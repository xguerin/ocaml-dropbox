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
        [@@deriving yojson, show]
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
        [@@deriving dropbox, show]
      end

      module Json = Json.Make (Type)
    end

    module OverwritePropertyGroupArg = struct
      module Type = struct
        type t =
          { path : string
          ; property_groups : PropertyGroup.Type.t list }
        [@@deriving yojson, show]
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
        [@@deriving dropbox, show]
      end

      module Json = Json.Make (Type)
    end

    module RemovePropertiesArg = struct
      module Type = struct
        type t =
          { path : string
          ; property_template_ids : string list }
        [@@deriving yojson, show]
      end

      module Json = Json.Make (Type)
    end

    module LookUpPropertiesError = struct
      module Type = struct
        type t = Property_group_not_found [@@deriving dropbox, show]
      end

      module Json = Json.Make (Type)
    end

    module RemovePropertiesError = struct
      module Type = struct
        type t =
          | Template_not_found of string
          | Restricted_content
          | Lookup_error of LookupError.Type.t
          | Unsupported_folder
          | Property_group_lookup of LookUpPropertiesError.Type.t
        [@@deriving dropbox, show]
      end

      module Json = Json.Make (Type)
    end

    module LogicalOperator = struct
      module Type = struct
        type t = Or_operator [@@deriving dropbox, show]
      end

      module Json = Json.Make (Type)
    end

    module PropertiesSearchMode = struct
      module Type = struct
        type t = Field_name of string [@@deriving dropbox, show]
      end

      module Json = Json.Make (Type)
    end

    module TemplateFilter = struct
      module Type = struct
        type t =
          | Filter_some of string list
          | Filter_none
        [@@deriving dropbox, show]
      end

      module Json = Json.Make (Type)
    end

    module PropertiesSearchQuery = struct
      module Type = struct
        type t =
          { query : string
          ; mode : PropertiesSearchMode.Type.t
          ; logical_operator : LogicalOperator.Type.t }
        [@@deriving yojson, show]
      end

      module Json = Json.Make (Type)
    end

    module PropertiesSearchArg = struct
      module Type = struct
        type t =
          { queries : PropertiesSearchQuery.Type.t list
          ; template_filter : TemplateFilter.Type.t }
        [@@deriving yojson, show]
      end

      module Json = Json.Make (Type)
    end

    module PropertiesSearchMatch = struct
      module Type = struct
        type t =
          { id : string
          ; path : string
          ; is_deleted : bool
          ; property_groups : PropertyGroup.Type.t list }
        [@@deriving yojson, show]
      end

      module Json = Json.Make (Type)
    end

    module PropertiesSearchResult = struct
      module Type = struct
        type t =
          { matches : PropertiesSearchMatch.Type.t list
          ; cursor : string }
        [@@deriving yojson, show]
      end

      module Json = Json.Make (Type)
    end

    module PropertiesSearchError = struct
      module Type = struct
        type t = Property_group_lookup of LookUpPropertiesError.Type.t
        [@@deriving dropbox, show]
      end

      module Json = Json.Make (Type)
    end

    module PropertiesSearchContinueArg = struct
      module Type = struct
        type t = {cursor : string} [@@deriving yojson, show]
      end

      module Json = Json.Make (Type)
    end

    module PropertiesSearchContinueError = struct
      module Type = struct
        type t = Reset [@@deriving dropbox, show]
      end

      module Json = Json.Make (Type)
    end

    module PropertyGroupUpdate = struct
      module Type = struct
        type t =
          { template_id : string
          ; add_or_update_fields : PropertyField.Type.t list option
          ; remove_fields : string list option }
        [@@deriving yojson, show]
      end

      module Json = Json.Make (Type)
    end

    module UpdatePropertiesArg = struct
      module Type = struct
        type t =
          { path : string
          ; update_property_groups : PropertyGroupUpdate.Type.t list }
        [@@deriving yojson, show]
      end

      module Json = Json.Make (Type)
    end

    module UpdatePropertiesError = struct
      module Type = struct
        type t =
          | Template_not_found of string
          | Restricted_content
          | Lookup_error of LookupError.Type.t
          | Unsupported_folder
          | Property_field_too_large
          | Does_not_fit_template
          | Duplicate_property_groups
          | Property_group_lookup of LookUpPropertiesError.Type.t
        [@@deriving dropbox, show]
      end

      module Json = Json.Make (Type)
    end

    module AddTemplateArg = struct
      module Type = struct
        type t =
          { name : string
          ; description : string
          ; fields : PropertyFieldTemplate.Type.t list }
        [@@deriving yojson, show]
      end

      module Json = Json.Make (Type)
    end

    module AddTemplateResult = struct
      module Type = struct
        type t = {template_id : string} [@@deriving yojson, show]
      end

      module Json = Json.Make (Type)
    end

    module ModifyTemplateError = struct
      module Type = struct
        type t =
          | Template_not_found of string
          | Restricted_content
          | Conflicting_property_names
          | Too_many_properties
          | Too_many_templates
          | Template_attribute_too_large
        [@@deriving dropbox, show]
      end

      module Json = Json.Make (Type)
    end

    module GetTemplateArg = struct
      module Type = struct
        type t = {template_id : string} [@@deriving yojson, show]
      end

      module Json = Json.Make (Type)
    end

    module GetTemplateResult = struct
      module Type = struct
        type t =
          { name : string
          ; description : string
          ; fields : PropertyFieldTemplate.Type.t list }
        [@@deriving yojson, show]
      end

      module Json = Json.Make (Type)
    end

    module TemplateError = struct
      module Type = struct
        type t =
          | Template_not_found of string
          | Restricted_content
        [@@deriving dropbox, show]
      end

      module Json = Json.Make (Type)
    end

    module ListTemplateResult = struct
      module Type = struct
        type t = {template_id : string list} [@@deriving yojson, show]
      end

      module Json = Json.Make (Type)
    end

    module RemoveTemplateArg = struct
      module Type = struct
        type t = {template_id : string} [@@deriving yojson, show]
      end

      module Json = Json.Make (Type)
    end

    module UpdateTemplateArg = struct
      module Type = struct
        type t =
          { template_id : string
          ; name : string option
          ; description : string option
          ; add_fields : PropertyFieldTemplate.Type.t list option }
        [@@deriving yojson, show]
      end

      module Json = Json.Make (Type)
    end

    module UpdateTemplateResult = struct
      module Type = struct
        type t = {template_id : string} [@@deriving yojson, show]
      end

      module Json = Json.Make (Type)
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

  module PropertySearch = struct
    module Arg = Protocol.PropertiesSearchArg
    module Result = Protocol.PropertiesSearchResult
    module Error = Error.Make (Protocol.PropertiesSearchError)

    module Info = struct
      let uri = Root.api "/file_properties/properties/search"
    end

    module Fn = RemoteProcedureCall.Function (C) (Arg) (Result) (Error) (Info)
  end

  let properties_search ~session
      ?(template_filter = Protocol.TemplateFilter.Type.Filter_none) queries =
    let request = PropertySearch.Arg.Type.{queries; template_filter}
    and headers = Session.headers session in
    PropertySearch.Fn.call ~headers request

  (*
   * Properties search continue.
   *)

  module PropertySearchContinue = struct
    module Arg = Protocol.PropertiesSearchContinueArg
    module Result = Protocol.PropertiesSearchResult
    module Error = Error.Make (Protocol.PropertiesSearchContinueError)

    module Info = struct
      let uri = Root.api "/file_properties/properties/search/continue"
    end

    module Fn = RemoteProcedureCall.Function (C) (Arg) (Result) (Error) (Info)
  end

  let properties_search_continue ~session cursor =
    let request = PropertySearchContinue.Arg.Type.{cursor}
    and headers = Session.headers session in
    PropertySearchContinue.Fn.call ~headers request

  (*
   * Properties update.
   *)

  module PropertyUpdate = struct
    module Arg = Protocol.UpdatePropertiesArg
    module Error = Error.Make (Protocol.UpdatePropertiesError)

    module Info = struct
      let uri = Root.api "/file_properties/properties/update"
    end

    module Fn = RemoteProcedureCall.Provider (C) (Arg) (Error) (Info)
  end

  let properties_update ~session path update_property_groups =
    let request = PropertyUpdate.Arg.Type.{path; update_property_groups}
    and headers = Session.headers session in
    PropertyUpdate.Fn.call ~headers request

  (*
   * Templates add for user.
   *)

  module TemplateAddForUser = struct
    module Arg = Protocol.AddTemplateArg
    module Result = Protocol.AddTemplateResult
    module Error = Error.Make (Protocol.ModifyTemplateError)

    module Info = struct
      let uri = Root.api "/file_properties/templates/add_for_user"
    end

    module Fn = RemoteProcedureCall.Function (C) (Arg) (Result) (Error) (Info)
  end

  let templates_add_for_user ~session name description fields =
    let request = TemplateAddForUser.Arg.Type.{name; description; fields}
    and headers = Session.headers session in
    TemplateAddForUser.Fn.call ~headers request

  (*
   * Templates get for user.
   *)

  module TemplateGetForUser = struct
    module Arg = Protocol.GetTemplateArg
    module Result = Protocol.GetTemplateResult
    module Error = Error.Make (Protocol.TemplateError)

    module Info = struct
      let uri = Root.api "/file_properties/templates/get_for_user"
    end

    module Fn = RemoteProcedureCall.Function (C) (Arg) (Result) (Error) (Info)
  end

  let templates_get_for_user ~session template_id =
    let request = TemplateGetForUser.Arg.Type.{template_id}
    and headers = Session.headers session in
    TemplateGetForUser.Fn.call ~headers request

  (*
   * Templates list for user.
   *)

  module TemplateListForUser = struct
    module Result = Protocol.ListTemplateResult
    module Error = Error.Make (Protocol.TemplateError)

    module Info = struct
      let uri = Root.api "/file_properties/templates/list_for_user"
    end

    module Fn = RemoteProcedureCall.Supplier (C) (Result) (Error) (Info)
  end

  let templates_list_for_user ~session () =
    let headers = Session.headers session in
    TemplateListForUser.Fn.call ~headers ()

  (*
   * Templates remove for user.
   *)

  module TemplateRemoveForUser = struct
    module Arg = Protocol.RemoveTemplateArg
    module Error = Error.Make (Protocol.TemplateError)

    module Info = struct
      let uri = Root.api "/file_properties/templates/remove_for_user"
    end

    module Fn = RemoteProcedureCall.Provider (C) (Arg) (Error) (Info)
  end

  let templates_remove_for_user ~session template_id =
    let request = TemplateRemoveForUser.Arg.Type.{template_id}
    and headers = Session.headers session in
    TemplateRemoveForUser.Fn.call ~headers request

  (*
   * Templates update for user.
   *)

  module TemplateUpdateForUser = struct
    module Arg = Protocol.UpdateTemplateArg
    module Result = Protocol.UpdateTemplateResult
    module Error = Error.Make (Protocol.ModifyTemplateError)

    module Info = struct
      let uri = Root.api "/file_properties/templates/update_for_user"
    end

    module Fn = RemoteProcedureCall.Function (C) (Arg) (Result) (Error) (Info)
  end

  let templates_update_for_user ~session ?name ?description ?add_fields
      template_id =
    let request =
      TemplateUpdateForUser.Arg.Type.
        {template_id; name; description; add_fields}
    and headers = Session.headers session in
    TemplateUpdateForUser.Fn.call ~headers request
end
