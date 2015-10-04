(**
   {b OpenCalais -
   A ocaml OpenCalais binding}
*)

(** set your OpenCalais uri, default 'http://api.opencalais.com/tag/rs/enrich' *)
val set_uri : Uri.t -> unit

(** set your OpenCalais token, no default value *)
val set_token : string -> unit

(** [request text] *)
val request : string -> Yojson.Basic.json Lwt.t

(** [to_social_tags result]
    Extract social tags from the json result  *)
val to_social_tags : Yojson.Basic.json -> string list
