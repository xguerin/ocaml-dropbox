(* 
 * Copyright (c) 2020 Xavier R. Guérin <copyright@applepine.org>
 * 
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *)

open Cohttp

module type Endpoint = sig
  module Type : sig
    include Json.Deriving

    val pp : Format.formatter -> t -> unit
    val show : t -> string
  end

  module Json : Json.S with type t = Type.t
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

  val show : t -> string
  val pp : Format.formatter -> t -> unit
  val unpack : endpoint -> error
end

module Void = struct
  module Type = struct
    type t = unit [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module Make (E : Endpoint) : T with type error = E.Type.t = struct
  type error = E.Type.t [@@deriving of_yojson, show]

  type endpoint =
    { error : error
    ; error_summary : string
    ; user_message : (string option[@default None]) }
  [@@deriving of_yojson, show]

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
  [@@deriving show]

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

  let unpack {error; _} = error
end
