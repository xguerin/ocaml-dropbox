module Type = struct
  type t = {token : string} [@@deriving yojson]
end

let make token = Type.{token}

let headers Type.{token; _} =
  let value = "Bearer " ^ token in
  Cohttp.Header.init_with "Authorization" value

let pp ppf t =
  let str = Yojson.Safe.to_string @@ Type.to_yojson t in
  Format.pp_print_string ppf str
