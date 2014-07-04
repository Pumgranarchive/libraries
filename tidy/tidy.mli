(**
   {b Tidy -
   A ocaml Tidy binding}
*)

(** translate html to xhtml and fix error  *)
val xhtml_of_html : string -> string Lwt.t
