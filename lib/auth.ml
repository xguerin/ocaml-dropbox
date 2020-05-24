open Api
open RemoteProcedureCall
open Infix

module Protocol = struct
  module Result = struct
    module Type = struct
      type t =
        { access_token : string
        ; token_type : string
        ; account_id : (string option[@default None])
        ; team_id : (string option[@default None])
        ; uid : string }
      [@@deriving yojson]
    end

    module Json = Json.S (Type)
  end
end

module S (C : Cohttp_lwt.S.Client) = struct
  open Protocol

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
    module Uri = struct
      let uri = Uri.of_string "https://api.dropboxapi.com/oauth2/token"
    end

    module Fn = Supplier (C) (Result) (Uri)
  end

  let token ?redirect_uri code ~id ~secret =
    let q =
      [ ("code", [code])
      ; ("grant_type", ["authorization_code"])
      ; ("client_id", [id])
      ; ("client_secret", [secret]) ] in
    let q =
      match redirect_uri with
      | None -> q
      | Some u -> ("redirect_uri", [Uri.to_string u]) :: q in
    let get_info Result.Type.{access_token; _} =
      Lwt.return_ok @@ Session.make access_token in
    Token.Fn.call ~q () >>=? get_info

  (*
   * Revoke.
   *)

  module Revoke = struct
    module Uri = struct
      let uri = Root.api "/auth/token/revoke"
    end

    module Fn = Void (C) (Uri)
  end

  let revoke session =
    let headers = Session.headers session in
    Revoke.Fn.call ~headers ()
end
