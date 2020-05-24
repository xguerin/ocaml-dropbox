module Tagged = struct
  module Type = struct
    type t = {tag : string [@key ".tag"]} [@@deriving yojson]
  end

  module Json = Json.S (Type)
end
