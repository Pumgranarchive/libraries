(**
   {b OpenCalais -
   A ocaml OpenCalais binding}
*)

(** set OpenCalais token *)
val set_token : string -> unit

(** Ask OpenCalais API with a [string] content.
The result is a [json] content with all OpenCalais informations about the [string].
[display_body] is an option to display the result if set to true.*)
val request : ?display_body:bool -> string -> Yojson.Basic.json Lwt.t

(** fetch the social_tags attribute of [json] list. this function return a [string list] *)
val tags_from_results : Yojson.Basic.json -> string list