open Cohttp
open Cohttp_lwt
open Infix
open Lwt.Infix

module type Data = sig
  module Json : Json.Sig
end

module type Info = sig
  val uri : Uri.t
end

module Root = struct
  let api sub = Uri.of_string ("https://api.dropboxapi.com/2" ^ sub)
  let content sub = Uri.of_string ("https://content.dropboxapi.com/2" ^ sub)
end

module ContentDownload = struct
  module Function (C : S.Client) (I : Data) (O : Data) (E : Info) = struct
    let deserialize v =
      match O.Json.of_string v with
      | Some o -> Lwt.return_ok o
      | None -> Lwt.return_error Error.Serdes

    let call ?(headers = Header.init ()) ?q v =
      let content = I.Json.to_string v in
      let headers = Header.add headers "Dropbox-API-Arg" content in
      let uri =
        match q with Some q -> Uri.with_query E.uri q | None -> E.uri in
      C.post ~headers uri
      >>= Error.handle
      >>=? fun (resp, body) ->
      (match Header.get (Response.headers resp) "Dropbox-API-Result" with
      | Some value -> deserialize value
      | None -> Lwt.return_error Error.Missing_header)
      >>=? fun result -> Lwt.return_ok (result, body)
  end
end

module RemoteProcedureCall = struct
  module Function (C : S.Client) (I : Data) (O : Data) (E : Info) = struct
    let deserialize v =
      match O.Json.of_string v with
      | Some o -> Lwt.return_ok o
      | None -> Lwt.return_error Error.Serdes

    let call ?(headers = Header.init ()) ?q v =
      let headers = Header.add headers "Content-Type" "application/json" in
      let uri =
        match q with Some q -> Uri.with_query E.uri q | None -> E.uri in
      let content = I.Json.to_string v in
      C.post ~body:(`String content) ~headers uri
      >>= Error.handle
      >>=? fun (_, body) -> Body.to_string body >>= deserialize
  end

  module Supplier (C : S.Client) (O : Data) (E : Info) = struct
    let deserialize v =
      match O.Json.of_string v with
      | Some o -> Lwt.return_ok o
      | None -> Lwt.return_error Error.Serdes

    let call ?(headers = Header.init ()) ?q () =
      let uri =
        match q with Some q -> Uri.with_query E.uri q | None -> E.uri in
      C.post ~headers uri
      >>= Error.handle
      >>=? fun (_, body) -> Body.to_string body >>= deserialize
  end

  module Void (C : S.Client) (E : Info) = struct
    let call ?(headers = Header.init ()) () =
      C.post ~headers E.uri >>= Error.handle
  end
end
