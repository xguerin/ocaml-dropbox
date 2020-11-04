open Endpoint

module Make (C : Cohttp_lwt.S.Client) = struct
  (*
   * Protocol.
   *)

  module Protocol = struct
    include Common_protocol
    include Files_protocol
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

  module CopyBatch = struct
    module Arg = Protocol.RelocationBatchArgBase
    module Result = Protocol.RelocationBatchV2Launch
    module Error = Error.Make (Error.Void)

    module Info = struct
      let uri = Root.api "/files/copy_batch_v2"
    end

    module Fn = RemoteProcedureCall.Function (C) (Arg) (Result) (Error) (Info)
  end

  let copy_batch ~session ?(autorename = false) entries =
    let request = CopyBatch.Arg.Type.{entries; autorename}
    and headers = Session.headers session in
    CopyBatch.Fn.call ~headers request

  (*
   * Copy batch check.
   *)

  module CopyBatchCheck = struct
    module Arg = Protocol.PollArg
    module Result = Protocol.RelocationBatchV2JobStatus
    module Error = Error.Make (Protocol.PollError)

    module Info = struct
      let uri = Root.api "/files/copy_batch/check_v2"
    end

    module Fn = RemoteProcedureCall.Function (C) (Arg) (Result) (Error) (Info)
  end

  let copy_batch_check ~session async_job_id =
    let request = CopyBatchCheck.Arg.Type.{async_job_id}
    and headers = Session.headers session in
    CopyBatchCheck.Fn.call ~headers request

  (*
   * Copy reference get.
   *)

  module CopyReferenceGet = struct
    module Arg = Protocol.GetCopyReferenceArg
    module Result = Protocol.GetCopyReferenceResult
    module Error = Error.Make (Protocol.GetCopyReferenceError)

    module Info = struct
      let uri = Root.api "/files/copy_reference/get"
    end

    module Fn = RemoteProcedureCall.Function (C) (Arg) (Result) (Error) (Info)
  end

  let copy_reference_get ~session path =
    let request = CopyReferenceGet.Arg.Type.{path}
    and headers = Session.headers session in
    CopyReferenceGet.Fn.call ~headers request

  (*
   * Copy reference save.
   *)

  module CopyReferenceSave = struct
    module Arg = Protocol.SaveCopyReferenceArg
    module Result = Protocol.SaveCopyReferenceResult
    module Error = Error.Make (Protocol.SaveCopyReferenceError)

    module Info = struct
      let uri = Root.api "/files/copy_reference/save"
    end

    module Fn = RemoteProcedureCall.Function (C) (Arg) (Result) (Error) (Info)
  end

  let copy_reference_save ~session copy_reference path =
    let request = CopyReferenceSave.Arg.Type.{copy_reference; path}
    and headers = Session.headers session in
    CopyReferenceSave.Fn.call ~headers request

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
    let request = CreateFolder.Arg.Type.{path; autorename = false}
    and headers = Session.headers session in
    CreateFolder.Fn.call ~headers request

  (*
   * Create folder batch.
   *)

  module CreateFolderBatch = struct
    module Arg = Protocol.CreateFolderBatchArg
    module Result = Protocol.CreateFolderBatchLaunch
    module Error = Error.Make (Error.Void)

    module Info = struct
      let uri = Root.api "/files/create_folder_batch"
    end

    module Fn = RemoteProcedureCall.Function (C) (Arg) (Result) (Error) (Info)
  end

  let create_folder_batch ~session ?(autorename = false) ?(force_async = false)
      paths =
    let request = CreateFolderBatch.Arg.Type.{paths; autorename; force_async}
    and headers = Session.headers session in
    CreateFolderBatch.Fn.call ~headers request

  (*
   * Create folder batch check.
   *)

  module CreateFolderBatchCheck = struct
    module Arg = Protocol.PollArg
    module Result = Protocol.CreateFolderBatchJobStatus
    module Error = Error.Make (Protocol.PollError)

    module Info = struct
      let uri = Root.api "/files/create_folder_batch/check"
    end

    module Fn = RemoteProcedureCall.Function (C) (Arg) (Result) (Error) (Info)
  end

  let create_folder_batch_check ~session async_job_id =
    let request = CreateFolderBatchCheck.Arg.Type.{async_job_id}
    and headers = Session.headers session in
    CreateFolderBatchCheck.Fn.call ~headers request

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

  let delete ~session ?parent_rev path =
    let request = Delete.Arg.Type.{path; parent_rev}
    and headers = Session.headers session in
    Delete.Fn.call ~headers request

  (*
   * Delete batch.
   *)

  module DeleteBatch = struct
    module Arg = Protocol.DeleteBatchArg
    module Result = Protocol.DeleteBatchLaunch
    module Error = Error.Make (Error.Void)

    module Info = struct
      let uri = Root.api "/files/delete_batch"
    end

    module Fn = RemoteProcedureCall.Function (C) (Arg) (Result) (Error) (Info)
  end

  let delete_batch ~session entries =
    let request = DeleteBatch.Arg.Type.{entries}
    and headers = Session.headers session in
    DeleteBatch.Fn.call ~headers request

  (*
   * Delete batch check.
   *)

  module DeleteBatchCheck = struct
    module Arg = Protocol.PollArg
    module Result = Protocol.DeleteBatchJobStatus
    module Error = Error.Make (Protocol.PollError)

    module Info = struct
      let uri = Root.api "/files/delete_batch/check"
    end

    module Fn = RemoteProcedureCall.Function (C) (Arg) (Result) (Error) (Info)
  end

  let delete_batch_check ~session async_job_id =
    let request = DeleteBatchCheck.Arg.Type.{async_job_id}
    and headers = Session.headers session in
    DeleteBatchCheck.Fn.call ~headers request

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

  module Export = struct
    module Arg = Protocol.ExportArg
    module Result = Protocol.ExportResult
    module Error = Error.Make (Protocol.ExportError)

    module Info = struct
      let uri = Root.content "/files/export"
    end

    module Fn = RemoteProcedureCall.Function (C) (Arg) (Result) (Error) (Info)
  end

  let export ~session path =
    let request = Export.Arg.Type.{path}
    and headers = Session.headers session in
    Export.Fn.call ~headers request

  (*
   * Get file lock batch.
   *)

  module GetFileLockBatch = struct
    module Arg = Protocol.LockFileBatchArg
    module Result = Protocol.LockFileBatchResult
    module Error = Error.Make (Protocol.LockFileError)

    module Info = struct
      let uri = Root.api "/files/get_file_lock_batch"
    end

    module Fn = RemoteProcedureCall.Function (C) (Arg) (Result) (Error) (Info)
  end

  let get_file_lock_batch ~session entries =
    let request = GetFileLockBatch.Arg.Type.{entries}
    and headers = Session.headers session in
    GetFileLockBatch.Fn.call ~headers request

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

  module GetPreview = struct
    module Arg = Protocol.PreviewArg
    module Result = Protocol.FileMetadata
    module Error = Error.Make (Protocol.PreviewError)

    module Info = struct
      let uri = Root.content "/files/get_preview"
    end

    module Fn = ContentDownload.Function (C) (Arg) (Result) (Error) (Info)
  end

  let get_preview ~session ?rev path =
    let headers = Session.headers session in
    GetPreview.Fn.call ~headers {path; rev}

  (*
   * Get temporary link.
   *)

  module GetTemporaryLink = struct
    module Arg = Protocol.GetTemporaryLinkArg
    module Result = Protocol.GetTemporaryLinkResult
    module Error = Error.Make (Protocol.GetTemporaryLinkError)

    module Info = struct
      let uri = Root.api "/files/get_temporary_link"
    end

    module Fn = RemoteProcedureCall.Function (C) (Arg) (Result) (Error) (Info)
  end

  let get_temporary_link ~session path =
    let headers = Session.headers session in
    GetTemporaryLink.Fn.call ~headers {path}

  (*
   * Get temporary upload link.
   *)

  module GetTemporaryLinkUpload = struct
    module Arg = Protocol.GetTemporaryUpoadLinkArg
    module Result = Protocol.GetTemporaryUpoadLinkResult
    module Error = Error.Make (Error.Void)

    module Info = struct
      let uri = Root.api "/files/get_temporary_upload_link"
    end

    module Fn = RemoteProcedureCall.Function (C) (Arg) (Result) (Error) (Info)
  end

  let get_temporary_upload_link ~session commit_info duration =
    let headers = Session.headers session in
    GetTemporaryLinkUpload.Fn.call ~headers {commit_info; duration}

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

  module GetThumbnailBatch = struct
    module Arg = Protocol.GetThumbnailBatchArg
    module Result = Protocol.GetThumbnailBatchResult
    module Error = Error.Make (Protocol.GetThumbnailBatchError)

    module Info = struct
      let uri = Root.api "/files/get_thumbnail_batch"
    end

    module Fn = RemoteProcedureCall.Function (C) (Arg) (Result) (Error) (Info)
  end

  let get_thumbnail_batch ~session entries =
    let headers = Session.headers session in
    GetThumbnailBatch.Fn.call ~headers {entries}

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

  module ListFolderGetLastCursor = struct
    module Arg = Protocol.ListFolderArg
    module Result = Protocol.ListFolderGetLastCursorResult
    module Error = Error.Make (Protocol.ListFolderError)

    module Info = struct
      let uri = Root.api "/files/list_folder/get_latest_cursor"
    end

    module Fn = RemoteProcedureCall.Function (C) (Arg) (Result) (Error) (Info)
  end

  let list_folder_get_latest_cursor ~session path =
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
    ListFolderGetLastCursor.Fn.call ~headers arg

  (*
   * List folder long poll.
   *)

  module ListFolderLongPoll = struct
    module Arg = Protocol.ListFolderLongPollArg
    module Result = Protocol.ListFolderLongPollResult
    module Error = Error.Make (Protocol.ListFolderLongPollError)

    module Info = struct
      let uri = Root.api "/files/list_folder/longpoll"
    end

    module Fn = RemoteProcedureCall.Function (C) (Arg) (Result) (Error) (Info)
  end

  let list_folder_longpoll ~session cursor timeout =
    let headers = Session.headers session in
    ListFolderLongPoll.Fn.call ~headers {cursor; timeout}

  (*
   * List revisions.
   *)

  module ListRevisions = struct
    module Arg = Protocol.ListRevisionsArg
    module Result = Protocol.ListRevisionsResult
    module Error = Error.Make (Protocol.ListRevisionsError)

    module Info = struct
      let uri = Root.api "/files/list_revisions"
    end

    module Fn = RemoteProcedureCall.Function (C) (Arg) (Result) (Error) (Info)
  end

  let list_revisions ~session path mode limit =
    let headers = Session.headers session in
    ListRevisions.Fn.call ~headers {path; mode; limit}

  (*
   * Lock file batch.
   *)

  module LockFileBatch = struct
    module Arg = Protocol.LockFileBatchArg
    module Result = Protocol.LockFileBatchResult
    module Error = Error.Make (Protocol.LockFileError)

    module Info = struct
      let uri = Root.api "/files/lock_file_batch"
    end

    module Fn = RemoteProcedureCall.Function (C) (Arg) (Result) (Error) (Info)
  end

  let lock_file_batch ~session entries =
    let headers = Session.headers session in
    LockFileBatch.Fn.call ~headers {entries}

  (*
   * Move.
   *)

  module Move = struct
    module Arg = Protocol.RelocationArg
    module Result = Protocol.RelocationResult
    module Error = Error.Make (Protocol.RelocationError)

    module Info = struct
      let uri = Root.api "/files/move_v2"
    end

    module Fn = RemoteProcedureCall.Function (C) (Arg) (Result) (Error) (Info)
  end

  let move ~session ?(autorename = false) ?(allow_ownership_transfer = false)
      from_path to_path =
    let headers = Session.headers session in
    Move.Fn.call ~headers
      { from_path
      ; to_path
      ; allow_shared_folder = false
      ; autorename
      ; allow_ownership_transfer }

  (*
   * Move batch.
   *)

  module MoveBatch = struct
    module Arg = Protocol.MoveBatchArg
    module Result = Protocol.RelocationBatchV2Launch
    module Error = Error.Make (Error.Void)

    module Info = struct
      let uri = Root.api "/files/move_batch_v2"
    end

    module Fn = RemoteProcedureCall.Function (C) (Arg) (Result) (Error) (Info)
  end

  let move_batch ~session ?(autorename = false)
      ?(allow_ownership_transfer = false) entries =
    let headers = Session.headers session in
    MoveBatch.Fn.call ~headers {entries; autorename; allow_ownership_transfer}

  (*
   * Move batch check.
   *)

  module MoveBatchCheck = struct
    module Arg = Protocol.PollArg
    module Result = Protocol.RelocationBatchV2JobStatus
    module Error = Error.Make (Protocol.PollError)

    module Info = struct
      let uri = Root.api "/files/move_batch/check_v2"
    end

    module Fn = RemoteProcedureCall.Function (C) (Arg) (Result) (Error) (Info)
  end

  let move_batch_check ~session async_job_id =
    let headers = Session.headers session in
    MoveBatchCheck.Fn.call ~headers {async_job_id}

  (*
   * Permanently delete.
   *)

  module PermanentlyDelete = struct
    module Arg = Protocol.DeleteArg
    module Error = Error.Make (Protocol.DeleteError)

    module Info = struct
      let uri = Root.api "/files/permanently_delete"
    end

    module Fn = RemoteProcedureCall.Provider (C) (Arg) (Error) (Info)
  end

  let permanently_delete ~session ?parent_rev path =
    let headers = Session.headers session in
    PermanentlyDelete.Fn.call ~headers {path; parent_rev}

  (*
   * Restore.
   *)

  module Restore = struct
    module Arg = Protocol.RestoreArg
    module Result = Protocol.FileMetadata
    module Error = Error.Make (Protocol.RestoreError)

    module Info = struct
      let uri = Root.api "/files/restore"
    end

    module Fn = RemoteProcedureCall.Function (C) (Arg) (Result) (Error) (Info)
  end

  let restore ~session path rev =
    let headers = Session.headers session in
    Restore.Fn.call ~headers {path; rev}

  (*
   * Save URL.
   *)

  module SaveUrl = struct
    module Arg = Protocol.SaveUrlArg
    module Result = Protocol.SaveUrlResult
    module Error = Error.Make (Protocol.SaveUrlError)

    module Info = struct
      let uri = Root.api "/files/save_url"
    end

    module Fn = RemoteProcedureCall.Function (C) (Arg) (Result) (Error) (Info)
  end

  let save_url ~session path url =
    let headers = Session.headers session in
    SaveUrl.Fn.call ~headers {path; url}

  (*
   * Save URL check job status.
   *)

  module SaveUrlCheckJobStatus = struct
    module Arg = Protocol.PollArg
    module Result = Protocol.SaveUrlJobStatus
    module Error = Error.Make (Protocol.PollError)

    module Info = struct
      let uri = Root.api "/files/save_url/check_job_status"
    end

    module Fn = RemoteProcedureCall.Function (C) (Arg) (Result) (Error) (Info)
  end

  let save_url_check_job_status ~session async_job_id =
    let headers = Session.headers session in
    SaveUrlCheckJobStatus.Fn.call ~headers {async_job_id}

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

  module UnlockFileBatch = struct
    module Arg = Protocol.UnlockFileBatchArg
    module Result = Protocol.LockFileBatchResult
    module Error = Error.Make (Protocol.LockFileError)

    module Info = struct
      let uri = Root.api "/files/unlock_file_batch"
    end

    module Fn = RemoteProcedureCall.Function (C) (Arg) (Result) (Error) (Info)
  end

  let unlock_file_batch ~session entries =
    let headers = Session.headers session in
    UnlockFileBatch.Fn.call ~headers {entries}

  (*
   * Upload.
   *)

  module Upload = struct
    module Arg = Protocol.CommitInfo
    module Result = Protocol.FileMetadata
    module Error = Error.Make (Protocol.UploadError)

    module Info = struct
      let uri = Root.content "/files/upload"
    end

    module Fn = ContentUpload.Function (C) (Arg) (Result) (Error) (Info)
  end

  let upload ~session commit_info payload =
    let headers = Session.headers session in
    Upload.Fn.call ~headers commit_info payload

  (*
   * Upload session start.
   *)

  module UploadSessionStart = struct
    module Arg = Protocol.UploadSessionStartArg
    module Result = Protocol.UploadSessionStartResult
    module Error = Error.Make (Error.Void)

    module Info = struct
      let uri = Root.content "/files/upload_session/start"
    end

    module Fn = ContentUpload.Function (C) (Arg) (Result) (Error) (Info)
  end

  let upload_session_start ~session ?(close = false) payload =
    let headers = Session.headers session in
    UploadSessionStart.Fn.call ~headers {close} payload

  (*
   * Upload session append.
   *)

  module UploadSessionAppend = struct
    module Arg = Protocol.UploadSessionAppendArg
    module Error = Error.Make (Protocol.UploadSessionLookupError)

    module Info = struct
      let uri = Root.content "/files/upload_session/append_v2"
    end

    module Fn = ContentUpload.Provider (C) (Arg) (Error) (Info)
  end

  let upload_session_append ~session ?(close = false) cursor payload =
    let headers = Session.headers session in
    UploadSessionAppend.Fn.call ~headers {cursor; close} payload

  (*
   * Upload session finish.
   *)

  module UploadSessionFinish = struct
    module Arg = Protocol.UploadSessionFinishArg
    module Result = Protocol.FileMetadata
    module Error = Error.Make (Protocol.UploadSessionFinishError)

    module Info = struct
      let uri = Root.content "/files/upload_session/finish"
    end

    module Fn = ContentUpload.Function (C) (Arg) (Result) (Error) (Info)
  end

  let upload_session_finish ~session cursor commit payload =
    let headers = Session.headers session in
    UploadSessionFinish.Fn.call ~headers {cursor; commit} payload

  (*
   * Upload session finish batch.
   *)

  module UploadSessionFinishBatch = struct
    module Arg = Protocol.UploadSessionFinishBatchArg
    module Result = Protocol.UploadSessionFinishBatchLaunch
    module Error = Error.Make (Error.Void)

    module Info = struct
      let uri = Root.api "/files/upload_session/finish_batch"
    end

    module Fn = RemoteProcedureCall.Function (C) (Arg) (Result) (Error) (Info)
  end

  let upload_session_finish_batch ~session entries =
    let headers = Session.headers session in
    UploadSessionFinishBatch.Fn.call ~headers {entries}

  (*
   * Upload session finish batch check.
   *)

  module UploadSessionFinishBatchCheck = struct
    module Arg = Protocol.PollArg
    module Result = Protocol.UploadSessionFinishBatchJobStatus
    module Error = Error.Make (Protocol.PollError)

    module Info = struct
      let uri = Root.api "/files/upload_session/finish_batch/check"
    end

    module Fn = RemoteProcedureCall.Function (C) (Arg) (Result) (Error) (Info)
  end

  let upload_session_finish_batch_check ~session async_job_id =
    let headers = Session.headers session in
    UploadSessionFinishBatchCheck.Fn.call ~headers {async_job_id}
end
