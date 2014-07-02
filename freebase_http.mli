
(*** Types ***)
type id = string
type name = string
type sliced_description = string
type social_media_presences = string list
type types = (string * string) list
type wiki_url = string list

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
val print_freebase_object : freebase_object -> unit

(*** Requests ***)
val search      : string -> Yojson.Basic.json Lwt.t
val get_topics  : string -> freebase_object Lwt.t
