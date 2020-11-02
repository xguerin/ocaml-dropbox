open Cohttp

module type Endpoint = sig
  module Type : Json.Deriving
  module Json : Json.S with type t = Type.t

  val to_string : Type.t -> string
end

module type T = sig
  type error
  type endpoint

  type t =
    | Access_denied
    | Bad_input_parameter of string
    | Bad_or_expired_token
    | Endpoint of endpoint
    | Missing_header
    | Not_implemented
    | Serdes of string
    | Server
    | Too_many_requests of int
    | Unknown

  val handle :
       Response.t * Cohttp_lwt.Body.t
    -> (Response.t * Cohttp_lwt.Body.t, t) result Lwt.t

  val to_string : t -> string
  val pp : Format.formatter -> t -> unit
  val unpack : endpoint -> error
end

module Void = struct
  module Type = struct
    type t = unit [@@deriving yojson]
  end

  module Json = Json.Make (Type)

  let to_string _ = ""
end

module Make (E : Endpoint) : T with type error = E.Type.t = struct
  type error = E.Type.t [@@deriving of_yojson]

  type endpoint =
    { error : error
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
    | Serdes of string
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
      | Error _ -> Lwt.return_error (Serdes content))
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

  let to_string = function
    | Access_denied -> "Access denied"
    | Bad_input_parameter v -> "Bad input: " ^ v
    | Bad_or_expired_token -> "Bad or expired token"
    | Endpoint {error; _} -> E.to_string error
    | Missing_header -> "Missing header"
    | Not_implemented -> "Not implemented"
    | Serdes c -> "Serialization error: " ^ c
    | Server -> "Server-side error"
    | Too_many_requests _ -> "Too many requests"
    | Unknown -> "Unknown error"

  let pp ppf v = Format.pp_print_string ppf (to_string v)
  let unpack {error; _} = error
end
