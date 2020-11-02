open Endpoint

module Make (C : Cohttp_lwt.S.Client) = struct
  (*
   * Protocol.
   *)

  module Protocol = struct
    open Common.Protocol

    module AddPropertiesArg = struct
      module Type = struct
        type t =
          { path : string
          ; property_groups : PropertyGroup.Type.t list }
        [@@deriving yojson]
      end

      module Json = Json.Make (Type)
    end

    module AddPropertiesError = struct
      module Type = struct
        type t =
          | Template_not_found of string
          | Restricted_content
          | Lookup_error of LookupError.Type.t
          | Unsupported_folder
          | Property_field_too_large
          | Does_not_fit_template
          | Duplicate_property_groups
          | Property_group_already_exists
        [@@deriving dropbox]
      end

      module Json = Json.Make (Type)

      let to_string = function
        | Type.Template_not_found e -> "Template not found: " ^ e
        | Type.Restricted_content -> "Restricted content"
        | Type.Lookup_error e -> "Lookup error: " ^ LookupError.to_string e
        | Type.Unsupported_folder -> "Unsupported folder"
        | Type.Property_field_too_large -> "Property field too large"
        | Type.Does_not_fit_template -> "Does not fit template"
        | Type.Duplicate_property_groups -> "Duplicate property groups"
        | Type.Property_group_already_exists -> "Property group already exists"
    end

    module OverwritePropertyGroupArg = struct
      module Type = struct
        type t =
          { path : string
          ; property_groups : PropertyGroup.Type.t list }
        [@@deriving yojson]
      end

      module Json = Json.Make (Type)
    end

    module InvalidPropertyGroupError = struct
      module Type = struct
        type t =
          | Template_not_found of string
          | Restricted_content
          | Path of LookupError.Type.t
          | Unsupported_folder
          | Property_field_too_large
          | Does_not_fit_template
          | Duplicate_property_groups
        [@@deriving dropbox]
      end

      module Json = Json.Make (Type)

      let to_string = function
        | Type.Template_not_found e -> "Template not found: " ^ e
        | Type.Restricted_content -> "Restricted content"
        | Type.Path e -> "Path: " ^ LookupError.to_string e
        | Type.Unsupported_folder -> "Unsupported folder"
        | Type.Property_field_too_large -> "Property field too large"
        | Type.Does_not_fit_template -> "Does not fit template"
        | Type.Duplicate_property_groups -> "Duplicate property groups"
    end

    module RemovePropertiesArg = struct
      module Type = struct
        type t =
          { path : string
          ; property_template_ids : string list }
        [@@deriving yojson]
      end

      module Json = Json.Make (Type)
    end

    module LookUpPropertiesError = struct
      module Type = struct
        type t = Property_group_not_found [@@deriving dropbox]
      end

      module Json = Json.Make (Type)

      let to_string = function
        | Type.Property_group_not_found -> "Property group not found"
    end

    module RemovePropertiesError = struct
      module Type = struct
        type t =
          | Template_not_found of string
          | Restricted_content
          | Lookup_error of LookupError.Type.t
          | Unsupported_folder
          | Property_group_lookup of LookUpPropertiesError.Type.t
        [@@deriving dropbox]
      end

      module Json = Json.Make (Type)

      let to_string = function
        | Type.Template_not_found e -> "Template not found: " ^ e
        | Type.Restricted_content -> "Restricted content"
        | Type.Lookup_error e -> "Lookup error: " ^ LookupError.to_string e
        | Type.Unsupported_folder -> "Unsupported folder"
        | Type.Property_group_lookup e ->
          "Property group lookup: " ^ LookUpPropertiesError.to_string e
    end
  end

  (*
   * Properties add.
   *)

  module PropertyAdd = struct
    module Arg = Protocol.AddPropertiesArg
    module Error = Error.Make (Protocol.AddPropertiesError)

    module Info = struct
      let uri = Root.api "/file_properties/properties/add"
    end

    module Fn = RemoteProcedureCall.Provider (C) (Arg) (Error) (Info)
  end

  let properties_add ~session path property_groups =
    let request = PropertyAdd.Arg.Type.{path; property_groups}
    and headers = Session.headers session in
    PropertyAdd.Fn.call ~headers request

  (*
   * Properties overwrite.
   *)

  module PropertyOverwrite = struct
    module Arg = Protocol.OverwritePropertyGroupArg
    module Error = Error.Make (Protocol.InvalidPropertyGroupError)

    module Info = struct
      let uri = Root.api "/file_properties/properties/overwrite"
    end

    module Fn = RemoteProcedureCall.Provider (C) (Arg) (Error) (Info)
  end

  let properties_overwrite ~session path property_groups =
    let request = PropertyOverwrite.Arg.Type.{path; property_groups}
    and headers = Session.headers session in
    PropertyOverwrite.Fn.call ~headers request

  (*
   * Properties remove.
   *)

  module PropertyRemove = struct
    module Arg = Protocol.RemovePropertiesArg
    module Error = Error.Make (Protocol.RemovePropertiesError)

    module Info = struct
      let uri = Root.api "/file_properties/properties/remove"
    end

    module Fn = RemoteProcedureCall.Provider (C) (Arg) (Error) (Info)
  end

  let properties_remove ~session path property_template_ids =
    let request = PropertyRemove.Arg.Type.{path; property_template_ids}
    and headers = Session.headers session in
    PropertyRemove.Fn.call ~headers request

  (*
   * Properties search.
   *)

  let properties_search_uri = Root.api "/file_properties/properties/search"

  let properties_search (_ : Session.Type.t) =
    let module Error = Error.Make (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Properties search continue.
   *)

  let properties_search_continue_uri =
    Root.api "/file_properties/properties/search/continue"

  let properties_search_continue (_ : Session.Type.t) =
    let module Error = Error.Make (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Properties update.
   *)

  let properties_update_uri = Root.api "/file_properties/properties/update"

  let properties_update (_ : Session.Type.t) =
    let module Error = Error.Make (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Templates add for user.
   *)

  let templates_add_for_user_uri =
    Root.api "/file_properties/templates/add_for_user"

  let templates_add_for_user (_ : Session.Type.t) =
    let module Error = Error.Make (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Templates get for user.
   *)

  let templates_get_for_user_uri =
    Root.api "/file_properties/templates/get_for_user"

  let templates_get_for_user (_ : Session.Type.t) =
    let module Error = Error.Make (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Templates list for user.
   *)

  let templates_list_for_user_uri =
    Root.api "/file_properties/templates/list_for_user"

  let templates_list_for_user (_ : Session.Type.t) =
    let module Error = Error.Make (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Templates remove for user.
   *)

  let templates_remove_for_user_uri =
    Root.api "/file_properties/templates/remove_for_user"

  let templates_remove_for_user (_ : Session.Type.t) =
    let module Error = Error.Make (Error.Void) in
    Lwt.return_error Error.Not_implemented

  (*
   * Templates update for user.
   *)

  let templates_update_for_user_uri =
    Root.api "/file_properties/templates/update_for_user"

  let templates_update_for_user (_ : Session.Type.t) =
    let module Error = Error.Make (Error.Void) in
    Lwt.return_error Error.Not_implemented
end
