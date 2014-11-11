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

type lightweight = Dbpedia_record.LightWeight.t

type basic = (title * abstract * wiki_page * is_primary_topic_of *
                label)
type song = (url * title * album)

exception Dbpedia of string

(*** Printing ***)
(** Print a lightweight dbpedia object on stdout *)
val print_lightweight : lightweight -> unit

(** Print a basic dbpedia object on stdout *)
val print_basic : basic -> unit

(** Print a discography on stdout *)
val print_discography : song -> unit

(*** Requests ***)
(** execute a sparql request and return a list of light object **)
val get_minimal_informations : string ->  lightweight list Lwt.t

(** execute a sparql request and return a list of basic object **)
val get_basic_informations : string -> basic list Lwt.t

(** execute a sparql request and return a list of songs **)
val get_discography : string -> song list Lwt.t
