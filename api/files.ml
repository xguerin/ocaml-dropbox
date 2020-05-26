open Endpoint
open Infix

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
      module Type = struct
        type t =
          | Malformed_path
          | Not_file
          | Not_folder
          | Not_found
          | Restricted_content
          | Unsupported_content_type

        let of_string = function
          | "malformed_path" -> Ok Malformed_path
          | "not_found" -> Ok Not_found
          | "not_file" -> Ok Not_file
          | "not_folder" -> Ok Not_folder
          | "restricted_content" -> Ok Restricted_content
          | "unsupported_content_type" -> Ok Unsupported_content_type
          | _ -> Error "Invalid LookupError format"

        let to_string = function
          | Malformed_path -> "malformed_path"
          | Not_found -> "not_found"
          | Not_file -> "not_file"
          | Not_folder -> "not_folder"
          | Restricted_content -> "restricted_content"
          | Unsupported_content_type -> "unsupported_content_type"

        let of_yojson = function
          | `Assoc [(".tag", `String v)] -> of_string v
          | `String v -> of_string v
          | _ -> Error "Invalid LookupError format"

        let to_yojson v = `String (to_string v)
      end

      let to_string = function
        | Type.Malformed_path -> "Malformed path"
        | Type.Not_file -> "Not a file"
        | Type.Not_folder -> "Not a folder"
        | Type.Not_found -> "Not found"
        | Type.Restricted_content -> "Restricted content"
        | Type.Unsupported_content_type -> "Unsupported content type"
    end

    module DownloadError = struct
      module Type = struct
        type t =
          | Path of LookupError.Type.t
          | Unsupported_file

        let of_yojson v =
          let sorted = Yojson.Safe.sort v in
          match sorted with
          | `Assoc [(".tag", `String "path"); ("path", path)] ->
            LookupError.Type.of_yojson path |>=? fun path -> Ok (Path path)
          | `Assoc [(".tag", `String "unsupported_file")]
          | `String "unsupported_file" ->
            Ok Unsupported_file
          | _ -> Error "Invalid DownloadError format"

        let to_yojson = function
          | Path path -> `Assoc [(".tag", LookupError.Type.to_yojson path)]
          | Unsupported_file -> `String "unsupported_file"
      end

      module Json = Json.S (Type)

      let to_string = function
        | Type.Path path -> LookupError.to_string path
        | Type.Unsupported_file -> "Unsupported file"
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

    module PhotoMetadata = struct
      module Type = struct
        type t =
          { dimensions : (Dimensions.Type.t option[@default None])
          ; location : (Dimensions.Type.t option[@default None])
          ; time_taken : (string option[@default None]) }
        [@@deriving yojson]
      end

      module Json = Json.S (Type)
    end

    module VideoMetadata = struct
      module Type = struct
        type t =
          { dimensions : (Dimensions.Type.t option[@default None])
          ; location : (Dimensions.Type.t option[@default None])
          ; time_taken : (string option[@default None])
          ; duration : (Int64.t option[@default None]) }
        [@@deriving yojson]
      end

      module Json = Json.S (Type)
    end

    module MediaMetadata = struct
      module Type = struct
        type t =
          | Photo of PhotoMetadata.Type.t
          | Video of VideoMetadata.Type.t

        let of_yojson v =
          let sorted = Yojson.Safe.sort v in
          match sorted with
          | `Assoc [(".tag", `String "photo"); ("photo", photo)] ->
            PhotoMetadata.Type.of_yojson photo |>=? fun p -> Ok (Photo p)
          | `Assoc [(".tag", `String "video"); ("video", video)] ->
            VideoMetadata.Type.of_yojson video |>=? fun v -> Ok (Video v)
          | _ -> Error "Invalid MediaMetadata format"

        let to_yojson = function
          | Photo photo ->
            `Assoc
              [ (".tag", `String "photo")
              ; ("photo", PhotoMetadata.Type.to_yojson photo) ]
          | Video video ->
            `Assoc
              [ (".tag", `String "video")
              ; ("video", VideoMetadata.Type.to_yojson video) ]
      end

      module Json = Json.S (Type)
    end

    module MediaInfo = struct
      module Type = struct
        type t =
          | Metadata of MediaMetadata.Type.t
          | Pending

        let of_yojson v =
          let sorted = Yojson.Safe.sort v in
          match sorted with
          | `Assoc [(".tag", `String "metadata"); ("metadata", metadata)] ->
            MediaMetadata.Type.of_yojson metadata |>=? fun m -> Ok (Metadata m)
          | `Assoc [(".tag", `String "pending")] | `String "pending" ->
            Ok Pending
          | _ -> Error "Invalid MediaInfo format"

        let to_yojson = function
          | Metadata metadata ->
            `Assoc
              [ (".tag", `String "metadata")
              ; ("metadata", MediaMetadata.Type.to_yojson metadata) ]
          | Pending -> `String "pending"
      end

      module Json = Json.S (Type)
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

    module FolderSharingInfo = struct
      module Type = struct
        type t =
          { read_only : bool
          ; parent_shared_folder_id : (string option[@default None])
          ; shared_folder_id : (string option[@default None])
          ; traverse_only : bool
          ; no_access : bool }
        [@@deriving yojson]
      end

      module Json = Json.S (Type)
    end

    module FolderMetadata = struct
      module Type = struct
        type t =
          { name : string
          ; id : string
          ; path_lower : (string option[@default None])
          ; path_display : (string option[@default None])
          ; parent_shared_folder_id : (string option[@default None])
          ; shared_folder_id : (string option[@default None])
          ; sharing_info : (FolderSharingInfo.Type.t option[@default None])
          ; property_groups : (PropertyGroup.Type.t option[@default None]) }
        [@@deriving yojson]
      end

      module Json = Json.S (Type)
    end

    module DownloadZipResult = struct
      module Type = struct
        type t = {metadata : FolderMetadata.Type.t} [@@deriving yojson]
      end

      module Json = Json.S (Type)
    end

    module DownloadZipError = struct
      module Type = struct
        type t =
          | Path of LookupError.Type.t
          | Too_large
          | Too_many_files

        let of_string = function
          | "too_large" -> Ok Too_large
          | "too_many_files" -> Ok Too_many_files
          | _ -> Error "Invalid DownloadZipError format"

        let to_string = function
          | Path _ -> "path"
          | Too_large -> "too_large"
          | Too_many_files -> "too_many_files"

        let of_yojson v =
          let sorted = Yojson.Safe.sort v in
          match sorted with
          | `Assoc [(".tag", `String "path"); ("path", path)] ->
            LookupError.Type.of_yojson path |>=? fun p -> Ok (Path p)
          | `Assoc [(".tag", `String v)] | `String v -> of_string v
          | _ -> Error "Invalid DownloadZipError format"

        let to_yojson = function
          | Path path -> `Assoc [(".tag", LookupError.Type.to_yojson path)]
          | v -> `String (to_string v)
      end

      module Json = Json.S (Type)

      let to_string = function
        | Type.Path path -> LookupError.to_string path
        | Type.Too_large -> "Too large"
        | Type.Too_many_files -> "Too many files"
    end

    module SharedLinkFileInfo = struct
      module Type = struct
        type t =
          { url : string
          ; path : (string option[@default None])
          ; password : (string option[@default None]) }
        [@@deriving yojson]
      end

      module Json = Json.S (Type)
    end

    module PathOrLink = struct
      module Type = struct
        type t =
          | Path of string
          | Link of SharedLinkFileInfo.Type.t

        let of_yojson v =
          let sorted = Yojson.Safe.sort v in
          match sorted with
          | `Assoc [(".tag", `String "path"); ("path", `String path)] ->
            Ok (Path path)
          | `Assoc [(".tag", `String "link"); ("link", link)] ->
            SharedLinkFileInfo.Type.of_yojson link |>=? fun l -> Ok (Link l)
          | _ -> Error "Invalid PathOrLink format"

        let to_yojson = function
          | Path path ->
            `Assoc [(".tag", `String "path"); ("path", `String path)]
          | Link link ->
            `Assoc
              [ (".tag", `String "link")
              ; ("link", SharedLinkFileInfo.Type.to_yojson link) ]
      end

      module Json = Json.S (Type)
    end

    module ThumbnailFormat = struct
      module Type = struct
        type t =
          | Jpeg
          | Png

        let of_string = function
          | "jpeg" -> Ok Jpeg
          | "png" -> Ok Png
          | _ -> Error "Invalid ThumbnailFormat format"

        let of_yojson = function
          | `Assoc [(".tag", `String value)] -> of_string value
          | `String value -> of_string value
          | _ -> Error "Invalid ThumbnailFormat format"

        let to_yojson = function Jpeg -> `String "jpeg" | Png -> `String "png"
      end

      module Json = Json.S (Type)
    end

    module ThumbnailSize = struct
      module Type = struct
        type t =
          | W32H32
          | W64H64
          | W128H128
          | W256H256
          | W480H320
          | W640H480
          | W960H640
          | W1024H768
          | W2048H1536

        let of_string = function
          | "w32h32" -> Ok W32H32
          | "w64h64" -> Ok W64H64
          | "w128h128" -> Ok W128H128
          | "w256h256" -> Ok W256H256
          | "w480h320" -> Ok W480H320
          | "w640h480" -> Ok W640H480
          | "w960h640" -> Ok W960H640
          | "w1024h768" -> Ok W1024H768
          | "w2048h1536" -> Ok W2048H1536
          | _ -> Error "Invalid ThumbnailSize format"

        let of_yojson = function
          | `Assoc [(".tag", `String value)] -> of_string value
          | `String value -> of_string value
          | _ -> Error "Invalid ThumbnailSize format"

        let to_yojson = function
          | W32H32 -> `String "w32h32"
          | W64H64 -> `String "w64h64"
          | W128H128 -> `String "w128h128"
          | W256H256 -> `String "w256h256"
          | W480H320 -> `String "w480h320"
          | W640H480 -> `String "w640h480"
          | W960H640 -> `String "w960h640"
          | W1024H768 -> `String "w1024h768"
          | W2048H1536 -> `String "w2048h1536"
      end

      module Json = Json.S (Type)
    end

    module ThumbnailMode = struct
      module Type = struct
        type t =
          | Strict
          | Bestfit
          | Fitone_bestfit

        let of_string = function
          | "strict" -> Ok Strict
          | "bestfit" -> Ok Bestfit
          | "fitone_bestfit" -> Ok Fitone_bestfit
          | _ -> Error "Invalid ThumbnailMode format"

        let of_yojson = function
          | `Assoc [(".tag", `String value)] -> of_string value
          | `String value -> of_string value
          | _ -> Error "Invalid ThumbnailMode format"

        let to_yojson = function
          | Strict -> `String "strict"
          | Bestfit -> `String "bestfit"
          | Fitone_bestfit -> `String "fitone_bestfit"
      end

      module Json = Json.S (Type)
    end

    module ThumbnailV2Arg = struct
      module Type = struct
        type t =
          { resource : PathOrLink.Type.t
          ; format : ThumbnailFormat.Type.t
          ; size : ThumbnailSize.Type.t
          ; mode : ThumbnailMode.Type.t }
        [@@deriving yojson]
      end

      module Json = Json.S (Type)
    end

    module MinimalFileLinkMetadata = struct
      module Type = struct
        type t =
          { url : string
          ; rev : string
          ; id : (string option[@default None])
          ; path : (string option[@default None]) }
        [@@deriving yojson]
      end

      module Json = Json.S (Type)
    end

    module PreviewResult = struct
      module Type = struct
        type t =
          { file_metadata : (FileMetadata.Type.t option[@default None])
          ; link_metadata :
              (MinimalFileLinkMetadata.Type.t option
              [@default None]) }
        [@@deriving yojson]
      end

      module Json = Json.S (Type)
    end

    module ThumbnailV2Error = struct
      module Type = struct
        type t =
          | Access_denied
          | Conversion_error
          | Not_found
          | Path of LookupError.Type.t
          | Unsupported_extension
          | Unsupported_image

        let of_string = function
          | "access_denied" -> Ok Access_denied
          | "conversion_error" -> Ok Conversion_error
          | "not_found" -> Ok Not_found
          | "unsupported_extension" -> Ok Unsupported_extension
          | "unsupported_image" -> Ok Unsupported_image
          | _ -> Error "Invalid ThumbnailV2Error format"

        let to_string = function
          | Access_denied -> "access_denied"
          | Conversion_error -> "conversion_error"
          | Not_found -> "not_found"
          | Path _ -> "path"
          | Unsupported_extension -> "unsupported_extension"
          | Unsupported_image -> "unsupported_image"

        let of_yojson v =
          let sorted = Yojson.Safe.sort v in
          match sorted with
          | `Assoc [(".tag", `String value)] -> of_string value
          | `Assoc [(".tag", `String "path"); ("path", path)] ->
            LookupError.Type.of_yojson path |>=? fun p -> Ok (Path p)
          | _ -> Error "Invalid ThumbnailV2Error format"

        let to_yojson = function
          | Path path ->
            `Assoc
              [ (".tag", `String "path")
              ; ("path", LookupError.Type.to_yojson path) ]
          | v -> `Assoc [(".tag", `String (to_string v))]
      end

      module Json = Json.S (Type)

      let to_string = function
        | Type.Access_denied -> "Access denied"
        | Type.Conversion_error -> "Conversion error"
        | Type.Not_found -> "Not found"
        | Type.Path v -> LookupError.to_string v
        | Type.Unsupported_extension -> "Unsupported extension"
        | Type.Unsupported_image -> "Unsupported image"
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

  module DownloadZip = struct
    module Arg = Protocol.DownloadArg
    module Result = Protocol.DownloadZipResult
    module Error = Error.S (Protocol.DownloadZipError)

    module Info = struct
      let uri = Root.content "/files/download_zip"
    end

    module Fn = ContentDownload.Function (C) (Arg) (Result) (Error) (Info)
  end

  let download_zip ~session path =
    let headers = Session.headers session in
    DownloadZip.Fn.call ~headers {path}

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

  module GetThumbnail = struct
    module Arg = Protocol.ThumbnailV2Arg
    module Result = Protocol.PreviewResult
    module Error = Error.S (Protocol.ThumbnailV2Error)

    module Info = struct
      let uri = Root.content "/files/get_thumbnail_v2"
    end

    module Fn = ContentDownload.Function (C) (Arg) (Result) (Error) (Info)
  end

  let get_thumbnail ~format ~size ~mode ~session resource =
    let request = GetThumbnail.Arg.Type.{resource; format; size; mode} in
    let headers = Session.headers session in
    GetThumbnail.Fn.call ~headers request

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
