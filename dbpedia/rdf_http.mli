

val query : Rdf_uri.uri -> string -> Rdf_sparql.solution list Lwt.t
val pairs_of_solutions : ?display:bool -> Rdf_sparql.solution list -> string list -> (string * string) list list
