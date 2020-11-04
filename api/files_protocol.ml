open Common.Protocol

module DownloadArg = struct
  module Type = struct
    type t = {path : string} [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module DownloadError = struct
  module Type = struct
    type t =
      | Path of LookupError.Type.t
      | Unsupported_file
    [@@deriving dropbox, show]
  end

  module Json = Json.Make (Type)
end

module Dimensions = struct
  module Type = struct
    type t =
      { height : Int64.t
      ; width : Int64.t }
    [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module GpsCoordinates = struct
  module Type = struct
    type t =
      { latitude : float
      ; longitude : float }
    [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module PhotoMetadata = struct
  module Type = struct
    type t =
      { dimensions : Dimensions.Type.t option [@default None]
      ; location : Dimensions.Type.t option [@default None]
      ; time_taken : string option [@default None] }
    [@@deriving yojson, show]
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
    [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module MediaMetadata = struct
  module Type = struct
    type t =
      | Photo of PhotoMetadata.Type.t
      | Video of VideoMetadata.Type.t
    [@@deriving dropbox {mode = SubType}, show]
  end

  module Json = Json.Make (Type)
end

module MediaInfo = struct
  module Type = struct
    type t =
      | Metadata of MediaMetadata.Type.t
      | Pending
    [@@deriving dropbox, show]
  end

  module Json = Json.Make (Type)
end

module SymlinkInfo = struct
  module Type = struct
    type t = {target : string} [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module FileSharingInfo = struct
  module Type = struct
    type t =
      { read_only : bool
      ; parent_shared_folder_id : string
      ; modified_by : string option [@default None] }
    [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module ExportInfo = struct
  module Type = struct
    type t = {export_as : string option [@default None]}
    [@@deriving yojson, show]
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
    [@@deriving yojson, show]
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
    [@@deriving yojson, show]
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
    [@@deriving yojson, show]
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
      ; property_groups : PropertyGroup.Type.t list option [@default None] }
    [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module DownloadZipResult = struct
  module Type = struct
    type t = {metadata : FolderMetadata.Type.t} [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module DownloadZipError = struct
  module Type = struct
    type t =
      | Path of LookupError.Type.t
      | Too_large
      | Too_many_files
    [@@deriving dropbox, show]
  end

  module Json = Json.Make (Type)
end

module SharedLinkFileInfo = struct
  module Type = struct
    type t =
      { url : string
      ; path : string option [@default None]
      ; password : string option [@default None] }
    [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module PathOrLink = struct
  module Type = struct
    type t =
      | Path of string
      | Link of SharedLinkFileInfo.Type.t
    [@@deriving dropbox, show]
  end

  module Json = Json.Make (Type)
end

module ThumbnailFormat = struct
  module Type = struct
    type t =
      | Jpeg
      | Png
    [@@deriving dropbox, show]
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
    [@@deriving dropbox, show]
  end

  module Json = Json.Make (Type)
end

module ThumbnailMode = struct
  module Type = struct
    type t =
      | Strict
      | Bestfit
      | Fitone_bestfit
    [@@deriving dropbox, show]
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
    [@@deriving yojson, show]
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
    [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module PreviewResult = struct
  module Type = struct
    type t =
      { file_metadata : FileMetadata.Type.t option [@default None]
      ; link_metadata : MinimalFileLinkMetadata.Type.t option [@default None] }
    [@@deriving yojson, show]
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
    [@@deriving dropbox, show]
  end

  module Json = Json.Make (Type)
end

module SharedLink = struct
  module Type = struct
    type t =
      { url : string
      ; password : string option [@default None] }
    [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module TemplateFilterBase = struct
  module Type = struct
    type t = Filter_some of string list [@@deriving dropbox, show]
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
    [@@deriving yojson, show]
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
    [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module Metadata = struct
  module Type = struct
    type t =
      | Deleted of DeletedMetadata.Type.t
      | File of FileMetadata.Type.t
      | Folder of FolderMetadata.Type.t
    [@@deriving dropbox {mode = SubType}, show]
  end

  module Json = Json.Make (Type)
end

module MetadataV2 = struct
  module Type = struct
    type t = Metadata of Metadata.Type.t [@@deriving dropbox, show]
  end

  module Json = Json.Make (Type)
end

module ListFolderResult = struct
  module Type = struct
    type t =
      { entries : Metadata.Type.t list
      ; cursor : string
      ; has_more : bool }
    [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module TemplateError = struct
  module Type = struct
    type t =
      | Template_not_found
      | Restricted_content
    [@@deriving dropbox, show]
  end

  module Json = Json.Make (Type)
end

module ListFolderError = struct
  module Type = struct
    type t =
      | Path of LookupError.Type.t
      | Template_error of TemplateError.Type.t
    [@@deriving dropbox, show]
  end

  module Json = Json.Make (Type)
end

module ListFolderContinueArg = struct
  module Type = struct
    type t = {cursor : string} [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module ListFolderContinueError = struct
  module Type = struct
    type t =
      | Path of LookupError.Type.t
      | Reset
    [@@deriving dropbox, show]
  end

  module Json = Json.Make (Type)
end

module FileStatus = struct
  module Type = struct
    type t =
      | Active
      | Deleted
    [@@deriving dropbox, show]
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
    [@@deriving dropbox, show]
  end

  module Json = Json.Make (Type)
end

module SearchMatchFieldOptions = struct
  module Type = struct
    type t = {include_highlights : bool} [@@deriving yojson, show]
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
    [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module SearchV2Arg = struct
  module Type = struct
    type t =
      { query : string
      ; options : SearchOptions.Type.t option
      ; match_field_options : SearchMatchFieldOptions.Type.t option }
    [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module HighlightSpan = struct
  module Type = struct
    type t =
      { highlight_str : string
      ; is_highlighted : bool }
    [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module SearchMatchV2 = struct
  module Type = struct
    type t =
      { metadata : MetadataV2.Type.t
      ; highlight_spans : HighlightSpan.Type.t list option [@default None] }
    [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module SearchV2Result = struct
  module Type = struct
    type t =
      { matches : SearchMatchV2.Type.t list
      ; has_more : bool
      ; cursor : string option [@default None] }
    [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module SearchError = struct
  module Type = struct
    type t =
      | Path of LookupError.Type.t
      | Invalid_argument of string option
      | Internal_error
    [@@deriving dropbox, show]
  end

  module Json = Json.Make (Type)
end

module SearchV2ContinueArg = struct
  module Type = struct
    type t = {cursor : string} [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module CreateFolderArg = struct
  module Type = struct
    type t =
      { path : string
      ; autorename : bool }
    [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module CreateFolderResult = struct
  module Type = struct
    type t = {metadata : FolderMetadata.Type.t} [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module WriteConflictError = struct
  module Type = struct
    type t =
      | File
      | Folder
      | File_ancestor
    [@@deriving dropbox, show]
  end

  module Json = Json.Make (Type)
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
    [@@deriving dropbox, show]
  end

  module Json = Json.Make (Type)
end

module CreateFolderError = struct
  module Type = struct
    type t = Path of WriteError.Type.t [@@deriving dropbox, show]
  end

  module Json = Json.Make (Type)
end

module RelocationArg = struct
  module Type = struct
    type t =
      { from_path : string
      ; to_path : string
      ; allow_shared_folder : bool
      ; autorename : bool
      ; allow_ownership_transfer : bool }
    [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module RelocationResult = struct
  module Type = struct
    type t = {metadata : Metadata.Type.t} [@@deriving yojson, show]
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
    [@@deriving dropbox, show]
  end

  module Json = Json.Make (Type)
end

module GetMetadataArg = struct
  module Type = struct
    type t =
      { path : string
      ; include_media_info : bool
      ; include_deleted : bool
      ; include_has_explicit_shared_members : bool
      ; include_property_groups : TemplateFilterBase.Type.t option }
    [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module GetMetadataError = struct
  module Type = struct
    type t = Path of LookupError.Type.t [@@deriving dropbox, show]
  end

  module Json = Json.Make (Type)
end

module RelocationPath = struct
  module Type = struct
    type t =
      { from_path : string
      ; to_path : string }
    [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module RelocationBatchArgBase = struct
  module Type = struct
    type t =
      { entries : RelocationPath.Type.t list
      ; autorename : bool }
    [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module RelocationBatchErrorEntry = struct
  module Type = struct
    type t =
      | Relocation_error of RelocationError.Type.t
      | Internal_error
      | Too_many_write_operations
    [@@deriving dropbox, show]
  end

  module Json = Json.Make (Type)
end

module RelocationBatchResultEntry = struct
  module Type = struct
    type t =
      | Success of Metadata.Type.t
      | Failure of RelocationBatchErrorEntry.Type.t
    [@@deriving dropbox, show]
  end

  module Json = Json.Make (Type)
end

module RelocationBatchV2Result = struct
  module Type = struct
    type t = {entries : RelocationBatchResultEntry.Type.t list}
    [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module RelocationBatchV2Launch = struct
  module Type = struct
    type t =
      | Async_job_id of string
      | Complete of RelocationBatchV2Result.Type.t
    [@@deriving dropbox, show]
  end

  module Json = Json.Make (Type)
end

module PollArg = struct
  module Type = struct
    type t = {async_job_id : string} [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module RelocationBatchV2JobStatus = struct
  module Type = struct
    type t =
      | In_progress
      | Complete of RelocationBatchV2Result.Type.t
    [@@deriving dropbox, show]
  end

  module Json = Json.Make (Type)
end

module PollError = struct
  module Type = struct
    type t =
      | Invalid_async_job_id
      | Internal_error
    [@@deriving dropbox, show]
  end

  module Json = Json.Make (Type)
end

module GetCopyReferenceArg = struct
  module Type = struct
    type t = {path : string} [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module GetCopyReferenceResult = struct
  module Type = struct
    type t =
      { metadata : Metadata.Type.t
      ; copy_reference : string
      ; expires : string }
    [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module GetCopyReferenceError = struct
  module Type = struct
    type t = Path of LookupError.Type.t [@@deriving dropbox, show]
  end

  module Json = Json.Make (Type)
end

module SaveCopyReferenceArg = struct
  module Type = struct
    type t =
      { copy_reference : string
      ; path : string }
    [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module SaveCopyReferenceResult = struct
  module Type = struct
    type t = {metadata : Metadata.Type.t} [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module SaveCopyReferenceError = struct
  module Type = struct
    type t =
      | Path of WriteError.Type.t
      | Invalid_copy_reference
      | No_permission
      | Not_found
      | Too_many_files
    [@@deriving dropbox, show]
  end

  module Json = Json.Make (Type)
end

module CreateFolderBatchArg = struct
  module Type = struct
    type t =
      { paths : string list
      ; autorename : bool
      ; force_async : bool }
    [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module CreateFolderEntryResult = struct
  module Type = struct
    type t = {metadata : FolderMetadata.Type.t} [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module CreateFolderEntryError = struct
  module Type = struct
    type t = Path of WriteError.Type.t [@@deriving dropbox, show]
  end

  module Json = Json.Make (Type)
end

module CreateFolderBatchResultEntry = struct
  module Type = struct
    type t =
      | Success of CreateFolderEntryResult.Type.t
      | Failure of CreateFolderEntryError.Type.t
    [@@deriving dropbox, show]
  end

  module Json = Json.Make (Type)
end

module CreateFolderBatchResult = struct
  module Type = struct
    type t = {entries : CreateFolderBatchResultEntry.Type.t list}
    [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module CreateFolderBatchLaunch = struct
  module Type = struct
    type t =
      | Async_job_id of string
      | Complete of CreateFolderBatchResult.Type.t
    [@@deriving dropbox, show]
  end

  module Json = Json.Make (Type)
end

module CreateFolderBatchJobStatus = struct
  module Type = struct
    type t =
      | In_progress
      | Complete of CreateFolderBatchResult.Type.t
      | Failed of CreateFolderEntryError.Type.t
    [@@deriving dropbox, show]
  end

  module Json = Json.Make (Type)
end

module DeleteArg = struct
  module Type = struct
    type t =
      { path : string
      ; parent_rev : string option }
    [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module DeleteResult = struct
  module Type = struct
    type t = {metadata : Metadata.Type.t} [@@deriving yojson, show]
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
    [@@deriving dropbox, show]
  end

  module Json = Json.Make (Type)
end

module DeleteBatchArg = struct
  module Type = struct
    type t = {entries : DeleteArg.Type.t list} [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module DeleteBatchResultData = struct
  module Type = struct
    type t = {metadata : Metadata.Type.t} [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module DeleteBatchResultEntry = struct
  module Type = struct
    type t =
      | Success of DeleteBatchResultData.Type.t
      | Failure of DeleteError.Type.t
    [@@deriving dropbox, show]
  end

  module Json = Json.Make (Type)
end

module DeleteBatchResult = struct
  module Type = struct
    type t = {entries : DeleteBatchResultEntry.Type.t list}
    [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module DeleteBatchLaunch = struct
  module Type = struct
    type t =
      | Async_job_id of string
      | Complete of DeleteBatchResult.Type.t
    [@@deriving dropbox, show]
  end

  module Json = Json.Make (Type)
end

module DeleteBatchJobStatus = struct
  module Type = struct
    type t =
      | In_progress
      | Complete of DeleteBatchResult.Type.t
      | Failed of DeleteError.Type.t
    [@@deriving dropbox, show]
  end

  module Json = Json.Make (Type)
end

module ExportArg = struct
  module Type = struct
    type t = {path : string} [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module ExportMetadata = struct
  module Type = struct
    type t =
      { name : string
      ; size : Int64.t
      ; export_hash : string option }
    [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module ExportResult = struct
  module Type = struct
    type t =
      { export_metadata : ExportMetadata.Type.t
      ; file_metadata : FileMetadata.Type.t }
    [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module ExportError = struct
  module Type = struct
    type t =
      | Path of LookupError.Type.t
      | Non_exportable
      | Retry_error
    [@@deriving dropbox, show]
  end

  module Json = Json.Make (Type)
end

module LockFileArg = struct
  module Type = struct
    type t = {path : string} [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module LockFileBatchArg = struct
  module Type = struct
    type t = {entries : LockFileArg.Type.t} [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module SingleUserLock = struct
  module Type = struct
    type t =
      { created : string
      ; lock_holder_account_id : string
      ; lock_holder_team_id : string option }
    [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module FileLockContent = struct
  module Type = struct
    type t =
      | Unlocked
      | Single_user of SingleUserLock.Type.t
    [@@deriving dropbox, show]
  end

  module Json = Json.Make (Type)
end

module FileLock = struct
  module Type = struct
    type t = {content : FileLockContent.Type.t} [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module LockFileResult = struct
  module Type = struct
    type t =
      { metadata : Metadata.Type.t
      ; lock : FileLock.Type.t }
    [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module LockConflictError = struct
  module Type = struct
    type t = {lock : FileLock.Type.t} [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module LockFileError = struct
  module Type = struct
    type t =
      | Path_lookup of LookupError.Type.t
      | Too_many_write_operations
      | Too_many_files
      | No_write_permission
      | Cannot_be_locked
      | File_not_shared
      | Lock_conflict of LockConflictError.Type.t
      | Internal_error
    [@@deriving dropbox, show]
  end

  module Json = Json.Make (Type)
end

module LockFileResultEntry = struct
  module Type = struct
    type t =
      | Success of LockFileResult.Type.t
      | Failure of LockFileError.Type.t
    [@@deriving dropbox, show]
  end

  module Json = Json.Make (Type)
end

module LockFileBatchResult = struct
  module Type = struct
    type t = {entries : LockFileResultEntry.Type.t list}
    [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module PreviewArg = struct
  module Type = struct
    type t =
      { path : string
      ; rev : string option }
    [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module PreviewError = struct
  module Type = struct
    type t =
      | Path of LookupError.Type.t
      | In_progress
      | Unsupported_extension
      | Unsupported_content
    [@@deriving dropbox, show]
  end

  module Json = Json.Make (Type)
end
