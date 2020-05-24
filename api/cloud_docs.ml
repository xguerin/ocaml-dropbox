open Endpoint

module S (C : Cohttp_lwt.S.Client) = struct
  let get_metadata_uri = Root.api "/cloud_docs/get_metadata"
  let get_metadata (_ : Session.Type.t) = Lwt.return_error Error.Not_implemented
  let lock_uri = Root.api "/cloud_docs/lock"
  let lock (_ : Session.Type.t) = Lwt.return_error Error.Not_implemented
  let rename_uri = Root.api "/cloud_docs/rename"
  let rename (_ : Session.Type.t) = Lwt.return_error Error.Not_implemented
  let unlock_uri = Root.api "/cloud_docs/unlock"
  let unlock (_ : Session.Type.t) = Lwt.return_error Error.Not_implemented
end
