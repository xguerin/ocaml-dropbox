open Endpoint

module Make (C : Cohttp_lwt.S.Client) = struct
  (*
   * Protocol.
   *)

  module Protocol = struct
    module PhotoSourceArg = struct
      module Type = struct
        type t = Base64_data of string [@@deriving dropbox]
      end

      module Json = Json.Make (Type)
    end

    module SetProfilePhotoArg = struct
      module Type = struct
        type t = {photo : PhotoSourceArg.Type.t} [@@deriving yojson]
      end

      module Json = Json.Make (Type)
    end

    module SetProfilePhotoResult = struct
      module Type = struct
        type t = {profile_photo_url : string} [@@deriving yojson]
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
        [@@deriving dropbox]
      end

      module Json = Json.Make (Type)

      let to_string = function
        | Type.File_type_error -> "File type error"
        | Type.File_size_error -> "File size error"
        | Type.Dimension_error -> "Dimension error"
        | Type.Thumbnail_error -> "Thumbnail error"
        | Type.Transient_error -> "Transient error"
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
