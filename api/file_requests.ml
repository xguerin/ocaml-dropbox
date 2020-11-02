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
        type t = {file_request_count : Int64.t} [@@deriving yojson]
      end

      module Json = Json.Make (Type)
    end

    module CountFileRequestError = struct
      module Type = struct
        type t = Disabled_for_team [@@deriving dropbox]
      end

      module Json = Json.Make (Type)

      let to_string = function Type.Disabled_for_team -> "Disabled for team"
    end

    module FileRequestDeadline = struct
      module Type = struct
        type t =
          { deadline : string
          ; allow_late_uploads : (string option[@default None]) }
        [@@deriving yojson]
      end

      module Json = Json.Make (Type)

      let make e =
        Type.
          { deadline = ISO8601.Permissive.string_of_datetimezone e
          ; allow_late_uploads = None }
    end

    module CreateFileRequestArgs = struct
      module Type = struct
        type t =
          { title : string
          ; destination : string
          ; deadline : (FileRequestDeadline.Type.t option[@default None])
          ; open_ : bool [@key "open"] }
        [@@deriving yojson]
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
        [@@deriving yojson]
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
        [@@deriving dropbox]
      end

      module Json = Json.Make (Type)

      let to_string = function
        | Type.App_lacks_access -> "App lacks access"
        | Type.Disabled_for_team -> "Disabled for team"
        | Type.Email_unverified -> "Email unverified"
        | Type.Invalid_location -> "Invalid location"
        | Type.No_permission -> "No permission"
        | Type.Not_a_folder -> "Not a folder"
        | Type.Not_found -> "Not found"
        | Type.Rate_limit -> "Rate limit"
        | Type.Validation_error -> "Validation error"
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

  let count session =
    let get_count Count.Result.Type.{file_request_count; _} =
      Lwt.return_ok file_request_count in
    let headers = Session.headers session in
    Count.Fn.call ~headers () >>=? get_count

  (*
   * Create.
   *)

  module Create = struct
    module Args = Protocol.CreateFileRequestArgs
    module Result = Protocol.FileRequest
    module Error = Error.Make (Protocol.CreateFileRequestError)

    module Info = struct
      let uri = Root.api "/file_requests/create"
    end

    module Fn = Function (C) (Args) (Result) (Error) (Info)
  end

  let create ~title ~destination ?deadline ?(open_ = true) session =
    let deadline = Option.map Protocol.FileRequestDeadline.make deadline in
    let args = Create.Args.Type.{title; destination; deadline; open_} in
    let headers = Session.headers session in
    Create.Fn.call ~headers args

  (*
   * Delete.
   *)

  let delete_uri = Root.api "/file_requests/delete"

  let delete (_ : Session.Type.t) =
    let module Error = Error.Make (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Delete all closed.
   *)

  let delete_all_closed_uri = Root.api "/file_requests/delete_all_closed"

  let delete_all_closed (_ : Session.Type.t) =
    let module Error = Error.Make (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Get.
   *)

  let get_uri = Root.api "/file_requests/get"

  let get (_ : Session.Type.t) =
    let module Error = Error.Make (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * List.
   *)

  let list_uri = Root.api "/file_requests/list"

  let list (_ : Session.Type.t) =
    let module Error = Error.Make (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Update.
   *)

  let update_uri = Root.api "/file_requests/update"

  let update (_ : Session.Type.t) =
    let module Error = Error.Make (Error.Void) in
    Lwt.return_error Error.Not_implemented
end
