(**
   Xtractor
   A ocaml xtractor binding
*)

exception Failed of int
exception Killed of int
exception Stopped of int

type document = { title: string; body: string; summary: string;
                  image: string; video: string }

(** Set the jar path, default is '/home/nox/.opam/4.00.1/lib/xtractor/simplextractor.jar' *)
val set_jar_path : string -> unit

val xtractor : Uri.t -> document Lwt.t
