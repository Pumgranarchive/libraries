
(*** Types ***)
type id = string
type name = string
type sliced_description = string
type social_media_presences = string list
type types = (string * string) list
type wiki_url = string list

exception Freebase of string

type freebase_object =
  (
    id
    * name
    * sliced_description
    * social_media_presences
    * types
    * wiki_url
  )

(*** Printing ***)
(** Print a basic freebase object on stdout *)
val print_freebase_object : freebase_object -> unit

(*** Requests ***)
(** return a list of freebase basic object from a list of topic_ids *)
val get_topics  : string -> freebase_object option Lwt.t
