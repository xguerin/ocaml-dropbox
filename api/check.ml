open Endpoint
open RemoteProcedureCall
open Infix

module Make (C : Cohttp_lwt.S.Client) = struct
  open Cohttp

  (*
   * Protocol.
   *)

  module Protocol = struct
    module Query = struct
      module Type = struct
        type t = {query : string} [@@deriving yojson]
      end

      module Json = Json.Make (Type)
    end

    module Result = struct
      module Type = struct
        type t = {result : string} [@@deriving yojson]
      end

      module Json = Json.Make (Type)
    end
  end

  (*
   * Common.
   *)

  let check error Protocol.Result.Type.{result} =
    if result = "Hello, world!"
    then Lwt.return_ok ()
    else Lwt.return_error error

  (*
   * App.
   *)

  module App = struct
    module Query = Protocol.Query
    module Result = Protocol.Result
    module Error = Error.S (Error.Void)

    module Info = struct
      let uri = Root.api "/check/app"
    end

    module Fn = Function (C) (Query) (Result) (Error) (Info)
  end

  let app ~id ~secret () =
    let basic = "Basic " ^ Base64.encode_string (id ^ ":" ^ secret) in
    let headers = Header.init_with "Authorization" basic in
    App.Fn.call ~headers {query = "Hello, world!"} >>=? check App.Error.Unknown

  (*
   * User.
   *)

  module User = struct
    module Query = Protocol.Query
    module Result = Protocol.Result
    module Error = Error.S (Error.Void)

    module Info = struct
      let uri = Root.api "/check/user"
    end

    module Fn = Function (C) (Query) (Result) (Error) (Info)
  end

  let user session =
    let headers = Session.headers session in
    User.Fn.call ~headers {query = "Hello, world!"}
    >>=? check User.Error.Unknown
end
