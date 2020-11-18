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
    module Error = Error.Make (Error.Void)

    module Info = struct
      let uri = Root.api "/check/app"
    end

    module Fn = Function (C) (Query) (Result) (Error) (Info)
  end

  let app id secret =
    let basic = "Basic " ^ Base64.encode_string (id ^ ":" ^ secret) in
    let headers = Header.init_with "Authorization" basic in
    App.Fn.call ~headers {query = "Hello, world!"} >>=? check App.Error.Unknown

  (*
   * User.
   *)

  module User = struct
    module Query = Protocol.Query
    module Result = Protocol.Result
    module Error = Error.Make (Error.Void)

    module Info = struct
      let uri = Root.api "/check/user"
    end

    module Fn = Function (C) (Query) (Result) (Error) (Info)
  end

  let user ~session () =
    let headers = Session.headers session in
    User.Fn.call ~headers {query = "Hello, world!"}
    >>=? check User.Error.Unknown
end
