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

open Cohttp
open Cohttp_lwt
open Infix
open Lwt.Infix

module type Data = sig
  module Json : Json.S
end

module type Info = sig
  val uri : Uri.t
end

module Root = struct
  let api sub = Uri.of_string ("https://api.dropboxapi.com/2" ^ sub)
  let content sub = Uri.of_string ("https://content.dropboxapi.com/2" ^ sub)
end

module ContentDownload = struct
  module Function (C : S.Client) (I : Data) (O : Data) (R : Error.T) (E : Info) =
  struct
    let deserialize v =
      match O.Json.of_string v with
      | Ok o -> Lwt.return_ok o
      | Error e ->
        let%lwt () = Logs_lwt.err (fun m -> m "%s" v) in
        Lwt.return_error (R.Serdes e)

    let call ?(headers = Header.init ()) ?q v =
      let content = I.Json.to_string v in
      let headers = Header.add headers "Dropbox-API-Arg" content in
      let uri =
        match q with Some q -> Uri.with_query E.uri q | None -> E.uri in
      C.post ~headers uri
      >>= R.handle
      >>=? fun (resp, body) ->
      (match Header.get (Response.headers resp) "Dropbox-API-Result" with
      | Some value -> deserialize value
      | None -> Lwt.return_error R.Missing_header)
      >>=? fun result -> Lwt.return_ok (result, body)
  end
end

module ContentUpload = struct
  module Function (C : S.Client) (I : Data) (O : Data) (R : Error.T) (E : Info) =
  struct
    let deserialize v =
      match O.Json.of_string v with
      | Ok o -> Lwt.return_ok o
      | Error e ->
        let%lwt () = Logs_lwt.err (fun m -> m "%s" v) in
        Lwt.return_error (R.Serdes e)

    let call ?(headers = Header.init ()) ?q v payload =
      let content = I.Json.to_string v in
      let h = Header.add headers "Dropbox-API-Arg" content in
      let h = Header.add h "Content-Type" "application/octet-stream" in
      let uri =
        match q with Some q -> Uri.with_query E.uri q | None -> E.uri in
      C.post ~body:payload ~headers:h uri
      >>= R.handle
      >>=? fun (_, body) -> Body.to_string body >>= deserialize
  end

  module Provider (C : S.Client) (I : Data) (R : Error.T) (E : Info) = struct
    let call ?(headers = Header.init ()) ?q v payload =
      let content = I.Json.to_string v in
      let h = Header.add headers "Dropbox-API-Arg" content in
      let h = Header.add h "Content-Type" "application/octet-stream" in
      let uri =
        match q with Some q -> Uri.with_query E.uri q | None -> E.uri in
      C.post ~body:payload ~headers:h uri >>= R.handle
  end
end

module RemoteProcedureCall = struct
  module Function (C : S.Client) (I : Data) (O : Data) (R : Error.T) (E : Info) =
  struct
    let deserialize v =
      match O.Json.of_string v with
      | Ok o -> Lwt.return_ok o
      | Error e ->
        let%lwt () = Logs_lwt.err (fun m -> m "%s" v) in
        Lwt.return_error (R.Serdes e)

    let call ?(headers = Header.init ()) ?q v =
      let headers = Header.add headers "Content-Type" "application/json" in
      let uri =
        match q with Some q -> Uri.with_query E.uri q | None -> E.uri in
      let content = I.Json.to_string v in
      C.post ~body:(`String content) ~headers uri
      >>= R.handle
      >>=? fun (_, body) -> Body.to_string body >>= deserialize
  end

  module Provider (C : S.Client) (I : Data) (R : Error.T) (E : Info) = struct
    let call ?(headers = Header.init ()) ?q v =
      let headers = Header.add headers "Content-Type" "application/json" in
      let uri =
        match q with Some q -> Uri.with_query E.uri q | None -> E.uri in
      let content = I.Json.to_string v in
      C.post ~body:(`String content) ~headers uri >>= R.handle
  end

  module Supplier (C : S.Client) (O : Data) (R : Error.T) (E : Info) = struct
    let deserialize v =
      match O.Json.of_string v with
      | Ok o -> Lwt.return_ok o
      | Error e ->
        let%lwt () = Logs_lwt.err (fun m -> m "%s" v) in
        Lwt.return_error (R.Serdes e)

    let call ?(headers = Header.init ()) ?q () =
      let uri =
        match q with Some q -> Uri.with_query E.uri q | None -> E.uri in
      C.post ~headers uri
      >>= R.handle
      >>=? fun (_, body) -> Body.to_string body >>= deserialize
  end

  module Void (C : S.Client) (R : Error.T) (E : Info) = struct
    let call ?(headers = Header.init ()) () = C.post ~headers E.uri >>= R.handle
  end
end
