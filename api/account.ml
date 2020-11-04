open Endpoint

module Make (C : Cohttp_lwt.S.Client) = struct
  (*
   * Protocol.
   *)

  module Protocol = struct
    module PhotoSourceArg = struct
      module Type = struct
        type t = Base64_data of string [@@deriving dropbox, show]
      end

      module Json = Json.Make (Type)
    end

    module SetProfilePhotoArg = struct
      module Type = struct
        type t = {photo : PhotoSourceArg.Type.t} [@@deriving yojson, show]
      end

      module Json = Json.Make (Type)
    end

    module SetProfilePhotoResult = struct
      module Type = struct
        type t = {profile_photo_url : string} [@@deriving yojson, show]
      end

      module Json = Json.Make (Type)
    end

    module SetProfilePhotoError = struct
      module Type = struct
        type t =
          | File_type_error
          | File_size_error
          | Dimension_error
          | Thumbnail_error
          | Transient_error
        [@@deriving dropbox, show]
      end

      module Json = Json.Make (Type)
    end
  end

  (*
   * Set profile photo.
   *)

  module SetProfilePhoto = struct
    module Arg = Protocol.SetProfilePhotoArg
    module Result = Protocol.SetProfilePhotoResult
    module Error = Error.Make (Protocol.SetProfilePhotoError)

    module Info = struct
      let uri = Root.api "/account/set_profile_photo"
    end

    module Fn = RemoteProcedureCall.Function (C) (Arg) (Result) (Error) (Info)
  end

  let set_profile_photo ~session data =
    let request = SetProfilePhoto.Arg.Type.{photo = Base64_data data}
    and headers = Session.headers session in
    let module Error = Error.Make (Error.Void) in
    SetProfilePhoto.Fn.call ~headers request
end
