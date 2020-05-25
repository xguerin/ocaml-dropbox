open Endpoint
open RemoteProcedureCall
open Infix

module S (C : Cohttp_lwt.S.Client) = struct
  open Cohttp

  (*
   * Protocol.
   *)

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

  (*
   * Common.
   *)

  let check Protocol.Result.Type.{result} =
    if result = "Hello, world!"
    then Lwt.return_ok ()
    else Lwt.return_error Error.Unknown

  (*
   * App.
   *)

  module App = struct
    module Query = Protocol.Query
    module Result = Protocol.Result

    module Info = struct
      let uri = Root.api "/check/app"
    end

    module Fn = Function (C) (Query) (Result) (Info)
  end

  let app ~id ~secret () =
    let basic = "Basic " ^ Base64.encode_string (id ^ ":" ^ secret) in
    let headers = Header.init_with "Authorization" basic in
    App.Fn.call ~headers {query = "Hello, world!"} >>=? check

  (*
   * User.
   *)

  module User = struct
    module Query = Protocol.Query
    module Result = Protocol.Result

    module Info = struct
      let uri = Root.api "/check/user"
    end

    module Fn = Function (C) (Query) (Result) (Info)
  end

  let user session =
    let headers = Session.headers session in
    User.Fn.call ~headers {query = "Hello, world!"} >>=? check
end
