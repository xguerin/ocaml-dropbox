open Cohttp
open Cohttp_lwt
open Infix
open Lwt.Infix

module type Data = sig
  module Json : Json.Sig
end

module type Endpoint = sig
  val uri : Uri.t
end

module Root = struct
  let api sub = Uri.of_string ("https://api.dropboxapi.com/2" ^ sub)
  let content sub = Uri.of_string ("https://content.dropboxapi.com/2" ^ sub)
end

module RemoteProcedureCall = struct
  module Function (C : S.Client) (I : Data) (O : Data) (E : Endpoint) = struct
    let call ?(headers = Header.init ()) ?q v =
      let headers = Header.add headers "Content-Type" "application/json" in
      let uri =
        match q with Some q -> Uri.with_query E.uri q | None -> E.uri in
      I.Json.to_string v
      >>= fun content ->
      C.post ~body:(`String content) ~headers uri
      >>= Error.handle
      >>=? fun (_, body) -> Body.to_string body >>= O.Json.of_string
  end

  module Supplier (C : S.Client) (O : Data) (E : Endpoint) = struct
    let call ?(headers = Header.init ()) ?q () =
      let uri =
        match q with Some q -> Uri.with_query E.uri q | None -> E.uri in
      C.post ~headers uri
      >>= Error.handle
      >>=? fun (_, body) -> Body.to_string body >>= O.Json.of_string
  end

  module Void (C : S.Client) (E : Endpoint) = struct
    let call ?(headers = Header.init ()) () =
      C.post ~headers E.uri >>= Error.handle
  end
end
