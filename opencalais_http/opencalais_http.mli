(**
   {b OpenCalais -
   A ocaml OpenCalais binding}
*)

(** set OpenCalais token *)
val set_token : string -> unit

(** get json structure from text [request ?display_body body_str] *)
val request : ?display_body:bool -> string -> Yojson.Basic.json Lwt.t

(** get tags from a json list [tags_from_results json] *)
val tags_from_results : Yojson.Basic.json -> string list