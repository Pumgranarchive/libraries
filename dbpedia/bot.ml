

(* let get_basic_informations = *)

(* "PREFIX dbpedia-owl: <http://dbpedia.org/ontology/> *)
(* PREFIX dbres: <http://dbpedia.org/resource/> *)
(* PREFIX dbprop: <http://dbpedia.org/property/> *)
(* SELECT DISTINCT ?memberName ?genre *)
(* WHERE *)
(* { *)

(*  { *)
(*    dbres:Rhapsody_of_Fire dbpedia-owl:bandMember ?memberName. *)
(*  } *)
(*  UNION *)
(*  { *)
(*    dbres:Rhapsody_of_Fire dbpedia-owl:genre ?genre. *)
(*  } *)

(* } *)
(* limit 100" *)


(* "PREFIX dbpedia-owl: <http://dbpedia.org/ontology/> *)
(* PREFIX dbpprop: <http://dbpedia.org/property/> *)
(* PREFIX dbres: <http://dbpedia.org/resource/> *)
(* SELECT ?memberName ?instru *)
(* WHERE *)
(* { *)
(*      ?band dbpedia-owl:bandMember ?memberName. *)
(*      ?memberName dbpedia-owl:instrument ?instru *)
(* } *)
(* " *)

type title = string
type abstract = string
type rdf_type = string list
type wiki_page = string
type is_primary_topic_of = string
type label = string
type same_as = string list

type basic = (title * abstract * rdf_type * wiki_page * is_primary_topic_of * label * same_as)

let query uri q =
  let mes =
    {
      Rdf_sparql_protocol.in_query = q ;
      Rdf_sparql_protocol.in_dataset = Rdf_sparql_protocol.empty_dataset ;
    }
  in
  let iri = Rdf_iri.of_uri uri in
  lwt result = Rdf_sparql_http_lwt.get
    ~base: iri
    ~accept: "application/sparql-results+xml"
    uri
    mes
  in
  let get_solution = function
    | Rdf_sparql.Solutions l -> l
    | _ -> failwith ("No solutions")
  in
  Lwt.return (match result with
  | Rdf_sparql_protocol.Result r -> get_solution r
  | Rdf_sparql_protocol.Error e  -> failwith (Rdf_sparql_protocol.string_of_error e)
  | _                            -> failwith ("No retuls"))


let pairs_of_solutions solutions keys =
  let get_pair solution =
    let predicat elem = Rdf_sparql.is_bound solution elem in
    let key = List.find predicat keys in
    (key, (Rdf_term.string_of_term (Rdf_sparql.get_term solution key)))
  in
  (* let map func list = *)
  (*   let rec aux final_list = function *)
  (*     | h::t    -> aux ((func h)::final_list) t *)
  (*     | _       -> final_list *)
  (*   in *)
  (*   aux [] list *)
  (* in *)
  List.map get_pair solutions


let print_basic
    (title,abstract,rdf_type,wiki_page,is_primary_topic_of,label,same_as) =
  print_endline title;
  print_endline abstract;
  print_endline wiki_page;
  print_endline is_primary_topic_of


let get_basic_informations =
  let basic_of_pair pairs =
    let get_value key_to_find =
      let is_key_equal (key, value) = (key = key_to_find)
      in
      let pair = List.find is_key_equal pairs in
      let (key, value) = pair in
      value
    in
    let title = get_value "title" in
    let abstract = get_value "abstract" in
    let rdf_type = get_value "type" in
    let wiki_page = get_value "wikiPage" in
    let is_primary_topic_of = get_value "isPrimaryTopicOf" in
    let label = get_value "label" in
    let same_as = get_value "sameAs" in
    (title,abstract,rdf_type,wiki_page,is_primary_topic_of,label,same_as)
  in
  lwt dbpedia_results = query
      (Rdf_uri.uri "http://dbpedia.org/sparql") Dbpedia_query.(basic_informations.query) in
  (* print_endline (string_of_int (List.length dbpedia_results)); *)
  Lwt.return (basic_of_pair (pairs_of_solutions dbpedia_results Dbpedia_query.(basic_informations.keys)))

lwt _ =
  lwt basic = get_basic_informations in
  Lwt.return (print_basic basic)
