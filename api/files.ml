open Endpoint

module S (C : Cohttp_lwt.S.Client) = struct
  (*
   * Protocol.
   *)

  module Protocol = struct
    module DownloadArg = struct
      module Type = struct
        type t = {path : string} [@@deriving yojson]
      end

      module Json = Json.S (Type)
    end

    module LookupError = struct
      include Protocol.Tagged

      let to_string Type.{tag} =
        match tag with
        | "malformed_path" -> "Malformed path"
        | "not_found" -> "Not found"
        | "not_file" -> "Not a file"
        | "not_folder" -> "Not a folder"
        | "restricted_content" -> "Restricted content"
        | "unsupported_content_type" -> "Unsupported content type"
        | _ -> "Unknown error"
    end

    module DownloadError = struct
      module Type = struct
        type t =
          { tag : string [@key ".tag"]
          ; path : (LookupError.Type.t option[@default None]) }
        [@@deriving yojson]
      end

      module Json = Json.S (Type)

      let to_string Type.{tag; path} =
        match (tag, path) with
        | "path", Some path -> LookupError.to_string path
        | "unsupported_file", _ -> "Unsupported file"
        | _ -> "Unknown error"
    end

    module Dimensions = struct
      module Type = struct
        type t =
          { height : Int64.t
          ; width : Int64.t }
        [@@deriving yojson]
      end

      module Json = Json.S (Type)
    end

    module GpsCoordinates = struct
      module Type = struct
        type t =
          { latitude : float
          ; longitude : float }
        [@@deriving yojson]
      end

      module Json = Json.S (Type)
    end

    module MediaMetadata = struct
      module Type = struct
        type t =
          { tag : string [@key ".tag"]
          ; dimensions : (Dimensions.Type.t option[@default None])
          ; location : (Dimensions.Type.t option[@default None])
          ; time_taken : (string option[@default None]) }
        [@@deriving yojson]
      end

      module Json = Json.S (Type)
    end

    module MediaInfo = struct
      module Type = struct
        type t =
          { tag : string [@key ".tag"]
          ; metadata : (MediaMetadata.Type.t option[@default None]) }
        [@@deriving yojson]
      end
    end

    module SymlinkInfo = struct
      module Type = struct
        type t = {target : string} [@@deriving yojson]
      end

      module Json = Json.S (Type)
    end

    module FileSharingInfo = struct
      module Type = struct
        type t =
          { read_only : bool
          ; parent_shared_folder_id : string
          ; modified_by : (string option[@default None]) }
        [@@deriving yojson]
      end

      module Json = Json.S (Type)
    end

    module ExportInfo = struct
      module Type = struct
        type t = {export_as : (string option[@default None])}
        [@@deriving yojson]
      end

      module Json = Json.S (Type)
    end

    module PropertyField = struct
      module Type = struct
        type t =
          { name : string
          ; value : string }
        [@@deriving yojson]
      end

      module Json = Json.S (Type)
    end

    module PropertyGroup = struct
      module Type = struct
        type t =
          { template_id : string
          ; fields : PropertyField.Type.t list }
        [@@deriving yojson]
      end

      module Json = Json.S (Type)
    end

    module FileLockMetadata = struct
      module Type = struct
        type t =
          { is_lockholder : (bool option[@default None])
          ; lockholder_name : (string option[@default None])
          ; lockholder_account_id : (string option[@default None])
          ; created : (string option[@default None]) }
        [@@deriving yojson]
      end

      module Json = Json.S (Type)
    end

    module FileMetadata = struct
      module Type = struct
        type t =
          { name : string
          ; id : string
          ; client_modified : string
          ; server_modified : string
          ; rev : string
          ; size : Int64.t
          ; path_lower : (string option[@default None])
          ; path_display : (string option[@default None])
          ; media_info : (MediaInfo.Type.t option[@default None])
          ; symlink_info : (SymlinkInfo.Type.t option[@default None])
          ; sharing_info : (FileSharingInfo.Type.t option[@default None])
          ; is_downloadable : bool
          ; export_info : (ExportInfo.Type.t option[@default None])
          ; property_groups : (PropertyGroup.Type.t option[@default None])
          ; has_explicit_shared_members : (bool option[@default None])
          ; content_hash : (string option[@default None])
          ; file_lock_info : (FileLockMetadata.Type.t option[@default None]) }
        [@@deriving yojson]
      end

      module Json = Json.S (Type)
    end
  end

  (*
   * Copy.
   *)

  let copy_uri = Root.api "/files/copy_v2"

  let copy (_ : Session.Type.t) =
    let module Error = Error.S (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Copy batch.
   *)

  let copy_batch_uri = Root.api "/files/copy_batch_v2"

  let copy_batch (_ : Session.Type.t) =
    let module Error = Error.S (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Copy batch check.
   *)

  let copy_batch_check_uri = Root.api "/files/copy_batch/check_v2"

  let copy_batch_check (_ : Session.Type.t) =
    let module Error = Error.S (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Copy reference get.
   *)

  let copy_reference_get_uri = Root.api "/files/copy_reference/get"

  let copy_reference_get (_ : Session.Type.t) =
    let module Error = Error.S (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Copy reference save.
   *)

  let copy_reference_save_uri = Root.api "/files/copy_reference/save"

  let copy_reference_save (_ : Session.Type.t) =
    let module Error = Error.S (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Create folder.
   *)
  let create_folder_uri = Root.api "/files/create_folder_v2"

  let create_folder (_ : Session.Type.t) =
    let module Error = Error.S (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Create folder batch.
   *)

  let create_folder_batch_uri = Root.api "/files/create_folder_batch"

  let create_folder_batch (_ : Session.Type.t) =
    let module Error = Error.S (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Create folder batch check.
   *)

  let create_folder_batch_check_uri =
    Root.api "/files/create_folder_batch/check"

  let create_folder_batch_check (_ : Session.Type.t) =
    let module Error = Error.S (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Delete.
   *)

  let delete_uri = Root.api "/files/delete_v2"

  let delete (_ : Session.Type.t) =
    let module Error = Error.S (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Delete batch.
   *)

  let delete_batch_uri = Root.api "/files/delete_batch"

  let delete_batch (_ : Session.Type.t) =
    let module Error = Error.S (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Delete batch check.
   *)

  let delete_batch_check_uri = Root.api "/files/delete_batch/check"

  let delete_batch_check (_ : Session.Type.t) =
    let module Error = Error.S (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Download.
   *)

  module Download = struct
    module Arg = Protocol.DownloadArg
    module Result = Protocol.FileMetadata
    module Error = Error.S (Protocol.DownloadError)

    module Info = struct
      let uri = Root.content "/files/download"
    end

    module Fn = ContentDownload.Function (C) (Arg) (Result) (Error) (Info)
  end

  let download ~session path =
    let headers = Session.headers session in
    Download.Fn.call ~headers {path}

  (*
   * Download zip.
   *)

  let download_zip_uri = Root.content "/files/download_zip"

  let download_zip (_ : Session.Type.t) =
    let module Error = Error.S (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Export.
   *)

  let export_uri = Root.content "/files/export"

  let export (_ : Session.Type.t) =
    let module Error = Error.S (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Get file lock batch.
   *)

  let get_file_lock_batch_uri = Root.api "/files/get_file_lock_batch"

  let get_file_lock_batch (_ : Session.Type.t) =
    let module Error = Error.S (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Get metadata.
   *)

  let get_metadata_uri = Root.api "/files/get_metadata"

  let get_metadata (_ : Session.Type.t) =
    let module Error = Error.S (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Get preview.
   *)

  let get_preview_uri = Root.content "/files/get_preview"

  let get_preview (_ : Session.Type.t) =
    let module Error = Error.S (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Get temporary link.
   *)

  let get_temporary_link_uri = Root.api "/files/get_temporary_link"

  let get_temporary_link (_ : Session.Type.t) =
    let module Error = Error.S (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Get temporary upload link.
   *)

  let get_temporary_upload_link_uri =
    Root.api "/files/get_temporary_upload_link"

  let get_temporary_upload_link (_ : Session.Type.t) =
    let module Error = Error.S (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Get thumbnail.
   *)

  let get_thumbnail_uri = Root.content "/files/get_thumbnail_v2"

  let get_thumbnail (_ : Session.Type.t) =
    let module Error = Error.S (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Get thumbnail batch.
   *)

  let get_thumbnail_batch_uri = Root.content "/files/get_thumbnail_batch"

  let get_thumbnail_batch (_ : Session.Type.t) =
    let module Error = Error.S (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * List folder.
   *)

  let list_folder_uri = Root.api "/files/list_folder"

  let list_folder (_ : Session.Type.t) =
    let module Error = Error.S (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * List folder continue.
   *)

  let list_folder_continue_uri = Root.api "/files/list_folder/continue"

  let list_folder_continue (_ : Session.Type.t) =
    let module Error = Error.S (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * List folder get latest cursor.
   *)

  let list_folder_get_latest_cursor_uri =
    Root.api "/files/list_folder/get_latest_cursor"

  let list_folder_get_latest_cursor (_ : Session.Type.t) =
    let module Error = Error.S (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * List folder long poll.
   *)

  let list_folder_longpoll_uri = Root.api "/files/list_folder/longpoll"

  let list_folder_longpoll (_ : Session.Type.t) =
    let module Error = Error.S (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * List revisions.
   *)

  let list_revisions_uri = Root.api "/files/list_revisions"

  let list_revisions (_ : Session.Type.t) =
    let module Error = Error.S (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Lock file batch.
   *)

  let lock_file_batch_uri = Root.api "/files/lock_file_batch"

  let lock_file_batch (_ : Session.Type.t) =
    let module Error = Error.S (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Move.
   *)

  let move_uri = Root.api "/files/move_v2"

  let move (_ : Session.Type.t) =
    let module Error = Error.S (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Move batch.
   *)

  let move_batch_uri = Root.api "/files/move_batch_v2"

  let move_batch (_ : Session.Type.t) =
    let module Error = Error.S (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Move batch check.
   *)

  let move_batch_check_uri = Root.api "/files/move_batch/check_v2"

  let move_batch_check (_ : Session.Type.t) =
    let module Error = Error.S (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Permanently delete.
   *)

  let permanently_delete_uri = Root.api "/files/permanently_delete"

  let permanently_delete (_ : Session.Type.t) =
    let module Error = Error.S (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Restore.
   *)

  let restore_uri = Root.api "/files/restore"

  let restore (_ : Session.Type.t) =
    let module Error = Error.S (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Save URL.
   *)

  let save_url_uri = Root.api "/files/save_url"

  let save_url (_ : Session.Type.t) =
    let module Error = Error.S (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Save URL check job status.
   *)

  let save_url_check_job_status_uri =
    Root.api "/files/save_url/check_job_status"

  let save_url_check_job_status (_ : Session.Type.t) =
    let module Error = Error.S (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Search.
   *)

  let search_uri = Root.api "/files/search_v2"

  let search (_ : Session.Type.t) =
    let module Error = Error.S (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Search continue.
   *)

  let search_continue_uri = Root.api "/files/search/continue_v2"

  let search_continue (_ : Session.Type.t) =
    let module Error = Error.S (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Unlock file batch.
   *)

  let unlock_file_batch_uri = Root.api "/files/unlock_file_batch"

  let unlock_file_batch (_ : Session.Type.t) =
    let module Error = Error.S (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Upload.
   *)

  let upload_uri = Root.content "/files/upload"

  let upload (_ : Session.Type.t) =
    let module Error = Error.S (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Upload session start.
   *)

  let upload_session_start_uri = Root.content "/files/upload_session/start"

  let upload_session_start (_ : Session.Type.t) =
    let module Error = Error.S (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Upload session append.
   *)

  let upload_session_append_uri = Root.content "/files/upload_session/append_v2"

  let upload_session_append (_ : Session.Type.t) =
    let module Error = Error.S (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Upload session finish.
   *)

  let upload_session_finish_uri = Root.content "/files/upload_session/finish"

  let upload_session_finish (_ : Session.Type.t) =
    let module Error = Error.S (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Upload session finish batch.
   *)

  let upload_session_finish_batch_uri =
    Root.api "/files/upload_session/finish_batch"

  let upload_session_finish_batch (_ : Session.Type.t) =
    let module Error = Error.S (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Upload session finish batch check.
   *)

  let upload_session_finish_batch_check_uri =
    Root.api "/files/upload_session/finish_batch/check"

  let upload_session_finish_batch_check (_ : Session.Type.t) =
    let module Error = Error.S (Error.Void) in
    Lwt.return_error Error.Not_implemented
end
