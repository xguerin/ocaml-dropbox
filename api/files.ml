open Endpoint

module Make (C : Cohttp_lwt.S.Client) = struct
  (*
   * Protocol.
   *)

  module Protocol = struct
    open Common.Protocol

    module DownloadArg = struct
      module Type = struct
        type t = {path : string} [@@deriving yojson]
      end

      module Json = Json.Make (Type)
    end

    module DownloadError = struct
      module Type = struct
        type t =
          | Path of LookupError.Type.t
          | Unsupported_file
        [@@deriving dropbox]
      end

      module Json = Json.Make (Type)

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

      module Json = Json.Make (Type)
    end

    module GpsCoordinates = struct
      module Type = struct
        type t =
          { latitude : float
          ; longitude : float }
        [@@deriving yojson]
      end

      module Json = Json.Make (Type)
    end

    module PhotoMetadata = struct
      module Type = struct
        type t =
          { dimensions : Dimensions.Type.t option [@default None]
          ; location : Dimensions.Type.t option [@default None]
          ; time_taken : string option [@default None] }
        [@@deriving yojson]
      end

      module Json = Json.Make (Type)
    end

    module VideoMetadata = struct
      module Type = struct
        type t =
          { dimensions : Dimensions.Type.t option [@default None]
          ; location : Dimensions.Type.t option [@default None]
          ; time_taken : string option [@default None]
          ; duration : Int64.t option [@default None] }
        [@@deriving yojson]
      end

      module Json = Json.Make (Type)
    end

    module MediaMetadata = struct
      module Type = struct
        type t =
          | Photo of PhotoMetadata.Type.t
          | Video of VideoMetadata.Type.t
        [@@deriving dropbox {mode = SubType}]
      end

      module Json = Json.Make (Type)
    end

    module MediaInfo = struct
      module Type = struct
        type t =
          | Metadata of MediaMetadata.Type.t
          | Pending
        [@@deriving dropbox]
      end

      module Json = Json.Make (Type)
    end

    module SymlinkInfo = struct
      module Type = struct
        type t = {target : string} [@@deriving yojson]
      end

      module Json = Json.Make (Type)
    end

    module FileSharingInfo = struct
      module Type = struct
        type t =
          { read_only : bool
          ; parent_shared_folder_id : string
          ; modified_by : string option [@default None] }
        [@@deriving yojson]
      end

      module Json = Json.Make (Type)
    end

    module ExportInfo = struct
      module Type = struct
        type t = {export_as : string option [@default None]} [@@deriving yojson]
      end

      module Json = Json.Make (Type)
    end

    module FileLockMetadata = struct
      module Type = struct
        type t =
          { is_lockholder : bool option [@default None]
          ; lockholder_name : string option [@default None]
          ; lockholder_account_id : string option [@default None]
          ; created : string option [@default None] }
        [@@deriving yojson]
      end

      module Json = Json.Make (Type)
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
          ; path_lower : string option [@default None]
          ; path_display : string option [@default None]
          ; parent_shared_folder_id : string option [@default None]
          ; media_info : MediaInfo.Type.t option [@default None]
          ; symlink_info : SymlinkInfo.Type.t option [@default None]
          ; sharing_info : FileSharingInfo.Type.t option [@default None]
          ; is_downloadable : bool
          ; export_info : ExportInfo.Type.t option [@default None]
          ; property_groups : PropertyGroup.Type.t list option [@default None]
          ; has_explicit_shared_members : bool option [@default None]
          ; content_hash : string option [@default None]
          ; file_lock_info : FileLockMetadata.Type.t option [@default None] }
        [@@deriving yojson]
      end

      module Json = Json.Make (Type)
    end

    module FolderSharingInfo = struct
      module Type = struct
        type t =
          { read_only : bool
          ; parent_shared_folder_id : string option [@default None]
          ; shared_folder_id : string option [@default None]
          ; traverse_only : bool
          ; no_access : bool }
        [@@deriving yojson]
      end

      module Json = Json.Make (Type)
    end

    module FolderMetadata = struct
      module Type = struct
        type t =
          { name : string
          ; id : string
          ; path_lower : string option [@default None]
          ; path_display : string option [@default None]
          ; parent_shared_folder_id : string option [@default None]
          ; shared_folder_id : string option [@default None]
          ; sharing_info : FolderSharingInfo.Type.t option [@default None]
          ; property_groups : PropertyGroup.Type.t list option [@default None]
          }
        [@@deriving yojson]
      end

      module Json = Json.Make (Type)
    end

    module DownloadZipResult = struct
      module Type = struct
        type t = {metadata : FolderMetadata.Type.t} [@@deriving yojson]
      end

      module Json = Json.Make (Type)
    end

    module DownloadZipError = struct
      module Type = struct
        type t =
          | Path of LookupError.Type.t
          | Too_large
          | Too_many_files
        [@@deriving dropbox]
      end

      module Json = Json.Make (Type)

      let to_string = function
        | Type.Path path -> LookupError.to_string path
        | Type.Too_large -> "Too large"
        | Type.Too_many_files -> "Too many files"
    end

    module SharedLinkFileInfo = struct
      module Type = struct
        type t =
          { url : string
          ; path : string option [@default None]
          ; password : string option [@default None] }
        [@@deriving yojson]
      end

      module Json = Json.Make (Type)
    end

    module PathOrLink = struct
      module Type = struct
        type t =
          | Path of string
          | Link of SharedLinkFileInfo.Type.t
        [@@deriving dropbox]
      end

      module Json = Json.Make (Type)
    end

    module ThumbnailFormat = struct
      module Type = struct
        type t =
          | Jpeg
          | Png
        [@@deriving dropbox]
      end

      module Json = Json.Make (Type)
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
        [@@deriving dropbox]
      end

      module Json = Json.Make (Type)
    end

    module ThumbnailMode = struct
      module Type = struct
        type t =
          | Strict
          | Bestfit
          | Fitone_bestfit
        [@@deriving dropbox]
      end

      module Json = Json.Make (Type)
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

      module Json = Json.Make (Type)
    end

    module MinimalFileLinkMetadata = struct
      module Type = struct
        type t =
          { url : string
          ; rev : string
          ; id : string option [@default None]
          ; path : string option [@default None] }
        [@@deriving yojson]
      end

      module Json = Json.Make (Type)
    end

    module PreviewResult = struct
      module Type = struct
        type t =
          { file_metadata : FileMetadata.Type.t option [@default None]
          ; link_metadata : MinimalFileLinkMetadata.Type.t option
                [@default None] }
        [@@deriving yojson]
      end

      module Json = Json.Make (Type)
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
        [@@deriving dropbox]
      end

      module Json = Json.Make (Type)

      let to_string = function
        | Type.Access_denied -> "Access denied"
        | Type.Conversion_error -> "Conversion error"
        | Type.Not_found -> "Not found"
        | Type.Path v -> "Path error: " ^ LookupError.to_string v
        | Type.Unsupported_extension -> "Unsupported extension"
        | Type.Unsupported_image -> "Unsupported image"
    end

    module SharedLink = struct
      module Type = struct
        type t =
          { url : string
          ; password : string option [@default None] }
        [@@deriving yojson]
      end

      module Json = Json.Make (Type)
    end

    module TemplateFilterBase = struct
      module Type = struct
        type t = Filter_some of string list [@@deriving dropbox]
      end

      module Json = Json.Make (Type)
    end

    module ListFolderArg = struct
      module Type = struct
        type t =
          { path : string
          ; recursive : bool
          ; include_media_info : bool
          ; include_deleted : bool
          ; include_has_explicit_shared_members : bool
          ; include_mounted_folders : bool
          ; limit : Int32.t option [@default None]
          ; shared_link : SharedLink.Type.t option [@default None]
          ; include_property_groups : TemplateFilterBase.Type.t option
                [@default None]
          ; include_non_downloadable_files : bool }
        [@@deriving yojson]
      end

      module Json = Json.Make (Type)
    end

    module DeletedMetadata = struct
      module Type = struct
        type t =
          { name : string
          ; path_lower : string option [@default None]
          ; path_display : string option [@default None]
          ; parent_shared_folder_id : string option [@default None] }
        [@@deriving yojson]
      end

      module Json = Json.Make (Type)
    end

    module Metadata = struct
      module Type = struct
        type t =
          | Deleted of DeletedMetadata.Type.t
          | File of FileMetadata.Type.t
          | Folder of FolderMetadata.Type.t
        [@@deriving dropbox {mode = SubType}]
      end

      module Json = Json.Make (Type)
    end

    module MetadataV2 = struct
      module Type = struct
        type t = Metadata of Metadata.Type.t [@@deriving dropbox]
      end

      module Json = Json.Make (Type)
    end

    module ListFolderResult = struct
      module Type = struct
        type t =
          { entries : Metadata.Type.t list
          ; cursor : string
          ; has_more : bool }
        [@@deriving yojson]
      end

      module Json = Json.Make (Type)
    end

    module TemplateError = struct
      module Type = struct
        type t =
          | Template_not_found
          | Restricted_content
        [@@deriving dropbox]
      end

      module Json = Json.Make (Type)

      let to_string = function
        | Type.Template_not_found -> "Template not found"
        | Type.Restricted_content -> "Restricted content"
    end

    module ListFolderError = struct
      module Type = struct
        type t =
          | Path of LookupError.Type.t
          | Template_error of TemplateError.Type.t
        [@@deriving dropbox]
      end

      module Json = Json.Make (Type)

      let to_string = function
        | Type.Path p -> LookupError.to_string p
        | Type.Template_error e -> TemplateError.to_string e
    end

    module ListFolderContinueArg = struct
      module Type = struct
        type t = {cursor : string} [@@deriving yojson]
      end

      module Json = Json.Make (Type)
    end

    module ListFolderContinueError = struct
      module Type = struct
        type t =
          | Path of LookupError.Type.t
          | Reset
        [@@deriving dropbox]
      end

      module Json = Json.Make (Type)

      let to_string = function
        | Type.Path p -> LookupError.to_string p
        | Type.Reset -> "Reset"
    end

    module FileStatus = struct
      module Type = struct
        type t =
          | Active
          | Deleted
        [@@deriving dropbox]
      end

      module Json = Json.Make (Type)
    end

    module FileCategory = struct
      module Type = struct
        type t =
          | Image
          | Document
          | PDF
          | Spreadsheet
          | Presentation
          | Audio
          | Video
          | Folder
          | Paper
          | Other
        [@@deriving dropbox]
      end

      module Json = Json.Make (Type)
    end

    module SearchMatchFieldOptions = struct
      module Type = struct
        type t = {include_highlights : bool} [@@deriving yojson]
      end

      module Json = Json.Make (Type)
    end

    module SearchOptions = struct
      module Type = struct
        type t =
          { path : string option
          ; max_results : Int64.t
          ; file_status : FileStatus.Type.t
          ; filename_only : bool
          ; file_extensions : string list option
          ; file_categories : FileCategory.Type.t list option }
        [@@deriving yojson]
      end

      module Json = Json.Make (Type)
    end

    module SearchV2Arg = struct
      module Type = struct
        type t =
          { query : string
          ; options : SearchOptions.Type.t option
          ; match_field_options : SearchMatchFieldOptions.Type.t option }
        [@@deriving yojson]
      end

      module Json = Json.Make (Type)
    end

    module HighlightSpan = struct
      module Type = struct
        type t =
          { highlight_str : string
          ; is_highlighted : bool }
        [@@deriving yojson]
      end

      module Json = Json.Make (Type)
    end

    module SearchMatchV2 = struct
      module Type = struct
        type t =
          { metadata : MetadataV2.Type.t
          ; highlight_spans : HighlightSpan.Type.t list option [@default None]
          }
        [@@deriving yojson]
      end

      module Json = Json.Make (Type)
    end

    module SearchV2Result = struct
      module Type = struct
        type t =
          { matches : SearchMatchV2.Type.t list
          ; has_more : bool
          ; cursor : string option [@default None] }
        [@@deriving yojson]
      end

      module Json = Json.Make (Type)
    end

    module SearchError = struct
      module Type = struct
        type t =
          | Path of LookupError.Type.t
          | Invalid_argument of string option
          | Internal_error
        [@@deriving dropbox]
      end

      module Json = Json.Make (Type)

      let to_string = function
        | Type.Path p -> LookupError.to_string p
        | Type.Invalid_argument None -> "Invalid argument"
        | Type.Invalid_argument (Some e) -> "Invalid argument: " ^ e
        | Type.Internal_error -> "Internal error"
    end

    module SearchV2ContinueArg = struct
      module Type = struct
        type t = {cursor : string} [@@deriving yojson]
      end

      module Json = Json.Make (Type)
    end

    module CreateFolderArg = struct
      module Type = struct
        type t =
          { path : string
          ; autorename : bool }
        [@@deriving yojson]
      end

      module Json = Json.Make (Type)
    end

    module CreateFolderResult = struct
      module Type = struct
        type t = {metadata : FolderMetadata.Type.t} [@@deriving yojson]
      end

      module Json = Json.Make (Type)
    end

    module WriteConflictError = struct
      module Type = struct
        type t =
          | File
          | Folder
          | File_ancestor
        [@@deriving dropbox]
      end

      module Json = Json.Make (Type)

      let to_string = function
        | Type.File -> "File"
        | Type.Folder -> "Folder"
        | Type.File_ancestor -> "File ancestor"
    end

    module WriteError = struct
      module Type = struct
        type t =
          | Malformed_path of string option
          | Conflict of WriteConflictError.Type.t
          | No_write_permission
          | Insufficient_space
          | Disallowed_name
          | Team_folder
          | Too_many_write_operations
        [@@deriving dropbox]
      end

      module Json = Json.Make (Type)

      let to_string = function
        | Type.Malformed_path (Some p) -> "Malformed path: " ^ p
        | Type.Malformed_path None -> "Malformed path"
        | Type.Conflict c -> WriteConflictError.to_string c ^ " already exists"
        | Type.No_write_permission -> "No write permission"
        | Type.Insufficient_space -> "Insufficient space"
        | Type.Disallowed_name -> "Disallowed name"
        | Type.Team_folder -> "Team folder"
        | Type.Too_many_write_operations -> "Too many write operations"
    end

    module CreateFolderError = struct
      module Type = struct
        type t = Path of WriteError.Type.t [@@deriving dropbox]
      end

      module Json = Json.Make (Type)

      let to_string = function Type.Path p -> WriteError.to_string p
    end

    module DeleteArg = struct
      module Type = struct
        type t =
          { path : string
          ; parent_rev : string option }
        [@@deriving yojson]
      end

      module Json = Json.Make (Type)
    end

    module DeleteResult = struct
      module Type = struct
        type t = {metadata : Metadata.Type.t} [@@deriving yojson]
      end

      module Json = Json.Make (Type)
    end

    module DeleteError = struct
      module Type = struct
        type t =
          | Path_lookup of LookupError.Type.t
          | Path_write of WriteError.Type.t
          | Too_many_write_operations
          | Too_many_files
        [@@deriving dropbox]
      end

      module Json = Json.Make (Type)

      let to_string = function
        | Type.Path_lookup p -> LookupError.to_string p
        | Type.Path_write p -> WriteError.to_string p
        | Type.Too_many_write_operations -> "Too many write operations"
        | Type.Too_many_files -> "Too many files"
    end

    module RelocationArg = struct
      module Type = struct
        type t =
          { from_path : string
          ; to_path : string
          ; allow_shared_folder : bool
          ; autorename : bool
          ; allow_ownership_transfer : bool }
        [@@deriving yojson]
      end

      module Json = Json.Make (Type)
    end

    module RelocationResult = struct
      module Type = struct
        type t = {metadata : Metadata.Type.t} [@@deriving yojson]
      end

      module Json = Json.Make (Type)
    end

    module RelocationError = struct
      module Type = struct
        type t =
          | From_lookup of LookupError.Type.t
          | From_write of WriteError.Type.t
          | To of WriteError.Type.t
          | Cant_copy_shared_folder
          | Cant_nest_shared_folder
          | Cant_move_folder_into_itself
          | Too_many_files
          | Duplicated_or_nested_paths
          | Cant_transfer_ownership
          | Insufficient_quota
          | Internal_error
          | Cant_move_shared_folder
          | Cant_move_into_vault
        [@@deriving dropbox]
      end

      module Json = Json.Make (Type)

      let to_string = function
        | Type.From_lookup p -> LookupError.to_string p
        | Type.From_write p -> WriteError.to_string p
        | Type.To p -> WriteError.to_string p
        | Type.Cant_copy_shared_folder -> "Can't copy shared folder"
        | Type.Cant_nest_shared_folder -> "Can't nest shared folder"
        | Type.Cant_move_folder_into_itself -> "Can't move folder into itself"
        | Type.Too_many_files -> "Too many files"
        | Type.Insufficient_quota -> "Insufficient quota"
        | Type.Duplicated_or_nested_paths -> "Duplicated or nested paths"
        | Type.Cant_transfer_ownership -> "Can't transfer ownership"
        | Type.Internal_error -> "Internal error"
        | Type.Cant_move_shared_folder -> "Can't move shared folder"
        | Type.Cant_move_into_vault -> "Can't move into vault"
    end

    module GetMetadataArg = struct
      module Type = struct
        type t =
          { path : string
          ; include_media_info : bool
          ; include_deleted : bool
          ; include_has_explicit_shared_members : bool
          ; include_property_groups : TemplateFilterBase.Type.t option }
        [@@deriving yojson]
      end

      module Json = Json.Make (Type)
    end

    module GetMetadataError = struct
      module Type = struct
        type t = Path of LookupError.Type.t [@@deriving dropbox]
      end

      module Json = Json.Make (Type)

      let to_string = function Type.Path p -> LookupError.to_string p
    end
  end

  (*
   * Copy.
   *)

  module Copy = struct
    module Arg = Protocol.RelocationArg
    module Result = Protocol.RelocationResult
    module Error = Error.Make (Protocol.RelocationError)

    module Info = struct
      let uri = Root.api "/files/copy_v2"
    end

    module Fn = RemoteProcedureCall.Function (C) (Arg) (Result) (Error) (Info)
  end

  let copy ~session from_path to_path =
    let request =
      Copy.Arg.Type.
        { from_path
        ; to_path
        ; allow_shared_folder = false
        ; autorename = false
        ; allow_ownership_transfer = false } in
    let headers = Session.headers session in
    Copy.Fn.call ~headers request

  (*
   * Copy batch.
   *)

  let copy_batch_uri = Root.api "/files/copy_batch_v2"

  let copy_batch (_ : Session.Type.t) =
    let module Error = Error.Make (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Copy batch check.
   *)

  let copy_batch_check_uri = Root.api "/files/copy_batch/check_v2"

  let copy_batch_check (_ : Session.Type.t) =
    let module Error = Error.Make (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Copy reference get.
   *)

  let copy_reference_get_uri = Root.api "/files/copy_reference/get"

  let copy_reference_get (_ : Session.Type.t) =
    let module Error = Error.Make (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Copy reference save.
   *)

  let copy_reference_save_uri = Root.api "/files/copy_reference/save"

  let copy_reference_save (_ : Session.Type.t) =
    let module Error = Error.Make (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Create folder.
   *)

  module CreateFolder = struct
    module Arg = Protocol.CreateFolderArg
    module Result = Protocol.CreateFolderResult
    module Error = Error.Make (Protocol.CreateFolderError)

    module Info = struct
      let uri = Root.api "/files/create_folder_v2"
    end

    module Fn = RemoteProcedureCall.Function (C) (Arg) (Result) (Error) (Info)
  end

  let create_folder ~session path =
    let request = CreateFolder.Arg.Type.{path; autorename = false} in
    let headers = Session.headers session in
    CreateFolder.Fn.call ~headers request

  (*
   * Create folder batch.
   *)

  let create_folder_batch_uri = Root.api "/files/create_folder_batch"

  let create_folder_batch (_ : Session.Type.t) =
    let module Error = Error.Make (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Create folder batch check.
   *)

  let create_folder_batch_check_uri =
    Root.api "/files/create_folder_batch/check"

  let create_folder_batch_check (_ : Session.Type.t) =
    let module Error = Error.Make (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Delete.
   *)

  module Delete = struct
    module Arg = Protocol.DeleteArg
    module Result = Protocol.DeleteResult
    module Error = Error.Make (Protocol.DeleteError)

    module Info = struct
      let uri = Root.api "/files/delete_v2"
    end

    module Fn = RemoteProcedureCall.Function (C) (Arg) (Result) (Error) (Info)
  end

  let delete ~session path =
    let request = Delete.Arg.Type.{path; parent_rev = None} in
    let headers = Session.headers session in
    Delete.Fn.call ~headers request

  (*
   * Delete batch.
   *)

  let delete_batch_uri = Root.api "/files/delete_batch"

  let delete_batch (_ : Session.Type.t) =
    let module Error = Error.Make (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Delete batch check.
   *)

  let delete_batch_check_uri = Root.api "/files/delete_batch/check"

  let delete_batch_check (_ : Session.Type.t) =
    let module Error = Error.Make (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Download.
   *)

  module Download = struct
    module Arg = Protocol.DownloadArg
    module Result = Protocol.FileMetadata
    module Error = Error.Make (Protocol.DownloadError)

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
    module Error = Error.Make (Protocol.DownloadZipError)

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
    let module Error = Error.Make (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Get file lock batch.
   *)

  let get_file_lock_batch_uri = Root.api "/files/get_file_lock_batch"

  let get_file_lock_batch (_ : Session.Type.t) =
    let module Error = Error.Make (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Get metadata.
   *)

  module GetMetadata = struct
    module Arg = Protocol.GetMetadataArg
    module Result = Protocol.Metadata
    module Error = Error.Make (Protocol.GetMetadataError)

    module Info = struct
      let uri = Root.api "/files/get_metadata"
    end

    module Fn = RemoteProcedureCall.Function (C) (Arg) (Result) (Error) (Info)
  end

  let get_metadata ~session path =
    let arg =
      GetMetadata.Arg.Type.
        { path = (if path = "/" then "" else path)
        ; include_media_info = false
        ; include_deleted = false
        ; include_has_explicit_shared_members = false
        ; include_property_groups = None } in
    let headers = Session.headers session in
    GetMetadata.Fn.call ~headers arg

  (*
   * Get preview.
   *)

  let get_preview_uri = Root.content "/files/get_preview"

  let get_preview (_ : Session.Type.t) =
    let module Error = Error.Make (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Get temporary link.
   *)

  let get_temporary_link_uri = Root.api "/files/get_temporary_link"

  let get_temporary_link (_ : Session.Type.t) =
    let module Error = Error.Make (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Get temporary upload link.
   *)

  let get_temporary_upload_link_uri =
    Root.api "/files/get_temporary_upload_link"

  let get_temporary_upload_link (_ : Session.Type.t) =
    let module Error = Error.Make (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Get thumbnail.
   *)

  module GetThumbnail = struct
    module Arg = Protocol.ThumbnailV2Arg
    module Result = Protocol.PreviewResult
    module Error = Error.Make (Protocol.ThumbnailV2Error)

    module Info = struct
      let uri = Root.content "/files/get_thumbnail_v2"
    end

    module Fn = ContentDownload.Function (C) (Arg) (Result) (Error) (Info)
  end

  let get_thumbnail ~session ~format ~size ~mode resource =
    let request = GetThumbnail.Arg.Type.{resource; format; size; mode} in
    let headers = Session.headers session in
    GetThumbnail.Fn.call ~headers request

  (*
   * Get thumbnail batch.
   *)

  let get_thumbnail_batch_uri = Root.content "/files/get_thumbnail_batch"

  let get_thumbnail_batch (_ : Session.Type.t) =
    let module Error = Error.Make (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * List folder.
   *)

  module ListFolder = struct
    module Arg = Protocol.ListFolderArg
    module Result = Protocol.ListFolderResult
    module Error = Error.Make (Protocol.ListFolderError)

    module Info = struct
      let uri = Root.api "/files/list_folder"
    end

    module Fn = RemoteProcedureCall.Function (C) (Arg) (Result) (Error) (Info)
  end

  let list_folder ~session path =
    let arg =
      ListFolder.Arg.Type.
        { path = (if path = "/" then "" else path)
        ; recursive = false
        ; include_media_info = false
        ; include_deleted = false
        ; include_has_explicit_shared_members = false
        ; include_mounted_folders = false
        ; limit = None
        ; shared_link = None
        ; include_property_groups = None
        ; include_non_downloadable_files = false } in
    let headers = Session.headers session in
    ListFolder.Fn.call ~headers arg

  (*
   * List folder continue.
   *)

  module ListFolderContinue = struct
    module Arg = Protocol.ListFolderContinueArg
    module Result = Protocol.ListFolderResult
    module Error = Error.Make (Protocol.ListFolderContinueError)

    module Info = struct
      let uri = Root.api "/files/list_folder/continue"
    end

    module Fn = RemoteProcedureCall.Function (C) (Arg) (Result) (Error) (Info)
  end

  let list_folder_continue ~session cursor =
    let arg = ListFolderContinue.Arg.Type.{cursor} in
    let headers = Session.headers session in
    ListFolderContinue.Fn.call ~headers arg

  (*
   * List folder get latest cursor.
   *)

  let list_folder_get_latest_cursor_uri =
    Root.api "/files/list_folder/get_latest_cursor"

  let list_folder_get_latest_cursor (_ : Session.Type.t) =
    let module Error = Error.Make (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * List folder long poll.
   *)

  let list_folder_longpoll_uri = Root.api "/files/list_folder/longpoll"

  let list_folder_longpoll (_ : Session.Type.t) =
    let module Error = Error.Make (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * List revisions.
   *)

  let list_revisions_uri = Root.api "/files/list_revisions"

  let list_revisions (_ : Session.Type.t) =
    let module Error = Error.Make (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Lock file batch.
   *)

  let lock_file_batch_uri = Root.api "/files/lock_file_batch"

  let lock_file_batch (_ : Session.Type.t) =
    let module Error = Error.Make (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Move.
   *)

  let move_uri = Root.api "/files/move_v2"

  let move (_ : Session.Type.t) =
    let module Error = Error.Make (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Move batch.
   *)

  let move_batch_uri = Root.api "/files/move_batch_v2"

  let move_batch (_ : Session.Type.t) =
    let module Error = Error.Make (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Move batch check.
   *)

  let move_batch_check_uri = Root.api "/files/move_batch/check_v2"

  let move_batch_check (_ : Session.Type.t) =
    let module Error = Error.Make (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Permanently delete.
   *)

  let permanently_delete_uri = Root.api "/files/permanently_delete"

  let permanently_delete (_ : Session.Type.t) =
    let module Error = Error.Make (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Restore.
   *)

  let restore_uri = Root.api "/files/restore"

  let restore (_ : Session.Type.t) =
    let module Error = Error.Make (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Save URL.
   *)

  let save_url_uri = Root.api "/files/save_url"

  let save_url (_ : Session.Type.t) =
    let module Error = Error.Make (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Save URL check job status.
   *)

  let save_url_check_job_status_uri =
    Root.api "/files/save_url/check_job_status"

  let save_url_check_job_status (_ : Session.Type.t) =
    let module Error = Error.Make (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Search.
   *)

  module Search = struct
    module Arg = Protocol.SearchV2Arg
    module Result = Protocol.SearchV2Result
    module Error = Error.Make (Protocol.SearchError)

    module Info = struct
      let uri = Root.api "/files/search_v2"
    end

    module Fn = RemoteProcedureCall.Function (C) (Arg) (Result) (Error) (Info)
  end

  let search ~session ?path ?(max_results = 100L) query =
    let options =
      match path with
      | Some path ->
        Some
          Protocol.SearchOptions.Type.
            { path = Some path
            ; max_results
            ; file_status = Protocol.FileStatus.Type.Active
            ; filename_only = true
            ; file_extensions = None
            ; file_categories = Some [Protocol.FileCategory.Type.Image] }
      | None -> None in
    let request = Search.Arg.Type.{query; options; match_field_options = None} in
    let headers = Session.headers session in
    Search.Fn.call ~headers request

  (*
   * Search continue.
   *)

  module SearchContinue = struct
    module Arg = Protocol.SearchV2ContinueArg
    module Result = Protocol.SearchV2Result
    module Error = Error.Make (Protocol.SearchError)

    module Info = struct
      let uri = Root.api "/files/search/continue_v2"
    end

    module Fn = RemoteProcedureCall.Function (C) (Arg) (Result) (Error) (Info)
  end

  let search_continue ~session cursor =
    let request = SearchContinue.Arg.Type.{cursor} in
    let headers = Session.headers session in
    SearchContinue.Fn.call ~headers request

  (*
   * Unlock file batch.
   *)

  let unlock_file_batch_uri = Root.api "/files/unlock_file_batch"

  let unlock_file_batch (_ : Session.Type.t) =
    let module Error = Error.Make (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Upload.
   *)

  let upload_uri = Root.content "/files/upload"

  let upload (_ : Session.Type.t) =
    let module Error = Error.Make (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Upload session start.
   *)

  let upload_session_start_uri = Root.content "/files/upload_session/start"

  let upload_session_start (_ : Session.Type.t) =
    let module Error = Error.Make (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Upload session append.
   *)

  let upload_session_append_uri = Root.content "/files/upload_session/append_v2"

  let upload_session_append (_ : Session.Type.t) =
    let module Error = Error.Make (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Upload session finish.
   *)

  let upload_session_finish_uri = Root.content "/files/upload_session/finish"

  let upload_session_finish (_ : Session.Type.t) =
    let module Error = Error.Make (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Upload session finish batch.
   *)

  let upload_session_finish_batch_uri =
    Root.api "/files/upload_session/finish_batch"

  let upload_session_finish_batch (_ : Session.Type.t) =
    let module Error = Error.Make (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Upload session finish batch check.
   *)

  let upload_session_finish_batch_check_uri =
    Root.api "/files/upload_session/finish_batch/check"

  let upload_session_finish_batch_check (_ : Session.Type.t) =
    let module Error = Error.Make (Error.Void) in
    Lwt.return_error Error.Not_implemented
end
