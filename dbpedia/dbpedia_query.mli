(*** Types ***)
type sparql_information = { keys : string list; query : string}


(*** constructors ***)
(**
Create a value containing informations needed for retrieving basic informations of a dbpedia content.
*)
val get_basic_query_infos : string -> sparql_information

(**
Create a value containing informations needed for retrieving the discography of a band on dbpedia.
*)
val get_discography_query_infos : string -> sparql_information
