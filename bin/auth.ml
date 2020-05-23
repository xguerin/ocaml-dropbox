module Auth = Dropbox.Auth.S (Cohttp_lwt_unix.Client)

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
    Usage: auth [--id APP_ID [--secret APP_SECRET --code AUTH]]
                [--revoke BEARER]
     |usage}
  and aid_opt = ref None
  and scr_opt = ref None
  and cde_opt = ref None
  and rvk_opt = ref None in
  let specs =
    [ ("--id", Arg.String (fun v -> aid_opt := Some v), "Application ID")
    ; ("--secret", Arg.String (fun v -> scr_opt := Some v), "Application secret")
    ; ("--code", Arg.String (fun v -> cde_opt := Some v), "Authentication code")
    ; ("--revoke", Arg.String (fun v -> rvk_opt := Some v), "Revoke token") ]
  in
  Arg.parse specs (fun _ -> ()) usage;
  (*
   * Check arguments.
   *)
  match (!aid_opt, !scr_opt, !cde_opt, !rvk_opt) with
  | Some id, None, None, None ->
    let uri = Auth.authorize ~id (`Code None) in
    Logs.app (fun m -> m "%s" (Uri.to_string uri))
  | Some id, Some secret, Some code, None -> (
    let op = Auth.token ~id ~secret code in
    match Lwt_main.run op with
    | Ok session -> Logs.app (fun m -> m "%s" session.Dropbox.Session.token)
    | Error err -> Logs.err (fun m -> m "%a" Dropbox.Error.pp err))
  | None, None, None, Some token -> (
    let session = Dropbox.Session.make token in
    let op = Auth.revoke session in
    match Lwt_main.run op with
    | Ok _ -> Logs.app (fun m -> m "Revoked")
    | Error err -> Logs.err (fun m -> m "%a" Dropbox.Error.pp err))
  | _ -> Logs.err (fun m -> m "Invalid options")
