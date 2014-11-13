(*** Types ***)
type title = string
type url = string
type album = string

type lightweight = Dbpedia_record.LightWeight.t
type basic = Dbpedia_record.Basic.t
type song = (url * title * album)

exception Dbpedia of string

(*** utils  *)
val is_wikipedia_uri : string -> bool

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
val get_basic_informations_by_uri : string -> basic list Lwt.t

(** execute a sparql request and return a list of songs **)
val get_discography : string -> song list Lwt.t
