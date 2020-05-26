open Endpoint

module S (Client : Cohttp_lwt.S.Client) = struct
  (*
   * Properties add.
   *)

  let properties_add_uri = Root.api "/file_properties/properties/add"

  let properties_add (_ : Session.Type.t) =
    let module Error = Error.S (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Properties overwrite.
   *)

  let properties_overwrite_uri =
    Root.api "/file_properties/properties/overwrite"

  let properties_overwrite (_ : Session.Type.t) =
    let module Error = Error.S (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Properties remove.
   *)

  let properties_remove_uri = Root.api "/file_properties/properties/remove"

  let properties_remove (_ : Session.Type.t) =
    let module Error = Error.S (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Properties search.
   *)

  let properties_search_uri = Root.api "/file_properties/properties/search"

  let properties_search (_ : Session.Type.t) =
    let module Error = Error.S (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Properties search continue.
   *)

  let properties_search_continue_uri =
    Root.api "/file_properties/properties/search/continue"

  let properties_search_continue (_ : Session.Type.t) =
    let module Error = Error.S (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Properties update.
   *)

  let properties_update_uri = Root.api "/file_properties/properties/update"

  let properties_update (_ : Session.Type.t) =
    let module Error = Error.S (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Templates add for user.
   *)

  let templates_add_for_user_uri =
    Root.api "/file_properties/templates/add_for_user"

  let templates_add_for_user (_ : Session.Type.t) =
    let module Error = Error.S (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Templates get for user.
   *)

  let templates_get_for_user_uri =
    Root.api "/file_properties/templates/get_for_user"

  let templates_get_for_user (_ : Session.Type.t) =
    let module Error = Error.S (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Templates list for user.
   *)

  let templates_list_for_user_uri =
    Root.api "/file_properties/templates/list_for_user"

  let templates_list_for_user (_ : Session.Type.t) =
    let module Error = Error.S (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Templates remove for user.
   *)

  let templates_remove_for_user_uri =
    Root.api "/file_properties/templates/remove_for_user"

  let templates_remove_for_user (_ : Session.Type.t) =
    let module Error = Error.S (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Templates update for user.
   *)

  let templates_update_for_user_uri =
    Root.api "/file_properties/templates/update_for_user"

  let templates_update_for_user (_ : Session.Type.t) =
    let module Error = Error.S (Error.Void) in
    Lwt.return_error Error.Not_implemented
end
