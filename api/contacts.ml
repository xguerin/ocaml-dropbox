open Endpoint

module S (C : Cohttp_lwt.S.Client) = struct
  let delete_manual_contacts_uri = Root.api "/contacts/delete_manual_contacts"

  let delete_manual_contacts (_ : Session.Type.t) =
    Lwt.return_error Error.Not_implemented

  let delete_manual_contacts_batch_uri =
    Root.api "/contacts/delete_manual_contacts_batch"

  let delete_manual_contacts_batch (_ : Session.Type.t) =
    Lwt.return_error Error.Not_implemented
end
