(**
   Boilerpipe
   A ocaml boilerpipe binding
*)

exception Failed of int
exception Killed of int
exception Stopped of int

type mode = Article | Default

(** Set the jar path, default is 'jar/simpleboilerpipe.jar' *)
val set_jar_path : string -> unit

val boilerpipe : mode -> Uri.t -> string list Lwt.t
