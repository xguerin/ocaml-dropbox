open Dropbox.Infix
open Dropbox_lwt_unix
open Lwt.Infix

let copy ~session path = function
  | Some target -> (
    match%lwt Files.copy ~session path target with
    | Ok _ -> Lwt.return ()
    | Error e -> Logs_lwt.err (fun m -> m "%a" Files.Copy.Error.pp e))
  | None -> failwith "The --target option must be set"

let delete ~session path =
  match%lwt Files.delete ~session path with
  | Ok _ -> Lwt.return ()
  | Error e -> Logs_lwt.err (fun m -> m "%a" Files.Delete.Error.pp e)

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

let get_metadata ~session path =
  match%lwt Files.get_metadata ~session path with
  | Ok metadata -> (
    Files.GetMetadata.Result.(
      match metadata with
      | Type.Deleted _ -> Logs_lwt.info (fun m -> m "Deleted")
      | Type.File _ -> Logs_lwt.info (fun m -> m "File")
      | Type.Folder _ -> Logs_lwt.info (fun m -> m "Folder")))
  | Error e -> Logs_lwt.err (fun m -> m "%a" Files.GetMetadata.Error.pp e)

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

let create_folder ~session path =
  match%lwt Files.create_folder ~session path with
  | Ok _ -> Lwt.return ()
  | Error e -> Logs_lwt.err (fun m -> m "%a" Files.CreateFolder.Error.pp e)

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

let rec search_continue ~session cursor =
  let open Files.SearchContinue in
  let module Error = Files.SearchContinue.Error in
  match%lwt Files.search_continue ~session cursor with
  | Ok Result.Type.{matches; has_more = true; cursor = Some cursor} -> (
    match%lwt search_continue ~session cursor with
    | Ok rest -> Lwt.return_ok (matches @ rest)
    | Error e -> Lwt.return_error e)
  | Ok Result.Type.{matches; _} -> Lwt.return_ok matches
  | Error e -> Lwt.return_error e

let display_matches lst =
  let module Match = Files.Protocol.SearchMatchV2 in
  let%lwt () =
    Logs_lwt.info (fun m -> m "%d match(es) found" (List.length lst)) in
  Lwt_list.iter_s
    (fun Match.Type.{metadata = Metadata meta; _} ->
      match meta with
      | File {path_display = Some path; _} ->
        Logs_lwt.app (fun m -> m "%s" path)
      | _ -> Lwt.return ())
    lst

let search ~session ~path = function
  | Some query -> (
    let open Files.Search in
    let module Error = Files.Search.Error in
    match%lwt Files.search ~path ~session query with
    | Ok Result.Type.{matches; has_more = true; cursor = Some cursor} -> (
      match%lwt search_continue ~session cursor with
      | Ok rest -> display_matches (matches @ rest)
      | Error e -> Logs_lwt.err (fun m -> m "%a" Error.pp e))
    | Ok Result.Type.{matches; _} -> display_matches matches
    | Error e -> Logs_lwt.err (fun m -> m "%a" Error.pp e))
  | None -> failwith "The --query option must be set"

let upload ~session path = function
  | Some target -> (
    let module Error = Files.Upload.Error in
    let%lwt result =
      Lwt_io.open_file ~mode:Input path
      >>= fun channel ->
      let ci = Files.Protocol.CommitInfo.make target in
      Files.upload ~session ci (`Stream (Lwt_io.read_lines channel)) in
    match result with
    | Ok _ -> Lwt.return ()
    | Error e -> Logs_lwt.err (fun m -> m "%a" Error.pp e))
  | None -> failwith "The --target option must be set"

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
  and qry_opt = ref None
  and tgt_opt = ref None in
  let specs =
    [ ("--cmd", Arg.String (fun v -> cmd_opt := Some v), "Command")
    ; ("--token", Arg.String (fun v -> tkn_opt := Some v), "User token")
    ; ("--path", Arg.String (fun v -> pth_opt := Some v), "File path")
    ; ("--query", Arg.String (fun v -> qry_opt := Some v), "Search query")
    ; ("--target", Arg.String (fun v -> tgt_opt := Some v), "File target") ]
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
    | "copy" -> copy ~session path !tgt_opt
    | "delete" -> delete ~session path
    | "download" -> download ~session path
    | "download_zip" -> download_zip ~session path
    | "get_metadata" -> get_metadata ~session path
    | "get_thumbnail" -> get_thumbnail ~session path
    | "create_folder" -> create_folder ~session path
    | "list_folder" -> list_folder ~session path
    | "search" -> search ~session ~path !qry_opt
    | "upload" -> upload ~session path !tgt_opt
    | _ -> failwith "Invalid command" in
  Lwt_main.run op
