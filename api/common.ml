module Protocol = struct
  module LookupError = struct
    module Type = struct
      type t =
        | Malformed_path
        | Not_file
        | Not_folder
        | Not_found
        | Restricted_content
        | Unsupported_content_type
      [@@deriving dropbox]
    end

    module Json = Json.Make (Type)

    let to_string = function
      | Type.Malformed_path -> "Malformed path"
      | Type.Not_file -> "Not a file"
      | Type.Not_folder -> "Not a folder"
      | Type.Not_found -> "Not found"
      | Type.Restricted_content -> "Restricted content"
      | Type.Unsupported_content_type -> "Unsupported content type"
  end

  module PropertyType = struct
    module Type = struct
      type t = String [@@deriving dropbox]
    end

    module Json = Json.Make (Type)
  end

  module PropertyFieldTemplate = struct
    module Type = struct
      type t =
        { name : string
        ; description : string
        ; type_ : PropertyType.Type.t [@key "type"] }
      [@@deriving yojson]
    end

    module Json = Json.Make (Type)
  end

  module PropertyField = struct
    module Type = struct
      type t =
        { name : string
        ; value : string }
      [@@deriving yojson]
    end

    module Json = Json.Make (Type)
  end

  module PropertyGroup = struct
    module Type = struct
      type t =
        { template_id : string
        ; fields : PropertyField.Type.t list }
      [@@deriving yojson]
    end

    module Json = Json.Make (Type)
  end
end
