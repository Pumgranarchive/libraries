(*** Types ***)
type title = string
type abstract = string
type rdf_type = string list
type wiki_page = string
type is_primary_topic_of = string
type label = string
type same_as = string list

type url = string
type name = string
type album = string

type basic = (title * abstract * rdf_type * wiki_page * is_primary_topic_of * label * same_as)
type song = (url * title * album)

(*** Printing ***)
(** Print a basic dbpedia object on stdout *)
val print_basic : basic -> unit

(** Print a discography on stdout *)
val print_discography : song -> unit

(*** Requests ***)
(** execute a sparql request and return a list of basic object **)
val get_basic_informations : string -> basic list Lwt.t

(** execute a sparql request and return a list of songs **)
val get_discography : string -> song list Lwt.t
