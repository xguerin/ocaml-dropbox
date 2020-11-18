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

open Common_protocol

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

module GetTemporaryLinkArg = struct
  module Type = struct
    type t = {path : string} [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module GetTemporaryLinkResult = struct
  module Type = struct
    type t =
      { metadata : FileMetadata.Type.t
      ; link : string }
    [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module GetTemporaryLinkError = struct
  module Type = struct
    type t =
      | Path of LookupError.Type.t
      | Email_not_verified
      | Unsupported_file
    [@@deriving dropbox, show]
  end

  module Json = Json.Make (Type)
end

module GetTemporaryUpoadLinkArg = struct
  module Type = struct
    type t =
      { commit_info : CommitInfo.Type.t
      ; duration : float }
    [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module GetTemporaryUpoadLinkResult = struct
  module Type = struct
    type t = {link : string} [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module ThumbnailArg = struct
  module Type = struct
    type t =
      { path : string
      ; format : ThumbnailFormat.Type.t
      ; size : ThumbnailSize.Type.t
      ; mode : ThumbnailMode.Type.t }
    [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module GetThumbnailBatchArg = struct
  module Type = struct
    type t = {entries : ThumbnailArg.Type.t list} [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module ThumbnailError = struct
  module Type = struct
    type t =
      | Path of LookupError.Type.t
      | Unsupported_extension
      | Unsupported_image
      | Conversion_error
    [@@deriving dropbox, show]
  end

  module Json = Json.Make (Type)
end

module GetThumbnailBatchResultData = struct
  module Type = struct
    type t =
      { metadata : FileMetadata.Type.t
      ; thumbnail : string }
    [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module GetThumbnailBatchResultEntry = struct
  module Type = struct
    type t =
      | Success of GetThumbnailBatchResultData.Type.t
      | Failure of ThumbnailError.Type.t
    [@@deriving dropbox, show]
  end

  module Json = Json.Make (Type)
end

module GetThumbnailBatchResult = struct
  module Type = struct
    type t = {entries : GetThumbnailBatchResultEntry.Type.t list}
    [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module GetThumbnailBatchError = struct
  module Type = struct
    type t = Too_many_files [@@deriving dropbox, show]
  end

  module Json = Json.Make (Type)
end

module ListFolderGetLastCursorResult = struct
  module Type = struct
    type t = {cursor : string} [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module ListFolderLongPollArg = struct
  module Type = struct
    type t =
      { cursor : string
      ; timeout : Int64.t }
    [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module ListFolderLongPollResult = struct
  module Type = struct
    type t =
      { changes : bool
      ; backoff : Int64.t option }
    [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module ListFolderLongPollError = struct
  module Type = struct
    type t = Reset [@@deriving dropbox, show]
  end

  module Json = Json.Make (Type)
end

module ListRevisionsArg = struct
  module Type = struct
    type t =
      { path : string
      ; mode : ListRevisionsMode.Type.t
      ; limit : Int64.t }
    [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module ListRevisionsResult = struct
  module Type = struct
    type t =
      { is_deleted : bool
      ; entries : FileMetadata.Type.t list
      ; server_deleted : string option [@default None] }
    [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module ListRevisionsError = struct
  module Type = struct
    type t = Path of LookupError.Type.t [@@deriving dropbox, show]
  end

  module Json = Json.Make (Type)
end

module MoveBatchArg = struct
  module Type = struct
    type t =
      { entries : RelocationArg.Type.t list
      ; autorename : bool
      ; allow_ownership_transfer : bool }
    [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module RestoreArg = struct
  module Type = struct
    type t =
      { path : string
      ; rev : string }
    [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module RestoreError = struct
  module Type = struct
    type t =
      | Path_lookup of LookupError.Type.t
      | Path_write of WriteError.Type.t
      | Invalid_revision
      | In_progress
    [@@deriving dropbox, show]
  end

  module Json = Json.Make (Type)
end

module SaveUrlArg = struct
  module Type = struct
    type t =
      { path : string
      ; url : string }
    [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module SaveUrlResult = struct
  module Type = struct
    type t =
      | Async_job_id of string
      | Complete of FileMetadata.Type.t
    [@@deriving dropbox, show]
  end

  module Json = Json.Make (Type)
end

module SaveUrlError = struct
  module Type = struct
    type t =
      | Path of WriteError.Type.t
      | Download_failed
      | Invalid_revision
      | Not_found
    [@@deriving dropbox, show]
  end

  module Json = Json.Make (Type)
end

module SaveUrlJobStatus = struct
  module Type = struct
    type t =
      | In_progress
      | Complete of FileMetadata.Type.t
      | Failed of SaveUrlError.Type.t
    [@@deriving dropbox, show]
  end

  module Json = Json.Make (Type)
end

module UnlockFileArg = struct
  module Type = struct
    type t = {path : string} [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module UnlockFileBatchArg = struct
  module Type = struct
    type t = {entries : UnlockFileArg.Type.t list} [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module UploadWriteFailed = struct
  module Type = struct
    type t =
      { reason : WriteError.Type.t
      ; upload_session_id : string }
    [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module UploadError = struct
  module Type = struct
    type t =
      | Path of UploadWriteFailed.Type.t
      | Properties_error of InvalidPropertyGroupError.Type.t
    [@@deriving dropbox {mode = SubType}, show]
  end

  module Json = Json.Make (Type)
end

module UploadSessionStartArg = struct
  module Type = struct
    type t = {close : bool} [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module UploadSessionStartResult = struct
  module Type = struct
    type t = {session_id : string} [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module UploadSessionCursor = struct
  module Type = struct
    type t =
      { session_id : string
      ; offset : Int64.t }
    [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module UploadSessionAppendArg = struct
  module Type = struct
    type t =
      { cursor : UploadSessionCursor.Type.t
      ; close : bool }
    [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module UploadSessionOffsetError = struct
  module Type = struct
    type t = {correct_offset : Int64.t} [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module UploadSessionLookupError = struct
  module Type = struct
    type t =
      | Not_found
      | Incorrect_offset of UploadSessionOffsetError.Type.t
      | Closed
      | Not_closed
      | Too_large
    [@@deriving dropbox, show]
  end

  module Json = Json.Make (Type)
end

module UploadSessionFinishArg = struct
  module Type = struct
    type t =
      { cursor : UploadSessionCursor.Type.t
      ; commit : CommitInfo.Type.t }
    [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module UploadSessionFinishError = struct
  module Type = struct
    type t =
      | Lookup_failed of UploadSessionLookupError.Type.t
      | Path of WriteError.Type.t
      | Properties_error of InvalidPropertyGroupError.Type.t
      | Too_many_shared_folder_targets
      | Too_many_write_operations
    [@@deriving dropbox, show]
  end

  module Json = Json.Make (Type)
end

module UploadSessionFinishBatchArg = struct
  module Type = struct
    type t = {entries : UploadSessionFinishArg.Type.t} [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module UploadSessionFinishBatchResultEntry = struct
  module Type = struct
    type t =
      | Success of FileMetadata.Type.t
      | Failure of UploadSessionFinishError.Type.t
    [@@deriving dropbox, show]
  end

  module Json = Json.Make (Type)
end

module UploadSessionFinishBatchResult = struct
  module Type = struct
    type t = {entries : UploadSessionFinishBatchResultEntry.Type.t list}
    [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module UploadSessionFinishBatchLaunch = struct
  module Type = struct
    type t =
      | Async_job_id of string
      | Complete of UploadSessionFinishBatchResult.Type.t
    [@@deriving dropbox, show]
  end

  module Json = Json.Make (Type)
end

module UploadSessionFinishBatchJobStatus = struct
  module Type = struct
    type t =
      | In_progress
      | Complete of UploadSessionFinishBatchResult.Type.t
    [@@deriving dropbox, show]
  end

  module Json = Json.Make (Type)
end
