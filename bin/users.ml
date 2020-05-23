open Dropbox.Infix
open Lwt.Infix
module Users = Dropbox.Users.S (Cohttp_lwt_unix.Client)

let () =
  (*
   * Declare log reporter and level.
   *)
  Logs.set_reporter (Logs.format_reporter ());
  Logs.set_level (Some Logs.Info);
  (*
   * Command line.
   *)
  let usage = "Usage: info --token BEARER"
  and tkn_opt = ref None in
  let specs =
    [("--token", Arg.String (fun v -> tkn_opt := Some v), "User token")] in
  Arg.parse specs (fun _ -> ()) usage;
  (*
   * Check arguments.
   *)
  let token =
    match !tkn_opt with
    | Some token -> token
    | None -> failwith "The --token option must be set" in
  (*
   * Query user info.
   *)
  let session = Dropbox.Session.make token in
  let op =
    Users.get_current_account session
    >>=? fun name ->
    Users.get_space_usage session
    >>=? fun (used, allocated) ->
    Logs_lwt.app (fun m -> m "%s, %Ld/%Ld" name.display_name used allocated)
    >>= Lwt.return_ok in
  match Lwt_main.run op with
  | Ok () -> ()
  | Error err -> Logs.err (fun m -> m "%a" Dropbox.Error.pp err)
