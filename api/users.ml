open Endpoint
open RemoteProcedureCall
open Infix

module S (C : Cohttp_lwt.S.Client) = struct
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
        [@@deriving yojson]
      end

      module Json = Json.S (Type)
    end

    module SharedFolderMemberPolicy = struct
      module Type = struct
        type t =
          | Anyone
          | Team

        let of_string = function
          | "anyone" -> Ok Anyone
          | "team" -> Ok Team
          | _ -> Error "Invalid SharedFolderMemberPolicy format"

        let to_string = function Anyone -> "anyone" | Team -> "team"

        let of_yojson = function
          | `Assoc [(".tag", `String v)] -> of_string v
          | `String v -> of_string v
          | _ -> Error "Invalid SharedFolderMemberPolicy format"

        let to_yojson v = `String (to_string v)
      end

      module Json = Json.S (Type)
    end

    module SharedFolderJoinPolicy = struct
      module Type = struct
        type t =
          | From_anyone
          | From_team_only

        let of_string = function
          | "from_anyone" -> Ok From_anyone
          | "from_team_only" -> Ok From_team_only
          | _ -> Error "Invalid SharedFolderJoinPolicy format"

        let to_string = function
          | From_anyone -> "from_anyone"
          | From_team_only -> "from_team_only"

        let of_yojson = function
          | `Assoc [(".tag", `String v)] -> of_string v
          | `String v -> of_string v
          | _ -> Error "Invalid SharedFolderJoinPolicy format"

        let to_yojson v = `String (to_string v)
      end

      module Json = Json.S (Type)
    end

    module SharedLinkCreatePolicy = struct
      module Type = struct
        type t =
          | Default_public
          | Default_team_only
          | Team_only

        let of_string = function
          | "default_public" -> Ok Default_public
          | "default_team_only" -> Ok Default_team_only
          | "team_only" -> Ok Team_only
          | _ -> Error "Invalid SharedLinkCreatePolicy format"

        let to_string = function
          | Default_public -> "default_public"
          | Default_team_only -> "default_team_only"
          | Team_only -> "team_only"

        let of_yojson = function
          | `Assoc [(".tag", `String v)] -> of_string v
          | `String v -> of_string v
          | _ -> Error "Invalid SharedLinkCreatePolicy format"

        let to_yojson v = `String (to_string v)
      end

      module Json = Json.S (Type)
    end

    module TeamSharingPolicies = struct
      module Type = struct
        type t =
          { shared_folder_member_policy : SharedFolderMemberPolicy.Type.t
          ; shared_folder_join_policy : SharedFolderJoinPolicy.Type.t
          ; shared_link_create_policy : SharedLinkCreatePolicy.Type.t }
        [@@deriving yojson]
      end

      module Json = Json.S (Type)
    end

    module OfficeAddinPolicy = struct
      module Type = struct
        type t =
          | Disabled
          | Enabled

        let of_string = function
          | "disabled" -> Ok Disabled
          | "enabled" -> Ok Enabled
          | _ -> Error "Invalid OfficeAddinPolicy format"

        let to_string = function Disabled -> "disabled" | Enabled -> "enabled"

        let of_yojson = function
          | `Assoc [(".tag", `String v)] -> of_string v
          | `String v -> of_string v
          | _ -> Error "Invalid OfficeAddinPolicy format"

        let to_yojson v = `String (to_string v)
      end

      module Json = Json.S (Type)
    end

    module FullTeam = struct
      module Type = struct
        type t =
          { id : string
          ; name : string
          ; sharing_policies : TeamSharingPolicies.Type.t
          ; office_addin_policies : OfficeAddinPolicy.Type.t }
        [@@deriving yojson]
      end

      module Json = Json.S (Type)
    end

    module AccountType = struct
      module Type = struct
        type t =
          | Basic
          | Pro
          | Business

        let of_string = function
          | "basic" -> Ok Basic
          | "pro" -> Ok Pro
          | "business" -> Ok Business
          | _ -> Error "Invalid AccountType format"

        let to_string = function
          | Basic -> "basic"
          | Pro -> "pro"
          | Business -> "business"

        let of_yojson = function
          | `Assoc [(".tag", `String v)] -> of_string v
          | `String v -> of_string v
          | _ -> Error "Invalid AccountType format"

        let to_yojson v = `String (to_string v)
      end

      module Json = Json.S (Type)
    end

    module TeamRootInfo = struct
      module Type = struct
        type t =
          { root_namespace_id : string
          ; home_namespace_id : string
          ; home_path : string }
        [@@deriving yojson]
      end

      module Json = Json.S (Type)
    end

    module UserRootInfo = struct
      module Type = struct
        type t =
          { root_namespace_id : string
          ; home_namespace_id : string }
        [@@deriving yojson]
      end

      module Json = Json.S (Type)
    end

    module RootInfo = struct
      module Type = struct
        type t =
          | Team of TeamRootInfo.Type.t
          | User of UserRootInfo.Type.t

        let of_yojson v =
          let sorted = Yojson.Safe.sort v in
          match sorted with
          | `Assoc ((".tag", `String "team") :: tl) ->
            TeamRootInfo.Type.of_yojson (`Assoc tl)
            |>? fun team -> Ok (Team team)
          | `Assoc ((".tag", `String "user") :: tl) ->
            UserRootInfo.Type.of_yojson (`Assoc tl)
            |>? fun user -> Ok (User user)
          | _ -> Error "Invalid RootInfo format"

        let to_yojson = function
          | Team team -> (
            match TeamRootInfo.Type.to_yojson team with
            | `Assoc tl -> `Assoc ((".tag", `String "team") :: tl)
            | _ -> `Null)
          | User user -> (
            match UserRootInfo.Type.to_yojson user with
            | `Assoc tl -> `Assoc ((".tag", `String "user") :: tl)
            | _ -> `Null)
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

  (*
   * Get account.
   *)

  let get_account_uri = Root.api "/users/get_account"

  let get_account (_ : Session.Type.t) =
    let module Error = Error.S (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Get account batch.
   *)

  let get_account_batch_uri = Root.api "/users/get_account_batch"

  let get_account_batch (_ : Session.Type.t) =
    let module Error = Error.S (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Get current account.
   *)

  module GetCurrentAccount = struct
    module Result = Protocol.Account
    module Error = Error.S (Error.Void)

    module Info = struct
      let uri = Root.api "/users/get_current_account"
    end

    module Fn = Supplier (C) (Result) (Error) (Info)
  end

  let get_current_account session =
    let headers = Session.headers session in
    GetCurrentAccount.Fn.call ~headers ()

  (*
   * Get space usage.
   *)

  module GetSpaceUsage = struct
    module Result = Protocol.SpaceUsage
    module Error = Error.S (Error.Void)

    module Info = struct
      let uri = Root.api "/users/get_space_usage"
    end

    module Fn = Supplier (C) (Result) (Error) (Info)
  end

  let get_space_usage session =
    let headers = Session.headers session in
    GetSpaceUsage.Fn.call ~headers ()
end
