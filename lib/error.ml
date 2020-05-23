open Cohttp

type endpoint =
  { error : string
  ; error_summary : string
  ; user_message : (string option[@default None]) }
[@@deriving yojson]

type t =
  | Bad_input_parameter of string
  | Bad_or_expired_token
  | Access_denied
  | Endpoint_specific of endpoint
  | Too_many_requests of int
  | Not_implemented of string
  | Server
  | Serdes of string
  | Unknown

let handle (resp, body) =
  match resp with
  | Response.{status = `Bad_request; _} ->
    let%lwt content = Cohttp_lwt.Body.to_string body in
    Lwt.return_error (Bad_input_parameter content)
  | Response.{status = `Unauthorized; _} ->
    Lwt.return_error Bad_or_expired_token
  | Response.{status = `Forbidden; _} -> Lwt.return_error Access_denied
  | Response.{status = `Conflict; _} -> (
    let%lwt content = Cohttp_lwt.Body.to_string body in
    match Yojson.Safe.from_string content |> endpoint_of_yojson with
    | Ok ep -> Lwt.return_error (Endpoint_specific ep)
    | Error error -> Lwt.return_error (Serdes error))
  | Response.{status = `Too_many_requests; headers; _} ->
    let delay =
      match
        Option.bind (Header.get headers "Retry-After") int_of_string_opt
      with
      | Some v -> v
      | None -> 1 in
    Lwt.return_error (Too_many_requests delay)
  | Response.{status; _} when Code.code_of_status status >= 500 ->
    Lwt.return_error Server
  | Response.{status; _} when Code.code_of_status status >= 400 ->
    Lwt.return_error Unknown
  | _ -> Lwt.return_ok (resp, body)

let pp ppf = function
  | Bad_input_parameter v -> Format.pp_print_string ppf ("Bad input: " ^ v)
  | Bad_or_expired_token -> Format.pp_print_string ppf "Bad or expired token"
  | Access_denied -> Format.pp_print_string ppf "Access denied"
  | Endpoint_specific v ->
    let err = Yojson.Safe.to_string @@ endpoint_to_yojson v in
    Format.pp_print_string ppf ("Endpoint error: " ^ err)
  | Too_many_requests _ -> Format.pp_print_string ppf "Too many requests"
  | Not_implemented v -> Format.pp_print_string ppf ("Not implemented: " ^ v)
  | Server -> Format.pp_print_string ppf "Server-side error"
  | Serdes v -> Format.pp_print_string ppf ("Serialization error: " ^ v)
  | Unknown -> Format.pp_print_string ppf "Unknown error"
