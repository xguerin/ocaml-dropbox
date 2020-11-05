open Endpoint
open RemoteProcedureCall

module Make (C : Cohttp_lwt.S.Client) = struct
  (*
   * Protocol.
   *)

  module Protocol = struct
    module Name = struct
      module Type = struct
        type t =
          { given_name : string
          ; surname : string
          ; familiar_name : string
          ; display_name : string
          ; abbreviated_name : string }
        [@@deriving yojson, show]
      end

      module Json = Json.Make (Type)
    end

    module GetAccountArg = struct
      module Type = struct
        type t = {account_id : string} [@@deriving yojson, show]
      end

      module Json = Json.Make (Type)
    end

    module BasicAccount = struct
      module Type = struct
        type t =
          { account_id : string
          ; name : Name.Type.t
          ; email : string
          ; email_verified : bool
          ; disabled : bool
          ; is_teammate : bool
          ; profile_photo_url : string option
          ; team_member_id : string option }
        [@@deriving yojson, show]
      end

      module Json = Json.Make (Type)
    end

    module GetAccountError = struct
      module Type = struct
        type t = No_account [@@deriving dropbox, show]
      end

      module Json = Json.Make (Type)
    end

    module GetAccountBatchArg = struct
      module Type = struct
        type t = {account_ids : string list} [@@deriving yojson, show]
      end

      module Json = Json.Make (Type)
    end

    module GetAccountBatchResult = struct
      module Type = struct
        type t = BasicAccount.Type.t list [@@deriving yojson, show]
      end

      module Json = Json.Make (Type)
    end

    module GetAccountBatchError = struct
      module Type = struct
        type t = No_account of string [@@deriving dropbox, show]
      end

      module Json = Json.Make (Type)
    end

    module SharedFolderMemberPolicy = struct
      module Type = struct
        type t =
          | Anyone
          | Team
        [@@deriving dropbox, show]
      end

      module Json = Json.Make (Type)
    end

    module SharedFolderJoinPolicy = struct
      module Type = struct
        type t =
          | From_anyone
          | From_team_only
        [@@deriving dropbox, show]
      end

      module Json = Json.Make (Type)
    end

    module SharedLinkCreatePolicy = struct
      module Type = struct
        type t =
          | Default_public
          | Default_team_only
          | Team_only
        [@@deriving dropbox, show]
      end

      module Json = Json.Make (Type)
    end

    module TeamSharingPolicies = struct
      module Type = struct
        type t =
          { shared_folder_member_policy : SharedFolderMemberPolicy.Type.t
          ; shared_folder_join_policy : SharedFolderJoinPolicy.Type.t
          ; shared_link_create_policy : SharedLinkCreatePolicy.Type.t }
        [@@deriving yojson, show]
      end

      module Json = Json.Make (Type)
    end

    module OfficeAddinPolicy = struct
      module Type = struct
        type t =
          | Disabled
          | Enabled
        [@@deriving dropbox, show]
      end

      module Json = Json.Make (Type)
    end

    module FullTeam = struct
      module Type = struct
        type t =
          { id : string
          ; name : string
          ; sharing_policies : TeamSharingPolicies.Type.t
          ; office_addin_policies : OfficeAddinPolicy.Type.t }
        [@@deriving yojson, show]
      end

      module Json = Json.Make (Type)
    end

    module AccountType = struct
      module Type = struct
        type t =
          | Basic
          | Pro
          | Business
        [@@deriving dropbox, show]
      end

      module Json = Json.Make (Type)
    end

    module TeamRootInfo = struct
      module Type = struct
        type t =
          { root_namespace_id : string
          ; home_namespace_id : string
          ; home_path : string }
        [@@deriving yojson, show]
      end

      module Json = Json.Make (Type)
    end

    module UserRootInfo = struct
      module Type = struct
        type t =
          { root_namespace_id : string
          ; home_namespace_id : string }
        [@@deriving yojson, show]
      end

      module Json = Json.Make (Type)
    end

    module RootInfo = struct
      module Type = struct
        type t =
          | Team of TeamRootInfo.Type.t
          | User of UserRootInfo.Type.t
        [@@deriving dropbox {mode = SubType}, show]
      end
    end

    module Account = struct
      module Type = struct
        type t =
          { account_id : string
          ; name : Name.Type.t
          ; email : string
          ; email_verified : bool
          ; disabled : bool
          ; locale : string
          ; referral_link : string
          ; is_paired : bool
          ; account_type : AccountType.Type.t
          ; root_info : RootInfo.Type.t
          ; profile_photo_url : (string option[@default None])
          ; country : string
          ; team : (FullTeam.Type.t option[@default None])
          ; team_member_id : (string option[@default None]) }
        [@@deriving yojson, show]
      end

      module Json = Json.Make (Type)
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
        [@@deriving yojson, show]
      end

      module Json = Json.Make (Type)
    end

    module SpaceUsage = struct
      module Type = struct
        type t =
          { used : Int64.t
          ; allocation : SpaceAllocation.Type.t }
        [@@deriving yojson, show]
      end

      module Json = Json.Make (Type)
    end

    module UserFeature = struct
      module Type = struct
        type t =
          | Paper_as_files
          | File_locking
        [@@deriving dropbox, show]
      end

      module Json = Json.Make (Type)
    end

    module UserFeatureBatchArg = struct
      module Type = struct
        type t = {features : UserFeature.Type.t list} [@@deriving yojson, show]
      end

      module Json = Json.Make (Type)
    end

    module PaperAsFileValue = struct
      module Type = struct
        type t = Enabled of bool [@@deriving dropbox, show]
      end

      module Json = Json.Make (Type)
    end

    module FileLockingAsValue = struct
      module Type = struct
        type t = Enabled of bool [@@deriving dropbox, show]
      end

      module Json = Json.Make (Type)
    end
  end

  (*
   * Get account.
   *)

  module GetAccount = struct
    module Arg = Protocol.GetAccountArg
    module Result = Protocol.BasicAccount
    module Error = Error.Make (Protocol.GetAccountError)

    module Info = struct
      let uri = Root.api "/users/get_account"
    end

    module Fn = Function (C) (Arg) (Result) (Error) (Info)
  end

  let get_account ~session account_id =
    let headers = Session.headers session in
    GetAccount.Fn.call ~headers {account_id}

  (*
   * Get account batch.
   *)

  module GetAccountBatch = struct
    module Arg = Protocol.GetAccountBatchArg
    module Result = Protocol.GetAccountBatchResult
    module Error = Error.Make (Protocol.GetAccountBatchError)

    module Info = struct
      let uri = Root.api "/users/get_account_batch"
    end

    module Fn = Function (C) (Arg) (Result) (Error) (Info)
  end

  let get_account_batch ~session account_ids =
    let headers = Session.headers session in
    GetAccountBatch.Fn.call ~headers {account_ids}

  (*
   * Get current account.
   *)

  module GetCurrentAccount = struct
    module Result = Protocol.Account
    module Error = Error.Make (Error.Void)

    module Info = struct
      let uri = Root.api "/users/get_current_account"
    end

    module Fn = Supplier (C) (Result) (Error) (Info)
  end

  let get_current_account ~session () =
    let headers = Session.headers session in
    GetCurrentAccount.Fn.call ~headers ()

  (*
   * Get space usage.
   *)

  module GetSpaceUsage = struct
    module Result = Protocol.SpaceUsage
    module Error = Error.Make (Error.Void)

    module Info = struct
      let uri = Root.api "/users/get_space_usage"
    end

    module Fn = Supplier (C) (Result) (Error) (Info)
  end

  let get_space_usage ~session () =
    let headers = Session.headers session in
    GetSpaceUsage.Fn.call ~headers ()

  (*
   * Features - Get value.
   *)
end
