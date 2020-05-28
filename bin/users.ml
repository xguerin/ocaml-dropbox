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
    >>=? fun Users.GetCurrentAccount.Result.Type.{name = {display_name; _}; _} ->
    Users.get_space_usage session
    >>=? fun Users.GetSpaceUsage.Result.Type.
               {used; allocation = {allocated; _}; _} ->
    Logs_lwt.app (fun m -> m "%s, %Ld/%Ld" display_name used allocated)
    >>= Lwt.return_ok in
  match Lwt_main.run op with
  | Ok () -> ()
  | Error err -> Logs.err (fun m -> m "%a" Users.GetCurrentAccount.Error.pp err)
