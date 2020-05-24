open Api
open RemoteProcedureCall
open Infix

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

module S (C : Cohttp_lwt.S.Client) = struct
  open Cohttp
  open Protocol

  let check Result.Type.{result} =
    if result = "Hello, world!"
    then Lwt.return_ok ()
    else Lwt.return_error Error.Unknown

  module AppEndpoint = struct
    let uri = Root.api "/check/app"
  end

  module App = Function (C) (Query) (Result) (AppEndpoint)

  let app ~id ~secret () =
    let basic = "Basic " ^ Base64.encode_string (id ^ ":" ^ secret) in
    let headers = Header.init_with "Authorization" basic in
    App.call ~headers {query = "Hello, world!"} >>=? check

  module UserEndpoint = struct
    let uri = Root.api "/check/user"
  end

  module User = Function (C) (Query) (Result) (UserEndpoint)

  let user session =
    let headers = Session.headers session in
    User.call ~headers {query = "Hello, world!"} >>=? check
end
