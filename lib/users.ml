open Infix
open Lwt.Infix

module Protocol = struct
  module Name = struct
    module Type = struct
      type t =
        { given_name : string
        ; surname : string
        ; familiar_name : string
        ; display_name : string
        ; abbreviated_name : string }
      [@@deriving yojson]
    end

    module Json = Json.S (Type)
  end

  module Team = struct
    module Type = struct
      type sharing_policies =
        { shared_folder_member_policy : Protocol.Tagged.Type.t
        ; shared_folder_join_policy : Protocol.Tagged.Type.t
        ; shared_link_create_policy : Protocol.Tagged.Type.t }
      [@@deriving yojson]

      type t =
        { id : string
        ; name : string
        ; sharing_policies : sharing_policies
        ; office_addin_policies : Protocol.Tagged.Type.t }
      [@@deriving yojson]
    end

    module Json = Json.S (Type)
  end

  module Account = struct
    module Type = struct
      type root_info =
        { tag : string [@key ".tag"]
        ; root_namespace_id : string
        ; home_namespace_id : string }
      [@@deriving yojson]

      type t =
        { account_id : string
        ; name : Name.Type.t
        ; email : string
        ; email_verified : bool
        ; disabled : bool
        ; locale : string
        ; referral_link : string
        ; is_paired : bool
        ; account_type : Protocol.Tagged.Type.t
        ; root_info : root_info
        ; profile_photo_url : (string option[@default None])
        ; country : string
        ; team : (Team.Type.t option[@default None])
        ; team_member_id : (string option[@default None]) }
      [@@deriving yojson]
    end

    module Json = Json.S (Type)
  end

  module SpaceAllocation = struct
    module Type = struct
      type t =
        { tag : string [@key ".tag"]
        ; allocated : Int64.t
        ; user_within_team_space_allocated : (Int64.t option[@default None])
        ; user_within_team_space_limit_type : (Int64.t option[@default None])
        ; user_within_team_space_used_cached : (Int64.t option[@default None])
        }
      [@@deriving yojson]
    end

    module Json = Json.S (Type)
  end

  module SpaceUsage = struct
    module Type = struct
      type t =
        { used : Int64.t
        ; allocation : SpaceAllocation.Type.t }
      [@@deriving yojson]
    end

    module Json = Json.S (Type)
  end
end

module S (Client : Cohttp_lwt.S.Client) = struct
  open Cohttp_lwt
  open Protocol

  let get_account_uri =
    Uri.of_string "https://api.dropboxapi.com/2/users/get_account"

  let get_account (_ : Session.Type.t) =
    Lwt.return_error (Error.Not_implemented "get_account")

  let get_account_batch_uri =
    Uri.of_string "https://api.dropboxapi.com/2/users/get_account_batch"

  let get_account_batch (_ : Session.Type.t) =
    Lwt.return_error (Error.Not_implemented "get_account_batch")

  let get_current_account_uri =
    Uri.of_string "https://api.dropboxapi.com/2/users/get_current_account"

  let get_current_account session =
    let headers = Session.headers session in
    Client.post ~headers get_current_account_uri
    >>= Error.handle
    >>=? (fun (_, body) -> Body.to_string body >>= Account.Json.of_string)
    >>=? fun {name; _} -> Lwt.return_ok name

  let get_space_usage_uri =
    Uri.of_string "https://api.dropboxapi.com/2/users/get_space_usage"

  let get_space_usage session =
    let headers = Session.headers session in
    Client.post ~headers get_space_usage_uri
    >>= Error.handle
    >>=? (fun (_, body) -> Body.to_string body >>= SpaceUsage.Json.of_string)
    >>=? fun {used; allocation = {allocated; _}; _} ->
    Lwt.return_ok (used, allocated)
end
