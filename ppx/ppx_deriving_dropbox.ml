open Ast_helper
open Ast_convenience
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
          [%pat? `Assoc [([%p pstr ".tag"], `String [%p pstr lc_name])]]
          [%expr Ok [%e Exp.construct (lid txt) None]]
      ; Exp.case
          [%pat? `String [%p pstr lc_name]]
          [%expr Ok [%e Exp.construct (lid txt) None]] ]
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
              [ ([%p pstr ".tag"], `String [%p pstr lc_name])
              ; ([%p pstr lc_name], `String [%p pvar lc_name]) ]]
          [%expr Ok [%e Exp.construct (lid name) (Some (evar lc_name))]] ]
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
          [%pat? `Assoc [([%p pstr ".tag"], `String [%p pstr lc_name])]]
          [%expr
            Ok
              [%e
                Exp.construct (lid name)
                  (Some (Exp.construct (lid "None") None))]]
      ; Exp.case
          [%pat?
            `Assoc
              [ ([%p pstr ".tag"], `String [%p pstr lc_name])
              ; ([%p pstr lc_name], `String [%p pvar lc_name]) ]]
          [%expr
            Ok
              [%e
                Exp.construct (lid name)
                  (Some (Exp.construct (lid "Some") (Some (evar lc_name))))]] ]
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
              [ ([%p pstr ".tag"], `String [%p pstr lc_name])
              ; ([%p pstr lc_name], `List [%p pvar lc_name]) ]]
          [%expr
            let result =
              List.fold_right
                (fun e acc -> match e with `String v -> v :: acc | _ -> acc)
                [%e evar lc_name] [] in
            Ok [%e Exp.construct (lid name) (Some (evar "result"))]] ]
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
              [ ([%p pstr ".tag"], `String [%p pstr lc_name])
              ; ([%p pstr lc_name], [%p pvar lc_name]) ]]
          [%expr
            match [%e Exp.apply of_yojson [(Nolabel, evar lc_name)]] with
            | Ok v -> Ok [%e Exp.construct (lid name) (Some (evar "v"))]
            | Error _ as e -> e] ]
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
          [%pat? `Assoc (([%p pstr ".tag"], `String [%p pstr lc_name]) :: tl)]
          [%expr
            match
              [%e
                Exp.apply of_yojson
                  [(Nolabel, Exp.variant "Assoc" (Some (evar "tl")))]]
            with
            | Ok v -> Ok [%e Exp.construct (lid name) (Some (evar "v"))]
            | Error _ as e -> e] ]
    | {pcd_loc = loc; _} -> raise ~loc "[dropbox] invalid Subtype constructor"

  let default_case ~loc () =
    [Exp.case [%pat? _] [%expr Error [%e str "invalid format"]]]

  let convert_variant_to_case ~options variant =
    match options.Options.mode with
    | Union -> convert_variant_to_case_as_union variant
    | SubType -> convert_variant_to_case_as_subtype variant

  let convert_variants_to_match ~options ~loc variants =
    let cases = List.map (convert_variant_to_case ~options) variants in
    let default = default_case ~loc () in
    Exp.match_ (evar "w") (List.concat cases @ default)

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
  let make_tagged_string ~loc lc_name =
    [%expr
      `Assoc
        [ ([%e str ".tag"], `String [%e str lc_name])
        ; ([%e str lc_name], `String [%e evar lc_name]) ]]

  let make_tagged_string_none ~loc lc_name =
    [%expr `Assoc [([%e str ".tag"], `String [%e str lc_name])]]

  let make_tagged_string_list ~loc lc_name =
    [%expr
      `Assoc
        [ ([%e str ".tag"], `String [%e str lc_name])
        ; ( [%e str lc_name]
          , `List (List.map (fun e -> `String e) [%e evar lc_name]) ) ]]

  let make_yojson_as_union ~loc to_yojson lc_name =
    [%expr
      `Assoc
        [ ([%e str ".tag"], `String [%e str lc_name])
        ; ( [%e str lc_name]
          , [%e Exp.apply to_yojson [(Asttypes.Nolabel, evar lc_name)]] ) ]]

  let make_yojson_as_subtype ~loc to_yojson lc_name =
    [%expr
      match [%e Exp.apply to_yojson [(Asttypes.Nolabel, evar lc_name)]] with
      | `Assoc tl -> `Assoc (([%e str ".tag"], `String [%e str lc_name]) :: tl)
      | _ -> `Null]

  let convert_variant_to_case_as_union = function
    (* Variant constructor without argument *)
    | {pcd_name = {txt; _}; pcd_args = Pcstr_tuple []; _} ->
      let lc_name = String.lowercase_ascii txt in
      [ Exp.case
          (Pat.construct (lid txt) None)
          (Exp.variant "String" (Some (str lc_name))) ]
    (* Variant constructor with a string argument *)
    | { pcd_name = {txt = name; _}
      ; pcd_loc = loc
      ; pcd_args =
          Pcstr_tuple
            [{ptyp_desc = Ptyp_constr ({txt = Lident "string"; _}, []); _}]
      ; _ } ->
      let lc_name = String.lowercase_ascii name in
      [ Exp.case
          (Pat.construct (lid name) (Some (pvar lc_name)))
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
          (Pat.construct (lid name)
             (Some (Pat.construct (lid "Some") (Some (pvar lc_name)))))
          (make_tagged_string ~loc lc_name)
      ; Exp.case
          (Pat.construct (lid name) (Some (Pat.construct (lid "None") None)))
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
          (Pat.construct (lid name) (Some (pvar lc_name)))
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
          (Pat.construct (lid name) (Some (pvar lc_name)))
          (make_yojson_as_union ~loc to_yojson lc_name) ]
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
          (Pat.construct (lid name) (Some (pvar lc_name)))
          (make_yojson_as_subtype ~loc to_yojson lc_name) ]
    | {pcd_loc = loc; _} -> raise ~loc "[dropbox] invalid Subtype constructor"

  let convert_variant_to_case ~options variant =
    match options.Options.mode with
    | Union -> convert_variant_to_case_as_union variant
    | SubType -> convert_variant_to_case_as_subtype variant

  let convert_variants_to_match ~options variants =
    let cases = List.map (convert_variant_to_case ~options) variants in
    Exp.match_ (evar "v") (List.concat cases)

  let gen ~options ~loc variants =
    let match_ = convert_variants_to_match ~options variants in
    [%expr fun v -> [%e match_]]
end

(*
 * Top-level deriver.
 *)

let str_of_type ~options ~path:_ ({ptype_loc = loc; _} as type_decl) =
  let options = Options.parse options in
  match type_decl.ptype_kind with
  | Ptype_variant constrs ->
    let of_yojson = OfYojson.gen ~options ~loc constrs in
    let to_yojson = ToYojson.gen ~options ~loc constrs in
    [ Str.value Nonrecursive [Vb.mk (pvar "of_yojson") of_yojson]
    ; Str.value Nonrecursive [Vb.mk (pvar "to_yojson") to_yojson] ]
  | _ -> raise ~loc "[dropbox] only supports Variant types"

let type_decl_str ~options ~path type_decls =
  List.concat (List.map (str_of_type ~options ~path) type_decls)

let () =
  let open Ppx_deriving in
  register @@ create "dropbox" ~type_decl_str ()
