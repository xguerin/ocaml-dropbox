open Infix
open Lwt.Infix

module Protocol = struct
  module Query = struct
    module Type = struct
      type t = {query : string} [@@deriving yojson]
    end

    module Json = Json.S (Type)
  end

  module Result = struct
    module Type = struct
      type t = {result : string} [@@deriving yojson]
    end

    module Json = Json.S (Type)
  end
end

module S (Client : Cohttp_lwt.S.Client) = struct
  open Cohttp
  open Cohttp_lwt
  open Protocol

  let app_uri = Uri.of_string "https://api.dropboxapi.com/2/check/app"

  let app ~id ~secret () =
    let basic = "Basic " ^ Base64.encode_string (id ^ ":" ^ secret) in
    let headers = Header.init_with "Authorization" basic in
    let headers = Header.add headers "Content-Type" "application/json" in
    Query.Json.to_string {query = "Hello, world!"}
    >>= (fun query -> Client.post ~body:(`String query) ~headers app_uri)
    >>= Error.handle
    >>=? (fun (_, body) -> Body.to_string body >>= Result.Json.of_string)
    >>=? fun {result} ->
    if result = "Hello, world!"
    then Lwt.return_ok ()
    else Lwt.return_error Error.Unknown

  let user_uri = Uri.of_string "https://api.dropboxapi.com/2/check/user"

  let user session =
    let headers = Session.headers session in
    Query.Json.to_string {query = "Hello, world!"}
    >>= (fun query -> Client.post ~body:(`String query) ~headers user_uri)
    >>= Error.handle
    >>=? (fun (_, body) -> Body.to_string body >>= Result.Json.of_string)
    >>=? fun {result} ->
    if result = "Hello, world!"
    then Lwt.return_ok ()
    else Lwt.return_error Error.Unknown
end
