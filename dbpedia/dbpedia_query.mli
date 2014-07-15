type sparql_information = { keys : string list; query : string}

val get_basic_query_infos : string -> sparql_information
val get_discography_query_infos : string -> sparql_information
