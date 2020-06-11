open Endpoint

module Make (C : Cohttp_lwt.S.Client) = struct
  let set_profile_photo_uri = Root.api "/account/set_profile_photo"

  let set_profile_photo (_ : Session.Type.t) =
    let module Error = Error.S (Error.Void) in
    Lwt.return_error Error.Not_implemented
end
