(** [set_token token] *)
val set_token : string -> unit

(** [request ?display_body body_str] *)
val request : ?display_body:bool -> string -> Yojson.Basic.json Lwt.t
