open Endpoint

module Make (C : Cohttp_lwt.S.Client) = struct
  (*
   * Add file member.
   *)

  let add_file_member_uri = Root.api "/sharing/add_file_member"

  let add_file_member (_ : Session.Type.t) =
    let module Error = Error.Make (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Add folder member.
   *)

  let add_folder_member_uri = Root.api "/sharing/add_folder_member"

  let add_folder_member (_ : Session.Type.t) =
    let module Error = Error.Make (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Check job status.
   *)

  let check_job_status_uri = Root.api "/sharing/check_job_status"

  let check_job_status (_ : Session.Type.t) =
    let module Error = Error.Make (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Check remove member job status.
   *)

  let check_remove_member_job_status_uri =
    Root.api "/sharing/check_remove_member_job_status"

  let check_remove_member_job_status (_ : Session.Type.t) =
    let module Error = Error.Make (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Check share job status.
   *)

  let check_share_job_status_uri = Root.api "/sharing/check_share_job_status"

  let check_share_job_status (_ : Session.Type.t) =
    let module Error = Error.Make (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Create shared link with settings.
   *)

  let create_shared_link_with_settings_uri =
    Root.api "/sharing/create_shared_link_with_settings"

  let create_shared_link_with_settings (_ : Session.Type.t) =
    let module Error = Error.Make (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Get file metadata.
   *)

  let get_file_metadata_uri = Root.api "/sharing/get_file_metadata"

  let get_file_metadata (_ : Session.Type.t) =
    let module Error = Error.Make (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Get file metadata/batch.
   *)

  let get_file_metadata_batch_uri = Root.api "/sharing/get_file_metadata/batch"

  let get_file_metadata_batch (_ : Session.Type.t) =
    let module Error = Error.Make (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Get folder metadata.
   *)

  let get_folder_metadata_uri = Root.api "/sharing/get_folder_metadata"

  let get_folder_metadata (_ : Session.Type.t) =
    let module Error = Error.Make (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Get shared link file.
   *)

  let get_shared_link_file_uri = Root.api "/sharing/get_shared_link_file"

  let get_shared_link_file (_ : Session.Type.t) =
    let module Error = Error.Make (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Get shared link metadata.
   *)

  let get_shared_link_metadata_uri =
    Root.api "/sharing/get_shared_link_metadata"

  let get_shared_link_metadata (_ : Session.Type.t) =
    let module Error = Error.Make (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * list file members.
   *)

  let list_file_members_uri = Root.api "/sharing/list_file_members"

  let list_file_members (_ : Session.Type.t) =
    let module Error = Error.Make (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * List file members, batch.
   *)

  let list_file_members_batch_uri = Root.api "/sharing/list_file_members/batch"

  let list_file_members_batch (_ : Session.Type.t) =
    let module Error = Error.Make (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * List file members, continue.
   *)

  let list_file_members_continue_uri =
    Root.api "/sharing/list_file_members/continue"

  let list_file_members_continue (_ : Session.Type.t) =
    let module Error = Error.Make (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * List folder members.
   *)

  let list_folder_members_uri = Root.api "/sharing/list_folder_members"

  let list_folder_members (_ : Session.Type.t) =
    let module Error = Error.Make (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * List folder members, continue.
   *)

  let list_folder_members_continue_uri =
    Root.api "/sharing/list_folder_members/continue"

  let list_folder_members_continue (_ : Session.Type.t) =
    let module Error = Error.Make (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * List folders.
   *)

  let list_folders_uri = Root.api "/sharing/list_folders"

  let list_folders (_ : Session.Type.t) =
    let module Error = Error.Make (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * List folders, continue.
   *)

  let list_folders_continue_uri = Root.api "/sharing/list_folders/continue"

  let list_folders_continue (_ : Session.Type.t) =
    let module Error = Error.Make (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * List mountable folders.
   *)

  let list_mountable_folders_uri = Root.api "/sharing/list_mountable_folders"

  let list_mountable_folders (_ : Session.Type.t) =
    let module Error = Error.Make (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * List mountable folders, continue.
   *)

  let list_mountable_folders_continue_uri =
    Root.api "/sharing/list_mountable_folders/continue"

  let list_mountable_folders_continue (_ : Session.Type.t) =
    let module Error = Error.Make (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * List received files.
   *)

  let list_received_files_uri = Root.api "/sharing/list_received_files"

  let list_received_files (_ : Session.Type.t) =
    let module Error = Error.Make (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * List received files, continue.
   *)

  let list_received_files_continue_uri =
    Root.api "/sharing/list_received_files/continue"

  let list_received_files_continue (_ : Session.Type.t) =
    let module Error = Error.Make (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * List shared links.
   *)

  let list_shared_links_uri = Root.api "/sharing/list_shared_links"

  let list_shared_links (_ : Session.Type.t) =
    let module Error = Error.Make (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Modify shared link settings.
   *)

  let modify_shared_link_settings_uri =
    Root.api "/sharing/modify_shared_link_settings"

  let modify_shared_link_settings (_ : Session.Type.t) =
    let module Error = Error.Make (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Mount folder.
   *)

  let mount_folder_uri = Root.api "/sharing/mount_folder"

  let mount_folder (_ : Session.Type.t) =
    let module Error = Error.Make (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Relinquish file membership.
   *)

  let relinquish_file_membership_uri =
    Root.api "/sharing/relinquish_file_membership"

  let relinquish_file_membership (_ : Session.Type.t) =
    let module Error = Error.Make (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Relinquish folder membership.
   *)

  let relinquish_folder_membership_uri =
    Root.api "/sharing/relinquish_folder_membership"

  let relinquish_folder_membership (_ : Session.Type.t) =
    let module Error = Error.Make (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Remove file member 2.
   *)

  let remove_file_member_2_uri = Root.api "/sharing/remove_file_member_2"

  let remove_file_member_2 (_ : Session.Type.t) =
    let module Error = Error.Make (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Remove folder member.
   *)

  let remove_folder_member_uri = Root.api "/sharing/remove_folder_member"

  let remove_folder_member (_ : Session.Type.t) =
    let module Error = Error.Make (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Revoke shared link.
   *)

  let revoke_shared_link_uri = Root.api "/sharing/revoke_shared_link"

  let revoke_shared_link (_ : Session.Type.t) =
    let module Error = Error.Make (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Set access inheritance.
   *)

  let set_access_inheritance_uri = Root.api "/sharing/set_access_inheritance"

  let set_access_inheritance (_ : Session.Type.t) =
    let module Error = Error.Make (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Share folder.
   *)

  let share_folder_uri = Root.api "/sharing/share_folder"

  let share_folder (_ : Session.Type.t) =
    let module Error = Error.Make (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Transfer folder.
   *)

  let transfer_folder_uri = Root.api "/sharing/transfer_folder"

  let transfer_folder (_ : Session.Type.t) =
    let module Error = Error.Make (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Unmount folder.
   *)

  let unmount_folder_uri = Root.api "/sharing/unmount_folder"

  let unmount_folder (_ : Session.Type.t) =
    let module Error = Error.Make (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Unshare file.
   *)

  let unshare_file_uri = Root.api "/sharing/unshare_file"

  let unshare_file (_ : Session.Type.t) =
    let module Error = Error.Make (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Unshare folder.
   *)

  let unshare_folder_uri = Root.api "/sharing/unshare_folder"

  let unshare_folder (_ : Session.Type.t) =
    let module Error = Error.Make (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Update file member.
   *)

  let update_file_member_uri = Root.api "/sharing/update_file_member"

  let update_file_member (_ : Session.Type.t) =
    let module Error = Error.Make (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Update folder member.
   *)

  let update_folder_member_uri = Root.api "/sharing/update_folder_member"

  let update_folder_member (_ : Session.Type.t) =
    let module Error = Error.Make (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Update folder policy.
   *)

  let update_folder_policy_uri = Root.api "/sharing/update_folder_policy"

  let update_folder_policy (_ : Session.Type.t) =
    let module Error = Error.Make (Error.Void) in
    Lwt.return_error Error.Not_implemented
end
