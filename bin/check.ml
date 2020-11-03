open Dropbox_lwt_unix

let () =
  (*
   * Declare log reporter and level.
   *)
  Logs.set_reporter (Logs.format_reporter ());
  Logs.set_level (Some Logs.Info);
  (*
   * Command line.
   *)
  let usage =
    {usage|
    Usage: check [--id APP_ID --secret APP_SECRET]
                 [--token BEARER]
     |usage}
  and aid_opt = ref None
  and scr_opt = ref None
  and tkn_opt = ref None in
  let specs =
    [ ("--id", Arg.String (fun v -> aid_opt := Some v), "Application ID")
    ; ("--secret", Arg.String (fun v -> scr_opt := Some v), "Application secret")
    ; ("--token", Arg.String (fun v -> tkn_opt := Some v), "User token") ] in
  Arg.parse specs (fun _ -> ()) usage;
  (*
   * Check arguments.
   *)
  match (!aid_opt, !scr_opt, !tkn_opt) with
  | Some id, Some secret, None -> (
    let op = Check.app id secret in
    match Lwt_main.run op with
    | Ok _ -> Logs.app (fun m -> m "Success")
    | Error err -> Logs.err (fun m -> m "%a" Check.App.Error.pp err))
  | None, None, Some token -> (
    let session = Dropbox.Session.make token in
    let op = Check.user ~session () in
    match Lwt_main.run op with
    | Ok _ -> Logs.app (fun m -> m "Success")
    | Error err -> Logs.err (fun m -> m "%a" Check.User.Error.pp err))
  | _ -> Logs.err (fun m -> m "Invalid options")
