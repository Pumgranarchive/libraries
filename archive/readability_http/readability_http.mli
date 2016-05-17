(**
   {b Readability -
   A ocaml readability binding}
*)

(** Set the readability token  *)
val set_token : string -> unit

(** Send request on the Readability parser  *)
val get_parser : Uri.t -> Yojson.Basic.json Lwt.t
