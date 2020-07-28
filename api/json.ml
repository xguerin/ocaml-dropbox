module type Deriving = sig
  type t

  val to_yojson : t -> Yojson.Safe.t
  val of_yojson : Yojson.Safe.t -> t Ppx_deriving_yojson_runtime.error_or
end

module type S = sig
  type t

  val of_string : string -> (t, string) result
  val to_string : t -> string
end

module Make (D : Deriving) : S with type t = D.t = struct
  type t = D.t

  let of_string str = D.of_yojson @@ Yojson.Safe.from_string str
  let to_string t = Yojson.Safe.to_string @@ D.to_yojson t
end
