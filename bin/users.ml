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
    Users.get_current_account ~session ()
    >>=? fun Users.GetCurrentAccount.Result.Type.{name = {display_name; _}; _} ->
    Users.get_space_usage ~session ()
    >>=? fun Users.GetSpaceUsage.Result.Type.
               {used; allocation = {allocated; _}; _} ->
    Logs_lwt.app (fun m -> m "%s, %Ld/%Ld" display_name used allocated)
    >>= Lwt.return_ok in
  match Lwt_main.run op with
  | Ok () -> ()
  | Error err -> Logs.err (fun m -> m "%a" Users.GetCurrentAccount.Error.pp err)
