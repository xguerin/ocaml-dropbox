(*
 * Base errors.
 *)

module LookupError = struct
  module Type = struct
    type t =
      | Malformed_path
      | Not_file
      | Not_folder
      | Not_found
      | Restricted_content
      | Unsupported_content_type
    [@@deriving dropbox, show]
  end

  module Json = Json.Make (Type)
end

module WriteConflictError = struct
  module Type = struct
    type t =
      | File
      | Folder
      | File_ancestor
    [@@deriving dropbox, show]
  end

  module Json = Json.Make (Type)
end

module WriteError = struct
  module Type = struct
    type t =
      | Malformed_path of string option
      | Conflict of WriteConflictError.Type.t
      | No_write_permission
      | Insufficient_space
      | Disallowed_name
      | Team_folder
      | Too_many_write_operations
    [@@deriving dropbox, show]
  end

  module Json = Json.Make (Type)
end

(*
 * Misc.
 *)

module LogicalOperator = struct
  module Type = struct
    type t = Or_operator [@@deriving dropbox, show]
  end

  module Json = Json.Make (Type)
end

(*
 * Properties.
 *)

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

module PropertiesSearchMode = struct
  module Type = struct
    type t = Field_name of string [@@deriving dropbox, show]
  end

  module Json = Json.Make (Type)
end

module PropertyType = struct
  module Type = struct
    type t = String [@@deriving dropbox, show]
  end

  module Json = Json.Make (Type)
end

module PropertyFieldTemplate = struct
  module Type = struct
    type t =
      { name : string
      ; description : string
      ; type_ : PropertyType.Type.t [@key "type"] }
    [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module PropertyField = struct
  module Type = struct
    type t =
      { name : string
      ; value : string }
    [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module PropertyGroup = struct
  module Type = struct
    type t =
      { template_id : string
      ; fields : PropertyField.Type.t list }
    [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

(*
 * Metadata.
 *)

module Dimensions = struct
  module Type = struct
    type t =
      { height : Int64.t
      ; width : Int64.t }
    [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module GpsCoordinates = struct
  module Type = struct
    type t =
      { latitude : float
      ; longitude : float }
    [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module PhotoMetadata = struct
  module Type = struct
    type t =
      { dimensions : Dimensions.Type.t option [@default None]
      ; location : Dimensions.Type.t option [@default None]
      ; time_taken : string option [@default None] }
    [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module VideoMetadata = struct
  module Type = struct
    type t =
      { dimensions : Dimensions.Type.t option [@default None]
      ; location : Dimensions.Type.t option [@default None]
      ; time_taken : string option [@default None]
      ; duration : Int64.t option [@default None] }
    [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module MediaMetadata = struct
  module Type = struct
    type t =
      | Photo of PhotoMetadata.Type.t
      | Video of VideoMetadata.Type.t
    [@@deriving dropbox {mode = SubType}, show]
  end

  module Json = Json.Make (Type)
end

module FileLockMetadata = struct
  module Type = struct
    type t =
      { is_lockholder : bool option [@default None]
      ; lockholder_name : string option [@default None]
      ; lockholder_account_id : string option [@default None]
      ; created : string option [@default None] }
    [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module MinimalFileLinkMetadata = struct
  module Type = struct
    type t =
      { url : string
      ; rev : string
      ; id : string option [@default None]
      ; path : string option [@default None] }
    [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module ExportMetadata = struct
  module Type = struct
    type t =
      { name : string
      ; size : Int64.t
      ; export_hash : string option }
    [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

(*
 * Info.
 *)

module MediaInfo = struct
  module Type = struct
    type t =
      | Metadata of MediaMetadata.Type.t
      | Pending
    [@@deriving dropbox, show]
  end

  module Json = Json.Make (Type)
end

module SymlinkInfo = struct
  module Type = struct
    type t = {target : string} [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module FileSharingInfo = struct
  module Type = struct
    type t =
      { read_only : bool
      ; parent_shared_folder_id : string
      ; modified_by : string option [@default None] }
    [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module ExportInfo = struct
  module Type = struct
    type t = {export_as : string option [@default None]}
    [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module FolderSharingInfo = struct
  module Type = struct
    type t =
      { read_only : bool
      ; parent_shared_folder_id : string option [@default None]
      ; shared_folder_id : string option [@default None]
      ; traverse_only : bool
      ; no_access : bool }
    [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module SharedLinkFileInfo = struct
  module Type = struct
    type t =
      { url : string
      ; path : string option [@default None]
      ; password : string option [@default None] }
    [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

(*
 * Path, link.
 *)

module PathOrLink = struct
  module Type = struct
    type t =
      | Path of string
      | Link of SharedLinkFileInfo.Type.t
    [@@deriving dropbox, show]
  end

  module Json = Json.Make (Type)
end

module SharedLink = struct
  module Type = struct
    type t =
      { url : string
      ; password : string option [@default None] }
    [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module WriteMode = struct
  module Type = struct
    type t =
      | Add
      | Overwrite
      | Update of string
    [@@deriving dropbox, show]
  end

  module Json = Json.Make (Type)
end

module CommitInfo = struct
  module Type = struct
    type t =
      { path : string
      ; mode : WriteMode.Type.t
      ; autorename : bool
      ; client_modified : string option
      ; mute : bool
      ; property_groups : PropertyGroup.Type.t list option
      ; strict_conflict : bool }
    [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)

  let make ?(mode = WriteMode.Type.Add) ?(autorename = false) ?client_modified
      ?(mute = false) ?property_groups ?(strict_conflict = false) path =
    Type.
      { path
      ; mode
      ; autorename
      ; client_modified
      ; mute
      ; property_groups
      ; strict_conflict }
end

module ListRevisionsMode = struct
  module Type = struct
    type t =
      | Path
      | Id
    [@@deriving dropbox, show]
  end

  module Json = Json.Make (Type)
end

(*
 * Metadata.
 *)

module FileMetadata = struct
  module Type = struct
    type t =
      { name : string
      ; id : string
      ; client_modified : string
      ; server_modified : string
      ; rev : string
      ; size : Int64.t
      ; path_lower : string option [@default None]
      ; path_display : string option [@default None]
      ; parent_shared_folder_id : string option [@default None]
      ; media_info : MediaInfo.Type.t option [@default None]
      ; symlink_info : SymlinkInfo.Type.t option [@default None]
      ; sharing_info : FileSharingInfo.Type.t option [@default None]
      ; is_downloadable : bool
      ; export_info : ExportInfo.Type.t option [@default None]
      ; property_groups : PropertyGroup.Type.t list option [@default None]
      ; has_explicit_shared_members : bool option [@default None]
      ; content_hash : string option [@default None]
      ; file_lock_info : FileLockMetadata.Type.t option [@default None] }
    [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module FolderMetadata = struct
  module Type = struct
    type t =
      { name : string
      ; id : string
      ; path_lower : string option [@default None]
      ; path_display : string option [@default None]
      ; parent_shared_folder_id : string option [@default None]
      ; shared_folder_id : string option [@default None]
      ; sharing_info : FolderSharingInfo.Type.t option [@default None]
      ; property_groups : PropertyGroup.Type.t list option [@default None] }
    [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module DeletedMetadata = struct
  module Type = struct
    type t =
      { name : string
      ; path_lower : string option [@default None]
      ; path_display : string option [@default None]
      ; parent_shared_folder_id : string option [@default None] }
    [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module Metadata = struct
  module Type = struct
    type t =
      | Deleted of DeletedMetadata.Type.t
      | File of FileMetadata.Type.t
      | Folder of FolderMetadata.Type.t
    [@@deriving dropbox {mode = SubType}, show]
  end

  module Json = Json.Make (Type)
end

module MetadataV2 = struct
  module Type = struct
    type t = Metadata of Metadata.Type.t [@@deriving dropbox, show]
  end

  module Json = Json.Make (Type)
end

(*
 * Thumbnail.
 *)

module ThumbnailFormat = struct
  module Type = struct
    type t =
      | Jpeg
      | Png
    [@@deriving dropbox, show]
  end

  module Json = Json.Make (Type)
end

module ThumbnailSize = struct
  module Type = struct
    type t =
      | W32H32
      | W64H64
      | W128H128
      | W256H256
      | W480H320
      | W640H480
      | W960H640
      | W1024H768
      | W2048H1536
    [@@deriving dropbox, show]
  end

  module Json = Json.Make (Type)
end

module ThumbnailMode = struct
  module Type = struct
    type t =
      | Strict
      | Bestfit
      | Fitone_bestfit
    [@@deriving dropbox, show]
  end

  module Json = Json.Make (Type)
end

module PreviewResult = struct
  module Type = struct
    type t =
      { file_metadata : FileMetadata.Type.t option [@default None]
      ; link_metadata : MinimalFileLinkMetadata.Type.t option [@default None] }
    [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

(*
 * Templates.
 *)

module TemplateFilterBase = struct
  module Type = struct
    type t = Filter_some of string list [@@deriving dropbox, show]
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

module TemplateError = struct
  module Type = struct
    type t =
      | Template_not_found of string
      | Restricted_content
    [@@deriving dropbox, show]
  end

  module Json = Json.Make (Type)
end

(*
 * Search.
 *)

module FileStatus = struct
  module Type = struct
    type t =
      | Active
      | Deleted
    [@@deriving dropbox, show]
  end

  module Json = Json.Make (Type)
end

module FileCategory = struct
  module Type = struct
    type t =
      | Image
      | Document
      | PDF
      | Spreadsheet
      | Presentation
      | Audio
      | Video
      | Folder
      | Paper
      | Other
    [@@deriving dropbox, show]
  end

  module Json = Json.Make (Type)
end

module SearchMatchFieldOptions = struct
  module Type = struct
    type t = {include_highlights : bool} [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module SearchOptions = struct
  module Type = struct
    type t =
      { path : string option
      ; max_results : Int64.t
      ; file_status : FileStatus.Type.t
      ; filename_only : bool
      ; file_extensions : string list option
      ; file_categories : FileCategory.Type.t list option }
    [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module HighlightSpan = struct
  module Type = struct
    type t =
      { highlight_str : string
      ; is_highlighted : bool }
    [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module SearchMatchTypeV2 = struct
  module Type = struct
    type t =
      | Filename
      | File_content
      | Filename_and_content
      | Image_content
    [@@deriving dropbox, show]
  end

  module Json = Json.Make (Type)
end

module SearchMatchV2 = struct
  module Type = struct
    type t =
      { metadata : MetadataV2.Type.t
      ; match_type : SearchMatchTypeV2.Type.t option [@default None]
      ; highlight_spans : HighlightSpan.Type.t list option [@default None] }
    [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

(*
 * Relocation.
 *)

module RelocationPath = struct
  module Type = struct
    type t =
      { from_path : string
      ; to_path : string }
    [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

(*
 * Lock.
 *)

module SingleUserLock = struct
  module Type = struct
    type t =
      { created : string
      ; lock_holder_account_id : string
      ; lock_holder_team_id : string option }
    [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end

module FileLockContent = struct
  module Type = struct
    type t =
      | Unlocked
      | Single_user of SingleUserLock.Type.t
    [@@deriving dropbox, show]
  end

  module Json = Json.Make (Type)
end

module FileLock = struct
  module Type = struct
    type t = {content : FileLockContent.Type.t} [@@deriving yojson, show]
  end

  module Json = Json.Make (Type)
end
