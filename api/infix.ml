let ( |>=? ) = Result.bind

let ( >>=? ) m f =
  let open Lwt.Infix in
  m >>= function Ok x -> f x | Error err -> Lwt.return (Error err)
