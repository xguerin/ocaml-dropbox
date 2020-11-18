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

open Ppxlib
open Ast_helper
open Ast_builder.Default
open Parsetree

(*
 * Aliases.
 *)

let raise = Ppx_deriving.raise_errorf

(*
 * Option parser.
 *)

module Options = struct
  type mode =
    | Union
    | SubType

  type t = {mode : mode}

  let parse options =
    List.fold_left
      (fun agg o ->
        match o with
        | "mode", [%expr Union] -> {mode = Union}
        | "mode", [%expr SubType] -> {mode = SubType}
        | "mode", {pexp_loc = loc; _} -> raise ~loc "[dropbox] Union | SubType"
        | _ -> agg)
      {mode = Union} options
end

(*
 * Of YoJson.
 *)

module OfYojson = struct
  let convert_variant_to_case_as_union = function
    (* Variant constructor without argument *)
    | {pcd_name = {txt; _}; pcd_loc = loc; pcd_args = Pcstr_tuple []; _} ->
      let lc_name = String.lowercase_ascii txt in
      [ Exp.case
          [%pat?
            `Assoc
              [([%p pstring ~loc ".tag"], `String [%p pstring ~loc lc_name])]]
          [%expr Ok [%e Exp.construct (Located.lident ~loc txt) None]]
      ; Exp.case
          [%pat? `String [%p pstring ~loc lc_name]]
          [%expr Ok [%e Exp.construct (Located.lident ~loc txt) None]] ]
    (* Variant constructor with a bool argument *)
    | { pcd_name = {txt = name; _}
      ; pcd_loc = loc
      ; pcd_args =
          Pcstr_tuple
            [{ptyp_desc = Ptyp_constr ({txt = Lident "bool"; _}, []); _}]
      ; _ } ->
      let lc_name = String.lowercase_ascii name in
      [ Exp.case
          [%pat?
            `Assoc
              [ ([%p pstring ~loc ".tag"], `String [%p pstring ~loc lc_name])
              ; ([%p pstring ~loc lc_name], `Bool [%p pvar ~loc lc_name]) ]]
          [%expr
            Ok
              [%e
                Exp.construct (Located.lident ~loc name)
                  (Some (evar ~loc lc_name))]] ]
    (* Variant constructor with a string argument *)
    | { pcd_name = {txt = name; _}
      ; pcd_loc = loc
      ; pcd_args =
          Pcstr_tuple
            [{ptyp_desc = Ptyp_constr ({txt = Lident "string"; _}, []); _}]
      ; _ } ->
      let lc_name = String.lowercase_ascii name in
      [ Exp.case
          [%pat?
            `Assoc
              [ ([%p pstring ~loc ".tag"], `String [%p pstring ~loc lc_name])
              ; ([%p pstring ~loc lc_name], `String [%p pvar ~loc lc_name]) ]]
          [%expr
            Ok
              [%e
                Exp.construct (Located.lident ~loc name)
                  (Some (evar ~loc lc_name))]] ]
    (* Variant constructor with a string option argument *)
    | { pcd_name = {txt = name; _}
      ; pcd_loc = loc
      ; pcd_args =
          Pcstr_tuple
            [ { ptyp_desc =
                  Ptyp_constr
                    ( {txt = Lident "option"; _}
                    , [ { ptyp_desc =
                            Ptyp_constr ({txt = Lident "string"; _}, [])
                        ; _ } ] )
              ; _ } ]
      ; _ } ->
      let lc_name = String.lowercase_ascii name in
      [ Exp.case
          [%pat?
            `Assoc
              [([%p pstring ~loc ".tag"], `String [%p pstring ~loc lc_name])]]
          [%expr
            Ok
              [%e
                Exp.construct (Located.lident ~loc name)
                  (Some (Exp.construct (Located.lident ~loc "None") None))]]
      ; Exp.case
          [%pat?
            `Assoc
              [ ([%p pstring ~loc ".tag"], `String [%p pstring ~loc lc_name])
              ; ([%p pstring ~loc lc_name], `String [%p pvar ~loc lc_name]) ]]
          [%expr
            Ok
              [%e
                Exp.construct (Located.lident ~loc name)
                  (Some
                     (Exp.construct
                        (Located.lident ~loc "Some")
                        (Some (evar ~loc lc_name))))]] ]
    (* Variant constructor with a string list argument *)
    | { pcd_name = {txt = name; _}
      ; pcd_loc = loc
      ; pcd_args =
          Pcstr_tuple
            [ { ptyp_desc =
                  Ptyp_constr
                    ( {txt = Lident "list"; _}
                    , [ { ptyp_desc =
                            Ptyp_constr ({txt = Lident "string"; _}, [])
                        ; _ } ] )
              ; _ } ]
      ; _ } ->
      let lc_name = String.lowercase_ascii name in
      [ Exp.case
          [%pat?
            `Assoc
              [ ([%p pstring ~loc ".tag"], `String [%p pstring ~loc lc_name])
              ; ([%p pstring ~loc lc_name], `List [%p pvar ~loc lc_name]) ]]
          [%expr
            let result =
              List.fold_right
                (fun e acc -> match e with `String v -> v :: acc | _ -> acc)
                [%e evar ~loc lc_name] [] in
            Ok
              [%e
                Exp.construct (Located.lident ~loc name)
                  (Some (evar ~loc "result"))]] ]
    (* Variant constructor with a Type.t argument *)
    | { pcd_name = {txt = name; _}
      ; pcd_loc = loc
      ; pcd_args =
          Pcstr_tuple
            [{ptyp_desc = Ptyp_constr ({txt = Ldot (base, _); _}, _); _}]
      ; _ } ->
      let of_yojson = Exp.ident {txt = Ldot (base, "of_yojson"); loc} in
      let lc_name = String.lowercase_ascii name in
      [ Exp.case
          [%pat?
            `Assoc
              [ ([%p pstring ~loc ".tag"], `String [%p pstring ~loc lc_name])
              ; ([%p pstring ~loc lc_name], [%p pvar ~loc lc_name]) ]]
          [%expr
            match [%e Exp.apply of_yojson [(Nolabel, evar ~loc lc_name)]] with
            | Ok v ->
              Ok
                [%e
                  Exp.construct (Located.lident ~loc name)
                    (Some (evar ~loc "v"))]
            | Error _ as e -> e] ]
    (* Variant constructor with a Type.t option argument *)
    | { pcd_name = {txt = name; _}
      ; pcd_loc = loc
      ; pcd_args =
          Pcstr_tuple
            [ { ptyp_desc =
                  Ptyp_constr
                    ( {txt = Lident "option"; _}
                    , [ { ptyp_desc = Ptyp_constr ({txt = Ldot (base, _); _}, _)
                        ; _ } ] )
              ; _ } ]
      ; _ } ->
      let of_yojson = Exp.ident {txt = Ldot (base, "of_yojson"); loc} in
      let lc_name = String.lowercase_ascii name in
      [ Exp.case
          [%pat?
            `Assoc
              [([%p pstring ~loc ".tag"], `String [%p pstring ~loc lc_name])]]
          [%expr
            Ok
              [%e
                Exp.construct (Located.lident ~loc name)
                  (Some (Exp.construct (Located.lident ~loc "None") None))]]
      ; Exp.case
          [%pat?
            `Assoc
              [ ([%p pstring ~loc ".tag"], `String [%p pstring ~loc lc_name])
              ; ([%p pstring ~loc lc_name], [%p pvar ~loc lc_name]) ]]
          [%expr
            match [%e Exp.apply of_yojson [(Nolabel, evar ~loc lc_name)]] with
            | Ok v ->
              Ok
                [%e
                  Exp.construct (Located.lident ~loc name)
                    (Some
                       (Exp.construct
                          (Located.lident ~loc "Some")
                          (Some (evar ~loc "v"))))]
            | Error _ as e -> e] ]
    (* Error *)
    | {pcd_name = {loc; _}; _} ->
      raise ~loc "[dropbox] invalid Union constructor"

  let convert_variant_to_case_as_subtype = function
    | { pcd_name = {txt = name; _}
      ; pcd_loc = loc
      ; pcd_args =
          Pcstr_tuple
            [{ptyp_desc = Ptyp_constr ({txt = Ldot (base, _); _}, _); _}]
      ; _ } ->
      let of_yojson = Exp.ident {txt = Ldot (base, "of_yojson"); loc} in
      let lc_name = String.lowercase_ascii name in
      [ Exp.case
          [%pat?
            `Assoc
              (([%p pstring ~loc ".tag"], `String [%p pstring ~loc lc_name])
              :: tl)]
          [%expr
            match
              [%e
                Exp.apply of_yojson
                  [(Nolabel, Exp.variant "Assoc" (Some (evar ~loc "tl")))]]
            with
            | Ok v ->
              Ok
                [%e
                  Exp.construct (Located.lident ~loc name)
                    (Some (evar ~loc "v"))]
            | Error _ as e -> e] ]
    | {pcd_loc = loc; _} -> raise ~loc "[dropbox] invalid Subtype constructor"

  let default_case ~loc () =
    [Exp.case [%pat? _] [%expr Error [%e estring ~loc "invalid format"]]]

  let convert_variant_to_case ~options variant =
    match options.Options.mode with
    | Union -> convert_variant_to_case_as_union variant
    | SubType -> convert_variant_to_case_as_subtype variant

  let convert_variants_to_match ~options ~loc variants =
    let cases = List.map (convert_variant_to_case ~options) variants in
    let default = default_case ~loc () in
    Exp.match_ (evar ~loc "w") (List.concat cases @ default)

  let gen ~options ~loc variants =
    let match_ = convert_variants_to_match ~options ~loc variants in
    [%expr
      fun v ->
        let w = Yojson.Safe.sort v in
        [%e match_]]
end

(*
 * To YoJson.
 *)

module ToYojson = struct
  let make_tagged_bool ~loc lc_name =
    [%expr
      `Assoc
        [ ([%e estring ~loc ".tag"], `String [%e estring ~loc lc_name])
        ; ([%e estring ~loc lc_name], `Bool [%e evar ~loc lc_name]) ]]

  let make_tagged_string ~loc lc_name =
    [%expr
      `Assoc
        [ ([%e estring ~loc ".tag"], `String [%e estring ~loc lc_name])
        ; ([%e estring ~loc lc_name], `String [%e evar ~loc lc_name]) ]]

  let make_tagged_string_none ~loc lc_name =
    [%expr
      `Assoc [([%e estring ~loc ".tag"], `String [%e estring ~loc lc_name])]]

  let make_tagged_string_list ~loc lc_name =
    [%expr
      `Assoc
        [ ([%e estring ~loc ".tag"], `String [%e estring ~loc lc_name])
        ; ( [%e estring ~loc lc_name]
          , `List (List.map (fun e -> `String e) [%e evar ~loc lc_name]) ) ]]

  let make_yojson_as_union ~loc to_yojson lc_name =
    [%expr
      `Assoc
        [ ([%e estring ~loc ".tag"], `String [%e estring ~loc lc_name])
        ; ( [%e estring ~loc lc_name]
          , [%e Exp.apply to_yojson [(Asttypes.Nolabel, evar ~loc lc_name)]] )
        ]]

  let make_yojson_as_subtype ~loc to_yojson lc_name =
    [%expr
      match
        [%e Exp.apply to_yojson [(Asttypes.Nolabel, evar ~loc lc_name)]]
      with
      | `Assoc tl ->
        `Assoc
          (([%e estring ~loc ".tag"], `String [%e estring ~loc lc_name]) :: tl)
      | _ -> `Null]

  let convert_variant_to_case_as_union = function
    (* Variant constructor without argument *)
    | {pcd_name = {txt; _}; pcd_loc = loc; pcd_args = Pcstr_tuple []; _} ->
      let lc_name = String.lowercase_ascii txt in
      [ Exp.case
          (Pat.construct (Located.lident ~loc txt) None)
          (Exp.variant "String" (Some (estring ~loc lc_name))) ]
    (* Variant constructor with a bool argument *)
    | { pcd_name = {txt = name; _}
      ; pcd_loc = loc
      ; pcd_args =
          Pcstr_tuple
            [{ptyp_desc = Ptyp_constr ({txt = Lident "bool"; _}, []); _}]
      ; _ } ->
      let lc_name = String.lowercase_ascii name in
      [ Exp.case
          (Pat.construct (Located.lident ~loc name) (Some (pvar ~loc lc_name)))
          (make_tagged_bool ~loc lc_name) ]
    (* Variant constructor with a string argument *)
    | { pcd_name = {txt = name; _}
      ; pcd_loc = loc
      ; pcd_args =
          Pcstr_tuple
            [{ptyp_desc = Ptyp_constr ({txt = Lident "string"; _}, []); _}]
      ; _ } ->
      let lc_name = String.lowercase_ascii name in
      [ Exp.case
          (Pat.construct (Located.lident ~loc name) (Some (pvar ~loc lc_name)))
          (make_tagged_string ~loc lc_name) ]
    (* Variant constructor with a string option argument *)
    | { pcd_name = {txt = name; _}
      ; pcd_loc = loc
      ; pcd_args =
          Pcstr_tuple
            [ { ptyp_desc =
                  Ptyp_constr
                    ( {txt = Lident "option"; _}
                    , [ { ptyp_desc =
                            Ptyp_constr ({txt = Lident "string"; _}, [])
                        ; _ } ] )
              ; _ } ]
      ; _ } ->
      let lc_name = String.lowercase_ascii name in
      [ Exp.case
          (Pat.construct (Located.lident ~loc name)
             (Some
                (Pat.construct
                   (Located.lident ~loc "Some")
                   (Some (pvar ~loc lc_name)))))
          (make_tagged_string ~loc lc_name)
      ; Exp.case
          (Pat.construct (Located.lident ~loc name)
             (Some (Pat.construct (Located.lident ~loc "None") None)))
          (make_tagged_string_none ~loc lc_name) ]
    (* Variant constructor with a string list argument *)
    | { pcd_name = {txt = name; _}
      ; pcd_loc = loc
      ; pcd_args =
          Pcstr_tuple
            [ { ptyp_desc =
                  Ptyp_constr
                    ( {txt = Lident "list"; _}
                    , [ { ptyp_desc =
                            Ptyp_constr ({txt = Lident "string"; _}, [])
                        ; _ } ] )
              ; _ } ]
      ; _ } ->
      let lc_name = String.lowercase_ascii name in
      [ Exp.case
          (Pat.construct (Located.lident ~loc name) (Some (pvar ~loc lc_name)))
          (make_tagged_string_list ~loc lc_name) ]
    (* Variant constructor with a Type.t argument *)
    | { pcd_name = {txt = name; _}
      ; pcd_loc = loc
      ; pcd_args =
          Pcstr_tuple
            [{ptyp_desc = Ptyp_constr ({txt = Ldot (base, _); _}, _); _}]
      ; _ } ->
      let to_yojson = Exp.ident {txt = Ldot (base, "to_yojson"); loc} in
      let lc_name = String.lowercase_ascii name in
      [ Exp.case
          (Pat.construct (Located.lident ~loc name) (Some (pvar ~loc lc_name)))
          (make_yojson_as_union ~loc to_yojson lc_name) ]
    (* Variant constructor with a Type.t option argument *)
    | { pcd_name = {txt = name; _}
      ; pcd_loc = loc
      ; pcd_args =
          Pcstr_tuple
            [ { ptyp_desc =
                  Ptyp_constr
                    ( {txt = Lident "option"; _}
                    , [ { ptyp_desc = Ptyp_constr ({txt = Ldot (base, _); _}, _)
                        ; _ } ] )
              ; _ } ]
      ; _ } ->
      let to_yojson = Exp.ident {txt = Ldot (base, "to_yojson"); loc} in
      let lc_name = String.lowercase_ascii name in
      [ Exp.case
          (Pat.construct (Located.lident ~loc name)
             (Some
                (Pat.construct
                   (Located.lident ~loc "Some")
                   (Some (pvar ~loc lc_name)))))
          (make_yojson_as_union ~loc to_yojson lc_name)
      ; Exp.case
          (Pat.construct (Located.lident ~loc name)
             (Some (Pat.construct (Located.lident ~loc "None") None)))
          (make_tagged_string_none ~loc lc_name) ]
    | {pcd_name = {loc; _}; _} ->
      raise ~loc "[dropbox] invalid Union constructor"

  let convert_variant_to_case_as_subtype = function
    | { pcd_name = {txt = name; _}
      ; pcd_loc = loc
      ; pcd_args =
          Pcstr_tuple
            [{ptyp_desc = Ptyp_constr ({txt = Ldot (base, _); _}, _); _}]
      ; _ } ->
      let to_yojson = Exp.ident {txt = Ldot (base, "to_yojson"); loc} in
      let lc_name = String.lowercase_ascii name in
      [ Exp.case
          (Pat.construct (Located.lident ~loc name) (Some (pvar ~loc lc_name)))
          (make_yojson_as_subtype ~loc to_yojson lc_name) ]
    | {pcd_loc = loc; _} -> raise ~loc "[dropbox] invalid Subtype constructor"

  let convert_variant_to_case ~options variant =
    match options.Options.mode with
    | Union -> convert_variant_to_case_as_union variant
    | SubType -> convert_variant_to_case_as_subtype variant

  let convert_variants_to_match ~options ~loc variants =
    let cases = List.map (convert_variant_to_case ~options) variants in
    Exp.match_ (evar ~loc "v") (List.concat cases)

  let gen ~options ~loc variants =
    let match_ = convert_variants_to_match ~options ~loc variants in
    [%expr fun v -> [%e match_]]
end

(*
 * Top-level deriver.
 *)

let str_of_type ~options ~path:_ ({ptype_loc = loc; _} as type_decl) =
  let options = Options.parse options in
  match type_decl.ptype_kind with
  | Ptype_variant constrs ->
    let of_yojson = OfYojson.gen ~options ~loc constrs
    and to_yojson = ToYojson.gen ~options ~loc constrs in
    [ Str.value Nonrecursive [Vb.mk (pvar ~loc "of_yojson") of_yojson]
    ; Str.value Nonrecursive [Vb.mk (pvar ~loc "to_yojson") to_yojson] ]
  | _ -> raise ~loc "[dropbox] only supports Variant types"

let type_decl_str ~options ~path type_decls =
  List.concat (List.map (str_of_type ~options ~path) type_decls)

let () =
  let open Ppx_deriving in
  register @@ create "dropbox" ~type_decl_str ()
