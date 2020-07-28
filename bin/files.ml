open Dropbox.Infix
open Dropbox_lwt_unix
open Lwt.Infix

let download ~session path =
  let%lwt result =
    Files.download ~session path
    >>=? fun ({name; _}, body) ->
    Lwt_io.open_file ~mode:Output name
    >>= fun channel ->
    Lwt_io.write_lines channel @@ Cohttp_lwt.Body.to_stream body
    >>= fun () -> Lwt_io.close channel >>= Lwt.return_ok in
  match result with
  | Ok () -> Lwt.return ()
  | Error e -> Logs_lwt.err (fun m -> m "%a" Files.Download.Error.pp e)

let download_zip ~session path =
  let%lwt result =
    Files.download_zip ~session path
    >>=? fun ({metadata = {name; _}}, body) ->
    Lwt_io.open_file ~mode:Output (name ^ ".zip")
    >>= fun channel ->
    Lwt_io.write_lines channel @@ Cohttp_lwt.Body.to_stream body
    >>= fun () -> Lwt_io.close channel >>= Lwt.return_ok in
  match result with
  | Ok () -> Lwt.return ()
  | Error e -> Logs_lwt.err (fun m -> m "%a" Files.DownloadZip.Error.pp e)

let get_thumbnail ~session path =
  let%lwt result =
    Files.get_thumbnail ~format:Png ~size:W128H128 ~mode:Strict ~session
      (Path path)
    >>=? fun (metadata, body) ->
    match metadata with
    | {file_metadata = Some {name; _}; _} ->
      Lwt_io.open_file ~mode:Output name
      >>= fun channel ->
      Lwt_io.write_lines channel @@ Cohttp_lwt.Body.to_stream body
      >>= fun () -> Lwt_io.close channel >>= Lwt.return_ok
    | _ -> Lwt.return_error Files.GetThumbnail.Error.Unknown in
  match result with
  | Ok () -> Lwt.return ()
  | Error e -> Logs_lwt.err (fun m -> m "%a" Files.GetThumbnail.Error.pp e)

let rec list_folder_continue ~fn ~session cursor =
  let open Files.ListFolderContinue in
  let module Error = Files.ListFolderContinue.Error in
  match%lwt Files.list_folder_continue ~session cursor with
  | Ok Result.Type.{entries; cursor; has_more} ->
    let%lwt () = Lwt_list.iter_s fn entries in
    if has_more then list_folder_continue ~fn ~session cursor else Lwt.return ()
  | Error e -> Logs_lwt.err (fun m -> m "%a" Error.pp e)

let list_folder ~session path =
  let open Files.ListFolder in
  let module Error = Files.ListFolder.Error in
  let module Metadata = Files.Protocol.Metadata in
  let callback = function
    | Metadata.Type.Deleted {name; _} -> Logs_lwt.app (fun m -> m "x %s" name)
    | Metadata.Type.File {name; _} -> Logs_lwt.app (fun m -> m "r %s" name)
    | Metadata.Type.Folder {name; _} -> Logs_lwt.app (fun m -> m "d %s" name)
  in
  match%lwt Files.list_folder ~session path with
  | Ok Result.Type.{entries; cursor; has_more} ->
    let%lwt () = Lwt_list.iter_s callback entries in
    if has_more
    then list_folder_continue ~fn:callback ~session cursor
    else Lwt.return ()
  | Error e -> Logs_lwt.err (fun m -> m "%a" Error.pp e)

let search ~session ?path = function
  | Some query -> (
    let open Files.Search in
    let module Error = Files.Search.Error in
    match%lwt Files.search ~session ~path query with
    | Ok Result.Type.{matches; _} ->
      Logs_lwt.info (fun m -> m "%d match(es) found" (List.length matches))
    | Error e -> Logs_lwt.err (fun m -> m "%a" Error.pp e))
  | None -> failwith "The --query option must be set"

let () =
  (*
   * Declare log reporter and level.
   *)
  Logs.set_reporter (Logs.format_reporter ());
  Logs.set_level (Some Logs.Info);
  (*
   * Command line.
   *)
  let usage = "Usage: files [-z] --token BEARER --path PATH"
  and cmd_opt = ref None
  and tkn_opt = ref None
  and pth_opt = ref None
  and qry_opt = ref None in
  let specs =
    [ ("--cmd", Arg.String (fun v -> cmd_opt := Some v), "Command")
    ; ("--token", Arg.String (fun v -> tkn_opt := Some v), "User token")
    ; ("--path", Arg.String (fun v -> pth_opt := Some v), "File path")
    ; ("--query", Arg.String (fun v -> qry_opt := Some v), "Search query") ]
  in
  Arg.parse specs (fun _ -> ()) usage;
  (*
   * Check arguments.
   *)
  let cmd =
    match !cmd_opt with
    | Some token -> token
    | None -> failwith "The --cmd option must be set"
  and token =
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
    match cmd with
    | "download" -> download ~session path
    | "download_zip" -> download_zip ~session path
    | "get_thumbnail" -> get_thumbnail ~session path
    | "list_folder" -> list_folder ~session path
    | "search" -> search ~session ~path !qry_opt
    | _ -> failwith "Invalid command" in
  Lwt_main.run op
