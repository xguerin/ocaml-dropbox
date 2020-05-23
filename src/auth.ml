open Infix
open Lwt.Infix

module Protocol = struct
  module Token = struct
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

module S (Client : Cohttp_lwt.S.Client) = struct
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

  type code = string
  type token = string

  let token_uri = Uri.of_string "https://api.dropboxapi.com/oauth2/token"

  let token ?redirect_uri code ~id ~secret =
    let open Protocol.Token in
    let q =
      [ ("code", [code])
      ; ("grant_type", ["authorization_code"])
      ; ("client_id", [id])
      ; ("client_secret", [secret]) ] in
    let q =
      match redirect_uri with
      | None -> q
      | Some u -> ("redirect_uri", [Uri.to_string u]) :: q in
    Client.post @@ Uri.with_query token_uri q
    >>= Error.handle
    >>=? (fun (_, body) ->
           Cohttp_lwt.Body.to_string body
           >>= fun body ->
           let%lwt _ = Logs_lwt.info (fun m -> m "%s" body) in
           Json.of_string body)
    >>=? fun {access_token; _} -> Lwt.return_ok @@ Session.make access_token

  let revoke_uri =
    Uri.of_string "https://api.dropboxapi.com/2/auth/token/revoke"

  let revoke session =
    let headers = Session.headers session in
    Client.post ~headers revoke_uri >>= Error.handle
end
