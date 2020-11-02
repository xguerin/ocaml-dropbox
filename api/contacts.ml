open Endpoint

module Make (C : Cohttp_lwt.S.Client) = struct
  (*
   * Protocol.
   *)

  module Protocol = struct
    module DeleteManualContactsArg = struct
      module Type = struct
        type t = {email_addresses : string list} [@@deriving yojson]
      end

      module Json = Json.Make (Type)
    end

    module DeleteManualContactsError = struct
      module Type = struct
        type t = Contacts_not_found of string list [@@deriving dropbox]
      end

      module Json = Json.Make (Type)

      let to_string = function
        | Type.Contacts_not_found contacts ->
          "Contacts not found: " ^ String.concat "," contacts
    end
  end

  (*
   * Delete manual contacts.
   *)

  module DeleteManualContacts = struct
    module Error = Error.S (Error.Void)

    module Info = struct
      let uri = Root.api "/contacts/delete_manual_contacts"
    end

    module Fn = RemoteProcedureCall.Void (C) (Error) (Info)
  end

  let delete_manual_contacts ~session () =
    let headers = Session.headers session in
    DeleteManualContacts.Fn.call ~headers ()

  (*
   * Delete manual contacts batch.
   *)

  module DeleteManualContactsBatch = struct
    module Arg = Protocol.DeleteManualContactsArg
    module Error = Error.S (Protocol.DeleteManualContactsError)

    module Info = struct
      let uri = Root.api "/contacts/delete_manual_contacts_batch"
    end

    module Fn = RemoteProcedureCall.Provider (C) (Arg) (Error) (Info)
  end

  let delete_manual_contacts_batch ~session email_addresses =
    let request = DeleteManualContactsBatch.Arg.Type.{email_addresses}
    and headers = Session.headers session in
    DeleteManualContactsBatch.Fn.call ~headers request
end
