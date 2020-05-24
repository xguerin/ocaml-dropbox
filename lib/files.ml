open Api

module S (Client : Cohttp_lwt.S.Client) = struct
  (*
   * Copy.
   *)

  let copy_uri = Root.api "/files/copy_v2"
  let copy (_ : Session.Type.t) = Lwt.return_error Error.Not_implemented

  (*
   * Copy batch.
   *)

  let copy_batch_uri = Root.api "/files/copy_batch_v2"
  let copy_batch (_ : Session.Type.t) = Lwt.return_error Error.Not_implemented

  (*
   * Copy batch check.
   *)

  let copy_batch_check_uri = Root.api "/files/copy_batch/check_v2"

  let copy_batch_check (_ : Session.Type.t) =
    Lwt.return_error Error.Not_implemented

  (*
   * Copy reference get.
   *)

  let copy_reference_get_uri = Root.api "/files/copy_reference/get"

  let copy_reference_get (_ : Session.Type.t) =
    Lwt.return_error Error.Not_implemented

  (*
   * Copy reference save.
   *)

  let copy_reference_save_uri = Root.api "/files/copy_reference/save"

  let copy_reference_save (_ : Session.Type.t) =
    Lwt.return_error Error.Not_implemented

  (*
   * Create folder.
   *)
  let create_folder_uri = Root.api "/files/create_folder_v2"

  let create_folder (_ : Session.Type.t) =
    Lwt.return_error Error.Not_implemented

  (*
   * Create folder batch.
   *)

  let create_folder_batch_uri = Root.api "/files/create_folder_batch"

  let create_folder_batch (_ : Session.Type.t) =
    Lwt.return_error Error.Not_implemented

  (*
   * Create folder batch check.
   *)

  let create_folder_batch_check_uri =
    Root.api "/files/create_folder_batch/check"

  let create_folder_batch_check (_ : Session.Type.t) =
    Lwt.return_error Error.Not_implemented

  (*
   * Delete.
   *)

  let delete_uri = Root.api "/files/delete_v2"
  let delete (_ : Session.Type.t) = Lwt.return_error Error.Not_implemented

  (*
   * Delete batch.
   *)

  let delete_batch_uri = Root.api "/files/delete_batch"
  let delete_batch (_ : Session.Type.t) = Lwt.return_error Error.Not_implemented

  (*
   * Delete batch check.
   *)

  let delete_batch_check_uri = Root.api "/files/delete_batch/check"

  let delete_batch_check (_ : Session.Type.t) =
    Lwt.return_error Error.Not_implemented

  (*
   * Download.
   *)

  let download_uri = Root.content "/files/download"
  let download (_ : Session.Type.t) = Lwt.return_error Error.Not_implemented

  (*
   * Download zip.
   *)

  let download_zip_uri = Root.content "/files/download_zip"
  let download_zip (_ : Session.Type.t) = Lwt.return_error Error.Not_implemented

  (*
   * Export.
   *)

  let export_uri = Root.content "/files/export"
  let export (_ : Session.Type.t) = Lwt.return_error Error.Not_implemented

  (*
   * Get file lock batch.
   *)

  let get_file_lock_batch_uri = Root.api "/files/get_file_lock_batch"

  let get_file_lock_batch (_ : Session.Type.t) =
    Lwt.return_error Error.Not_implemented

  (*
   * Get metadata.
   *)

  let get_metadata_uri = Root.api "/files/get_metadata"
  let get_metadata (_ : Session.Type.t) = Lwt.return_error Error.Not_implemented

  (*
   * Get preview.
   *)

  let get_preview_uri = Root.content "/files/get_preview"
  let get_preview (_ : Session.Type.t) = Lwt.return_error Error.Not_implemented

  (*
   * Get temporary link.
   *)

  let get_temporary_link_uri = Root.api "/files/get_temporary_link"

  let get_temporary_link (_ : Session.Type.t) =
    Lwt.return_error Error.Not_implemented

  (*
   * Get temporary upload link.
   *)

  let get_temporary_upload_link_uri =
    Root.api "/files/get_temporary_upload_link"

  let get_temporary_upload_link (_ : Session.Type.t) =
    Lwt.return_error Error.Not_implemented

  (*
   * Get thumbnail.
   *)

  let get_thumbnail_uri = Root.content "/files/get_thumbnail_v2"

  let get_thumbnail (_ : Session.Type.t) =
    Lwt.return_error Error.Not_implemented

  (*
   * Get thumbnail batch.
   *)

  let get_thumbnail_batch_uri = Root.content "/files/get_thumbnail_batch"

  let get_thumbnail_batch (_ : Session.Type.t) =
    Lwt.return_error Error.Not_implemented

  (*
   * List folder.
   *)

  let list_folder_uri = Root.api "/files/list_folder"
  let list_folder (_ : Session.Type.t) = Lwt.return_error Error.Not_implemented

  (*
   * List folder continue.
   *)

  let list_folder_continue_uri = Root.api "/files/list_folder/continue"

  let list_folder_continue (_ : Session.Type.t) =
    Lwt.return_error Error.Not_implemented

  (*
   * List folder get latest cursor.
   *)

  let list_folder_get_latest_cursor_uri =
    Root.api "/files/list_folder/get_latest_cursor"

  let list_folder_get_latest_cursor (_ : Session.Type.t) =
    Lwt.return_error Error.Not_implemented

  (*
   * List folder long poll.
   *)

  let list_folder_longpoll_uri = Root.api "/files/list_folder/longpoll"

  let list_folder_longpoll (_ : Session.Type.t) =
    Lwt.return_error Error.Not_implemented

  (*
   * List revisions.
   *)

  let list_revisions_uri = Root.api "/files/list_revisions"

  let list_revisions (_ : Session.Type.t) =
    Lwt.return_error Error.Not_implemented

  (*
   * Lock file batch.
   *)

  let lock_file_batch_uri = Root.api "/files/lock_file_batch"

  let lock_file_batch (_ : Session.Type.t) =
    Lwt.return_error Error.Not_implemented

  (*
   * Move.
   *)

  let move_uri = Root.api "/files/move_v2"
  let move (_ : Session.Type.t) = Lwt.return_error Error.Not_implemented

  (*
   * Move batch.
   *)

  let move_batch_uri = Root.api "/files/move_batch_v2"
  let move_batch (_ : Session.Type.t) = Lwt.return_error Error.Not_implemented

  (*
   * Move batch check.
   *)

  let move_batch_check_uri = Root.api "/files/move_batch/check_v2"

  let move_batch_check (_ : Session.Type.t) =
    Lwt.return_error Error.Not_implemented

  (*
   * Permanently delete.
   *)

  let permanently_delete_uri = Root.api "/files/permanently_delete"

  let permanently_delete (_ : Session.Type.t) =
    Lwt.return_error Error.Not_implemented

  (*
   * Restore.
   *)

  let restore_uri = Root.api "/files/restore"
  let restore (_ : Session.Type.t) = Lwt.return_error Error.Not_implemented

  (*
   * Save URL.
   *)

  let save_url_uri = Root.api "/files/save_url"
  let save_url (_ : Session.Type.t) = Lwt.return_error Error.Not_implemented

  (*
   * Save URL check job status.
   *)

  let save_url_check_job_status_uri =
    Root.api "/files/save_url/check_job_status"

  let save_url_check_job_status (_ : Session.Type.t) =
    Lwt.return_error Error.Not_implemented

  (*
   * Search.
   *)

  let search_uri = Root.api "/files/search_v2"
  let search (_ : Session.Type.t) = Lwt.return_error Error.Not_implemented

  (*
   * Search continue.
   *)

  let search_continue_uri = Root.api "/files/search/continue_v2"

  let search_continue (_ : Session.Type.t) =
    Lwt.return_error Error.Not_implemented

  (*
   * Unlock file batch.
   *)

  let unlock_file_batch_uri = Root.api "/files/unlock_file_batch"

  let unlock_file_batch (_ : Session.Type.t) =
    Lwt.return_error Error.Not_implemented

  (*
   * Upload.
   *)

  let upload_uri = Root.content "/files/upload"
  let upload (_ : Session.Type.t) = Lwt.return_error Error.Not_implemented

  (*
   * Upload session start.
   *)

  let upload_session_start_uri = Root.content "/files/upload_session/start"

  let upload_session_start (_ : Session.Type.t) =
    Lwt.return_error Error.Not_implemented

  (*
   * Upload session append.
   *)

  let upload_session_append_uri = Root.content "/files/upload_session/append_v2"

  let upload_session_append (_ : Session.Type.t) =
    Lwt.return_error Error.Not_implemented

  (*
   * Upload session finish.
   *)

  let upload_session_finish_uri = Root.content "/files/upload_session/finish"

  let upload_session_finish (_ : Session.Type.t) =
    Lwt.return_error Error.Not_implemented

  (*
   * Upload session finish batch.
   *)

  let upload_session_finish_batch_uri =
    Root.api "/files/upload_session/finish_batch"

  let upload_session_finish_batch (_ : Session.Type.t) =
    Lwt.return_error Error.Not_implemented

  (*
   * Upload session finish batch check.
   *)

  let upload_session_finish_batch_check_uri =
    Root.api "/files/upload_session/finish_batch/check"

  let upload_session_finish_batch_check (_ : Session.Type.t) =
    Lwt.return_error Error.Not_implemented
end
