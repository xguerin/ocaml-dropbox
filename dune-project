(lang dune 2.5.1)

(name ocaml-dropbox)
(version 1.0.0)
(generate_opam_files true)

(homepage https://git.sr.ht/~xguerin/ocaml-dropbox)
(source (uri git+https://git.sr.ht/~xguerin/ocaml-dropbox))
(license ISC)
(authors "Xavier R. Guérin")
(maintainers "Xavier R. Guérin <srht@applepine.org>")
(bug_reports "https://todo.sr.ht/~xguerin/ocaml-dropbox")

(package
 (name ocaml-dropbox)
 (synopsis "OCaml Dropbox API")
 (depends
  (dune (> 2.0))
  (lwt (>= 5.0.0))
  (ppx_deriving_yojson (and :build (>= 3.5.2)))
  (uri (>= 3.1.0))
))
