(lang dune 2.5.1)

(name ocaml-dropbox)
(version 1.0.0)
(generate_opam_files true)

(source (github xguerin/ocaml-dropbox))
(license ISC)
(authors "Xavier R. Guérin")
(maintainers "Xavier R. Guérin <github@applepine.org>")

(package
 (name ocaml-dropbox)
 (synopsis "OCaml Dropbox API")
 (depends
  (ISO8601 (>= 0.2.6))
  (base64 (>= 3.4.0))
  (cohttp-lwt (>= 2.5.1))
  (dune (and :build (> 2.0)))
  (lwt (>= 5.0.0))
  (lwt_ppx (and :build (>= 2.0.1)))
  (ppxlib (and :build (>= 0.15.0)))
  (ppx_deriving (and :build (>= 4.5)))
  (ppx_deriving_yojson (and :build (>= 3.5.2)))
  (uri (>= 3.1.0))
))

(package
 (name ocaml-dropbox-lwt-unix)
 (synopsis "OCaml Dropbox API")
 (depends
  (cohttp-lwt-unix (>= 2.5.1))
  (dune (and :build (> 2.0)))
  (ocaml-dropbox (>= 1.0.0))
))
