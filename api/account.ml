open Endpoint

module S (C : Cohttp_lwt.S.Client) = struct
  let set_profile_photo_uri = Root.api "/account/set_profile_photo"

  let set_profile_photo (_ : Session.Type.t) =
    Lwt.return_error Error.Not_implemented
end
