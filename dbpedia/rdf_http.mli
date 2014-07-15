

(*** Requests ***)
(**
Execute a sparql query using ocaml-rdf and give the result back without any processing on it
*)
val query : Rdf_uri.uri -> string -> Rdf_sparql.solution list Lwt.t

(**
format the result of a sparql query into pairs.
*)
val pairs_of_solutions : ?display:bool -> Rdf_sparql.solution list -> string list -> (string * string) list list
