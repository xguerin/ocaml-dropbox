open Infix
open Lwt.Infix

module Protocol = struct
  module CountFileRequestResult = struct
    module Type = struct
      type t = {file_request_count : Int64.t} [@@deriving yojson]
    end

    module Json = Json.S (Type)
  end

  module FileRequestDeadline = struct
    module Type = struct
      type t =
        { deadline : string
        ; allow_late_uploads : (string option[@default None]) }
      [@@deriving yojson]
    end

    module Json = Json.S (Type)

    let make e =
      Type.
        { deadline = ISO8601.Permissive.string_of_datetimezone e
        ; allow_late_uploads = None }
  end

  module CreateFileRequestArgs = struct
    module Type = struct
      type t =
        { title : string
        ; destination : string
        ; deadline : (FileRequestDeadline.Type.t option[@default None])
        ; open_ : bool [@key "open"] }
      [@@deriving yojson]
    end

    module Json = Json.S (Type)
  end

  module FileRequest = struct
    module Type = struct
      type t =
        { id : string
        ; url : string
        ; title : string
        ; created : string
        ; is_open : bool
        ; file_count : Int64.t
        ; destination : string
        ; deadline : (FileRequestDeadline.Type.t option[@default None]) }
      [@@deriving yojson]
    end

    module Json = Json.S (Type)
  end
end

module S (Client : Cohttp_lwt.S.Client) = struct
  open Cohttp
  open Cohttp_lwt
  open Protocol

  let count_uri =
    Uri.of_string "https://api.dropboxapi.com/2/file_requests/count"

  let count session =
    let module Result = CountFileRequestResult in
    let headers = Session.headers session in
    Client.post ~headers count_uri
    >>= Error.handle
    >>=? (fun (_, body) -> Body.to_string body >>= Result.Json.of_string)
    >>=? fun {file_request_count; _} -> Lwt.return_ok file_request_count

  let create_uri =
    Uri.of_string "https://api.dropboxapi.com/2/file_requests/create"

  let create ~title ~destination ?deadline ?(open_ = true) session =
    let module Deadline = FileRequestDeadline in
    let module Args = CreateFileRequestArgs in
    let module Result = FileRequest in
    let deadline = Option.map Deadline.make deadline in
    let args = Args.Type.{title; destination; deadline; open_} in
    let headers = Session.headers session in
    let headers = Header.add headers "Content-Type" "application/json" in
    Args.Json.to_string args
    >>= (fun c -> Client.post ~body:(`String c) ~headers create_uri)
    >>= Error.handle
    >>=? fun (_, body) -> Body.to_string body >>= Result.Json.of_string

  let delete_uri =
    Uri.of_string "https://api.dropboxapi.com/2/file_requests/delete"

  let delete (_ : Session.Type.t) =
    Lwt.return_error (Error.Not_implemented "delete")

  let delete_all_closed_uri =
    Uri.of_string "https://api.dropboxapi.com/2/file_requests/delete_all_closed"

  let delete_all_closed (_ : Session.Type.t) =
    Lwt.return_error (Error.Not_implemented "delete_all_closed")

  let get_uri = Uri.of_string "https://api.dropboxapi.com/2/file_requests/get"
  let get (_ : Session.Type.t) = Lwt.return_error (Error.Not_implemented "get")

  let list_uri =
    Uri.of_string "https://api.dropboxapi.com/2/file_requests/list_v2"

  let list (_ : Session.Type.t) =
    Lwt.return_error (Error.Not_implemented "list")

  let list_continue_uri =
    Uri.of_string "https://api.dropboxapi.com/2/file_requests/list/continue"

  let list_continue (_ : Session.Type.t) =
    Lwt.return_error (Error.Not_implemented "list_continue")

  let update_uri =
    Uri.of_string "https://api.dropboxapi.com/2/file_requests/update"

  let update (_ : Session.Type.t) =
    Lwt.return_error (Error.Not_implemented "update")
end
