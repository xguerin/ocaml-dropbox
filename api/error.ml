open Cohttp

module type Endpoint = sig
  module Type : Json.Deriving
  module Json : Json.T with type t = Type.t

  val to_string : Type.t -> string
end

module type T = sig
  type endpoint

  type t =
    | Access_denied
    | Bad_input_parameter of string
    | Bad_or_expired_token
    | Endpoint of endpoint
    | Missing_header
    | Not_implemented
    | Serdes
    | Server
    | Too_many_requests of int
    | Unknown

  val handle :
       Response.t * Cohttp_lwt.Body.t
    -> (Response.t * Cohttp_lwt.Body.t, t) result Lwt.t

  val pp : Format.formatter -> t -> unit
end

module Void = struct
  module Type = struct
    type t = unit [@@deriving yojson]
  end

  module Json = Json.S (Type)

  let to_string _ = ""
end

module S (E : Endpoint) : T = struct
  type endpoint =
    { error : E.Type.t
    ; error_summary : string
    ; user_message : (string option[@default None]) }
  [@@deriving of_yojson]

  type t =
    | Access_denied
    | Bad_input_parameter of string
    | Bad_or_expired_token
    | Endpoint of endpoint
    | Missing_header
    | Not_implemented
    | Serdes
    | Server
    | Too_many_requests of int
    | Unknown

  let handle (resp, body) =
    match resp with
    | Response.{status = `Bad_request; _} ->
      let%lwt content = Cohttp_lwt.Body.to_string body in
      Lwt.return_error (Bad_input_parameter content)
    | Response.{status = `Conflict; _} -> (
      let%lwt content = Cohttp_lwt.Body.to_string body in
      match Yojson.Safe.from_string content |> endpoint_of_yojson with
      | Ok error -> Lwt.return_error (Endpoint error)
      | Error _ -> Lwt.return_error Serdes)
    | Response.{status = `Forbidden; _} -> Lwt.return_error Access_denied
    | Response.{status = `Too_many_requests; headers; _} ->
      let delay =
        match
          Option.bind (Header.get headers "Retry-After") int_of_string_opt
        with
        | Some v -> v
        | None -> 1 in
      Lwt.return_error (Too_many_requests delay)
    | Response.{status = `Unauthorized; _} ->
      Lwt.return_error Bad_or_expired_token
    | Response.{status; _} when Code.code_of_status status >= 400 ->
      Lwt.return_error Unknown
    | Response.{status; _} when Code.code_of_status status >= 500 ->
      Lwt.return_error Server
    | _ -> Lwt.return_ok (resp, body)

  let pp ppf = function
    | Access_denied -> Format.pp_print_string ppf "Access denied"
    | Bad_input_parameter v -> Format.pp_print_string ppf ("Bad input: " ^ v)
    | Bad_or_expired_token -> Format.pp_print_string ppf "Bad or expired token"
    | Endpoint {error; _} -> Format.pp_print_string ppf (E.to_string error)
    | Missing_header -> Format.pp_print_string ppf "Missing header"
    | Not_implemented -> Format.pp_print_string ppf "Not implemented"
    | Serdes -> Format.pp_print_string ppf "Serialization error"
    | Server -> Format.pp_print_string ppf "Server-side error"
    | Too_many_requests _ -> Format.pp_print_string ppf "Too many requests"
    | Unknown -> Format.pp_print_string ppf "Unknown error"
end
