(**
   Xtractor
   A ocaml xtractor binding
*)

exception Failed of int
exception Killed of int
exception Stopped of int

(** content: html content; body: article body  *)
type document = { title: string; body: string; summary: string }

(** Set the jar path, default is '/home/nox/.opam/4.00.1/lib/xtractor/simplextractor.jar' *)
val set_jar_path : string -> unit

(** xtractor uri html_content
 * [uri] Is used to transform relative uri to absolute uri
 *
 * [Warning] This function does not implement an url fetcher
 *           It is just an article extractor and an summarizer
 *)
val xtractor : Uri.t -> string -> document Lwt.t
