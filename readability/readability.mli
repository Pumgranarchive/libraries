(**
   {b Readability -
   A ocaml readability binding}
*)

(** Send request on the Readability parser  *)
val get_parser : Rdf_uri.uri -> Yojson.Basic.json Lwt.t
