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

open Endpoint
open RemoteProcedureCall
open Infix

module Make (C : Cohttp_lwt.S.Client) = struct
  (*
   * Protocol.
   *)

  module Protocol = struct
    module TokenResult = struct
      module Type = struct
        type t =
          { access_token : string
          ; token_type : string
          ; account_id : (string option[@default None])
          ; team_id : (string option[@default None])
          ; uid : string }
        [@@deriving yojson]
      end

      module Json = Json.Make (Type)
    end
  end

  (*
   * Authorize.
   *)

  let authorize_uri = Uri.of_string "https://www.dropbox.com/oauth2/authorize"

  let authorize ?(state = "") ?(force_reapprove = false)
      ?(disable_signup = false) ?locale ?(force_reauthentication = false)
      ~id:client_id response =
    let q =
      [ ("client_id", [client_id])
      ; ("state", [state])
      ; ("force_reapprove", [string_of_bool force_reapprove])
      ; ("disable_signup", [string_of_bool disable_signup])
      ; ("force_reauthentication", [string_of_bool force_reauthentication]) ]
    in
    let q =
      match response with
      | `Token uri ->
        ("response_type", ["token"])
        :: ("redirect_uri", [Uri.to_string uri])
        :: q
      | `Code (Some uri) ->
        ("response_type", ["code"])
        :: ("redirect_uri", [Uri.to_string uri])
        :: q
      | `Code None -> ("response_type", ["code"]) :: q in
    let q = match locale with Some l -> ("locale", [l]) :: q | None -> q in
    Uri.with_query authorize_uri q

  (*
   * Token.
   *)

  module Token = struct
    module Result = Protocol.TokenResult
    module Error = Error.Make (Error.Void)

    module Info = struct
      let uri = Uri.of_string "https://api.dropboxapi.com/oauth2/token"
    end

    module Fn = Supplier (C) (Result) (Error) (Info)
  end

  let token ?redirect_uri ~id ~secret code =
    let q =
      [ ("code", [code])
      ; ("grant_type", ["authorization_code"])
      ; ("client_id", [id])
      ; ("client_secret", [secret]) ] in
    let q =
      match redirect_uri with
      | None -> q
      | Some u -> ("redirect_uri", [Uri.to_string u]) :: q in
    let get_info Token.Result.Type.{access_token; _} =
      Lwt.return_ok @@ access_token in
    Token.Fn.call ~q () >>=? get_info

  (*
   * Revoke.
   *)

  module Revoke = struct
    module Error = Error.Make (Error.Void)

    module Info = struct
      let uri = Root.api "/auth/token/revoke"
    end

    module Fn = Void (C) (Error) (Info)
  end

  let revoke session =
    let headers = Session.headers session in
    Revoke.Fn.call ~headers () >>=? fun _ -> Lwt.return_ok ()
end
