open Api
open RemoteProcedureCall
open Infix

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

module S (C : Cohttp_lwt.S.Client) = struct
  open Protocol

  (*
   * Get account.
   *)

  let get_account_uri = Root.api "/users/get_account"
  let get_account (_ : Session.Type.t) = Lwt.return_error Error.Not_implemented

  (*
   * Get account batch.
   *)

  let get_account_batch_uri = Root.api "/users/get_account_batch"

  let get_account_batch (_ : Session.Type.t) =
    Lwt.return_error Error.Not_implemented

  (*
   * Get current account.
   *)

  module GetCurrentAccount = struct
    module Uri = struct
      let uri = Root.api "/users/get_current_account"
    end

    module Fn = Supplier (C) (Account) (Uri)
  end

  let get_current_account session =
    let get_info Account.Type.{name; _} = Lwt.return_ok name in
    let headers = Session.headers session in
    GetCurrentAccount.Fn.call ~headers () >>=? get_info

  (*
   * Get space usage.
   *)

  module GetSpaceUsage = struct
    module Uri = struct
      let uri = Root.api "/users/get_space_usage"
    end

    module Fn = Supplier (C) (SpaceUsage) (Uri)
  end

  let get_space_usage session =
    let get_info SpaceUsage.Type.{used; allocation = {allocated; _}} =
      Lwt.return_ok (used, allocated) in
    let headers = Session.headers session in
    GetSpaceUsage.Fn.call ~headers () >>=? get_info
end
