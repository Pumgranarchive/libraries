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

val print_basic : basic -> unit
val print_discography : song -> unit

val get_basic_informations : string -> basic list Lwt.t
val get_discography : string -> song list Lwt.t
