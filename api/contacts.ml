(* 
 * Copyright (c) 2020 Xavier R. Guérin <copyright@applepine.org>
 * 
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *)

open Endpoint

module Make (C : Cohttp_lwt.S.Client) = struct
  (*
   * Protocol.
   *)

  module Protocol = struct
    module DeleteManualContactsArg = struct
      module Type = struct
        type t = {email_addresses : string list} [@@deriving yojson, show]
      end

      module Json = Json.Make (Type)
    end

    module DeleteManualContactsError = struct
      module Type = struct
        type t = Contacts_not_found of string list [@@deriving dropbox, show]
      end

      module Json = Json.Make (Type)
    end
  end

  (*
   * Delete manual contacts.
   *)

  module DeleteManualContacts = struct
    module Error = Error.Make (Error.Void)

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
    module Error = Error.Make (Protocol.DeleteManualContactsError)

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
