module A = struct
  module Type = struct
    type t =
      | Basic
      | String of string
      | StringList of string list
      | StringOption of string option
    [@@deriving dropbox]
  end
end

module B = struct
  module Type = struct
    type t =
      | Module of A.Type.t
      | ModuleOption of A.Type.t option
    [@@deriving dropbox]
  end
end
