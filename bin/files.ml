open Dropbox.Infix
open Dropbox_lwt_unix
open Lwt.Infix

let () =
  (*
   * Declare log reporter and level.
   *)
  Logs.set_reporter (Logs.format_reporter ());
  Logs.set_level (Some Logs.Info);
  (*
   * Command line.
   *)
  let usage = "Usage: files --token BEARER --path PATH"
  and tkn_opt = ref None
  and pth_opt = ref None in
  let specs =
    [ ("--token", Arg.String (fun v -> tkn_opt := Some v), "User token")
    ; ("--path", Arg.String (fun v -> pth_opt := Some v), "File path") ] in
  Arg.parse specs (fun _ -> ()) usage;
  (*
   * Check arguments.
   *)
  let token =
    match !tkn_opt with
    | Some token -> token
    | None -> failwith "The --token option must be set"
  and path =
    match !pth_opt with
    | Some path -> path
    | None -> failwith "The --path option must be set" in
  (*
   * Query user info.
   *)
  let session = Dropbox.Session.make token in
  let op =
    Files.download ~session path
    >>=? fun (_, body) ->
    Cohttp_lwt.Body.to_string body
    >>= fun body -> Logs_lwt.app (fun m -> m "%s" body) >>= Lwt.return_ok in
  match Lwt_main.run op with
  | Ok () -> ()
  | Error err -> Logs.err (fun m -> m "%a" Dropbox.Error.pp err)
