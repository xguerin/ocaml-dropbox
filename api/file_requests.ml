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
    module CountFileRequestResult = struct
      module Type = struct
        type t = {file_request_count : Int64.t} [@@deriving yojson, show]
      end

      module Json = Json.Make (Type)
    end

    module CountFileRequestError = struct
      module Type = struct
        type t = Disabled_for_team [@@deriving dropbox, show]
      end

      module Json = Json.Make (Type)
    end

    module FileRequestDeadline = struct
      module Type = struct
        type t =
          { deadline : string
          ; allow_late_uploads : (string option[@default None]) }
        [@@deriving yojson, show]
      end

      module Json = Json.Make (Type)
    end

    module CreateFileRequestArgs = struct
      module Type = struct
        type t =
          { title : string
          ; destination : string
          ; deadline : (FileRequestDeadline.Type.t option[@default None])
          ; open_ : bool [@key "open"]
          ; description : string option }
        [@@deriving yojson, show]
      end

      module Json = Json.Make (Type)
    end

    module FileRequest = struct
      module Type = struct
        type t =
          { id : string
          ; url : string
          ; title : string
          ; created : string
          ; is_open : bool
          ; file_count : Int64.t
          ; destination : string
          ; deadline : (FileRequestDeadline.Type.t option[@default None]) }
        [@@deriving yojson, show]
      end

      module Json = Json.Make (Type)
    end

    module CreateFileRequestError = struct
      module Type = struct
        type t =
          | App_lacks_access
          | Disabled_for_team
          | Email_unverified
          | Invalid_location
          | No_permission
          | Not_a_folder
          | Not_found
          | Rate_limit
          | Validation_error
        [@@deriving dropbox, show]
      end

      module Json = Json.Make (Type)
    end

    module DeleteFileRequestArgs = struct
      module Type = struct
        type t = {ids : string list} [@@deriving yojson, show]
      end

      module Json = Json.Make (Type)
    end

    module DeleteFileRequestResult = struct
      module Type = struct
        type t = {file_requests : FileRequest.Type.t list}
        [@@deriving yojson, show]
      end

      module Json = Json.Make (Type)
    end

    module DeleteFileRequestError = struct
      module Type = struct
        type t =
          | Disabled_for_team
          | Not_found
          | Not_a_folder
          | App_lacks_access
          | No_permission
          | Email_unverified
          | Validation_error
          | File_request_open
        [@@deriving dropbox, show]
      end

      module Json = Json.Make (Type)
    end

    module DeleteAllClosedFileRequestsResult = struct
      module Type = struct
        type t = {file_requests : FileRequest.Type.t list}
        [@@deriving yojson, show]
      end

      module Json = Json.Make (Type)
    end

    module DeleteAllClosedFileRequestsError = struct
      module Type = struct
        type t =
          | Disabled_for_team
          | Not_found
          | Not_a_folder
          | App_lacks_access
          | No_permission
          | Email_unverified
          | Validation_error
        [@@deriving dropbox, show]
      end

      module Json = Json.Make (Type)
    end

    module GetFileRequestArgs = struct
      module Type = struct
        type t = {id : string} [@@deriving yojson, show]
      end

      module Json = Json.Make (Type)
    end

    module GetFileRequestError = struct
      module Type = struct
        type t =
          | Disabled_for_team
          | Not_found
          | Not_a_folder
          | App_lacks_access
          | No_permission
          | Email_unverified
          | Validation_error
        [@@deriving dropbox, show]
      end

      module Json = Json.Make (Type)
    end

    module ListFileRequestsArgs = struct
      module Type = struct
        type t = {limit : Int64.t} [@@deriving yojson, show]
      end

      module Json = Json.Make (Type)
    end

    module ListFileRequestsV2Result = struct
      module Type = struct
        type t =
          { file_requests : FileRequest.Type.t list
          ; cursor : string
          ; has_more : bool }
        [@@deriving yojson, show]
      end

      module Json = Json.Make (Type)
    end

    module ListFileRequestsError = struct
      module Type = struct
        type t = Disabled_for_team [@@deriving dropbox, show]
      end

      module Json = Json.Make (Type)
    end

    module UpdateFileRequestDeadline = struct
      module Type = struct
        type t =
          | No_update
          | Update of FileRequestDeadline.Type.t option
        [@@deriving dropbox, show]
      end

      module Json = Json.Make (Type)
    end

    module UpdateFileRequestArgs = struct
      module Type = struct
        type t =
          { id : string
          ; title : string option
          ; destination : string option
          ; deadline : UpdateFileRequestDeadline.Type.t
          ; open_ : bool option [@key "open"]
          ; description : string option }
        [@@deriving yojson, show]
      end

      module Json = Json.Make (Type)
    end

    module UpdateFileRequestError = struct
      module Type = struct
        type t =
          | Disabled_for_team
          | Not_found
          | Not_a_folder
          | App_lacks_access
          | No_permission
          | Email_unverified
          | Validation_error
        [@@deriving dropbox, show]
      end

      module Json = Json.Make (Type)
    end
  end

  (*
   * Count.
   *)

  module Count = struct
    module Result = Protocol.CountFileRequestResult
    module Error = Error.Make (Protocol.CountFileRequestError)

    module Info = struct
      let uri = Root.api "/file_requests/count"
    end

    module Fn = Supplier (C) (Result) (Error) (Info)
  end

  let count ~session () =
    let get_count Count.Result.Type.{file_request_count; _} =
      Lwt.return_ok file_request_count in
    let headers = Session.headers session in
    Count.Fn.call ~headers () >>=? get_count

  (*
   * Create.
   *)

  module Create = struct
    module Arg = Protocol.CreateFileRequestArgs
    module Result = Protocol.FileRequest
    module Error = Error.Make (Protocol.CreateFileRequestError)

    module Info = struct
      let uri = Root.api "/file_requests/create"
    end

    module Fn = Function (C) (Arg) (Result) (Error) (Info)
  end

  let create ~session ?deadline ?(open_ = true) ?description title destination =
    let args =
      Create.Arg.Type.{title; destination; deadline; open_; description} in
    let headers = Session.headers session in
    Create.Fn.call ~headers args

  (*
   * Delete.
   *)

  module Delete = struct
    module Arg = Protocol.DeleteFileRequestArgs
    module Result = Protocol.DeleteFileRequestResult
    module Error = Error.Make (Protocol.DeleteFileRequestError)

    module Info = struct
      let uri = Root.api "/file_requests/delete"
    end

    module Fn = Function (C) (Arg) (Result) (Error) (Info)
  end

  let delete ~session ids =
    let request = Delete.Arg.Type.{ids}
    and headers = Session.headers session in
    Delete.Fn.call ~headers request

  (*
   * Delete all closed.
   *)
  module DeleteAllClosed = struct
    module Result = Protocol.DeleteAllClosedFileRequestsResult
    module Error = Error.Make (Protocol.DeleteAllClosedFileRequestsError)

    module Info = struct
      let uri = Root.api "/file_requests/delete_all_closed"
    end

    module Fn = Supplier (C) (Result) (Error) (Info)
  end

  let delete_all_closed ~session () =
    let headers = Session.headers session in
    DeleteAllClosed.Fn.call ~headers ()

  (*
   * Get.
   *)

  module Get = struct
    module Arg = Protocol.GetFileRequestArgs
    module Result = Protocol.FileRequest
    module Error = Error.Make (Protocol.GetFileRequestError)

    module Info = struct
      let uri = Root.api "/file_requests/get"
    end

    module Fn = Function (C) (Arg) (Result) (Error) (Info)
  end

  let get ~session id =
    let request = Get.Arg.Type.{id}
    and headers = Session.headers session in
    Get.Fn.call ~headers request

  (*
   * List.
   *)

  module List = struct
    module Arg = Protocol.ListFileRequestsArgs
    module Result = Protocol.ListFileRequestsV2Result
    module Error = Error.Make (Protocol.ListFileRequestsError)

    module Info = struct
      let uri = Root.api "/file_requests/list_v2"
    end

    module Fn = Function (C) (Arg) (Result) (Error) (Info)
  end

  let list ~session limit =
    let request = List.Arg.Type.{limit}
    and headers = Session.headers session in
    List.Fn.call ~headers request

  (*
   * Update.
   *)

  module Update = struct
    module Arg = Protocol.UpdateFileRequestArgs
    module Result = Protocol.FileRequest
    module Error = Error.Make (Protocol.UpdateFileRequestError)

    module Info = struct
      let uri = Root.api "/file_requests/update"
    end

    module Fn = Function (C) (Arg) (Result) (Error) (Info)
  end

  let update ~session ?title ?destination ?open_ ?description id deadline =
    let request =
      Update.Arg.Type.{id; title; destination; open_; deadline; description}
    and headers = Session.headers session in
    Update.Fn.call ~headers request
end
