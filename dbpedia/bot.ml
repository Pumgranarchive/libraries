

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

let query q =
  let mes =
    {
      Rdf_sparql_protocol.in_query = q ;
      Rdf_sparql_protocol.in_dataset = Rdf_sparql_protocol.empty_dataset ;
    }
  in
  let uri = (Rdf_uri.uri "http://dbpedia.org/sparql") in
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

let pairs_of_solutions ?(display = false) solutions keys =
  let get_pair solution =
    let predicat elem = Rdf_sparql.is_bound solution elem in
    let keys = List.find_all predicat keys in
    if (display = true)
    then List.iter
      (fun key -> print_endline ("key=" ^ key ^ " | value=" ^ (Rdf_term.string_of_term (Rdf_sparql.get_term solution key))))
      keys;

    (* let key2 = List.find_all predicat keys in *)
    (* let toto current =  print_endline (Rdf_term.string_of_term (Rdf_sparql.get_term solution current)) in *)
    (* List.iter toto key2; *)

    let create_pair key =
    (key, Rdf_sparql.get_string solution key) in
    List.map create_pair keys

  in
  List.map get_pair solutions

let get_value pairs key_to_find =
  let is_key_equal (key, value) = (key = key_to_find)
  in
  let find_key pairs =
    let exist = List.exists is_key_equal pairs in
    if exist then List.find is_key_equal pairs else (key_to_find, "")in
  let (key, value) = find_key pairs in
  value

(* let get_value pairs_list key_to_find = *)
(*   let is_key_equal (key, value) = (key = key_to_find) *)
(*   in *)
(*   let find_key pairs = List.find is_key_equal pairs in *)
(*   let (key, value) = find_key pairs in *)
(*   value *)

let get_values pairs key_to_find =
  let is_key_equal (key, value) = (key = key_to_find) in
  let current_pairs = List.find_all is_key_equal pairs in
  let get_value (key, value) = value in
  List.map get_value current_pairs

let print_basic
    (title,abstract,rdf_type,wiki_page,is_primary_topic_of,label,same_as) =
  print_endline "--------";
  print_endline title;
  print_endline abstract;
  print_endline wiki_page;
  print_endline is_primary_topic_of

let print_discography
    (song, name, album) =
  print_endline "--------";
  print_endline song;
  print_endline name;
  print_endline album

let get_basic_informations name =
  let basic_query = Dbpedia_query.get_basic_query_infos name in
  let basic_of_pair pairs =
    let title = get_value pairs "title" in
    let abstract = get_value pairs "abstract" in
    (* let rdf_type = get_value pairs "type" in *)
    let wiki_page = get_value pairs "wikiPage" in
    let is_primary_topic_of = get_value pairs "isPrimaryTopicOf" in
    let label = get_value pairs "label" in
    (* let same_as = get_value pairs "sameAs" in *)
    (title,abstract,"" (* rdf_type *),wiki_page,is_primary_topic_of,label,"" (*sameAs*))
  in
  lwt dbpedia_results = query Dbpedia_query.(basic_query.query) in
  let pairs_list = (pairs_of_solutions ~display:false dbpedia_results Dbpedia_query.(basic_query.keys)) in
  Lwt.return (List.map basic_of_pair pairs_list)

let get_discography name =
  let discography_query = Dbpedia_query.get_discography_query_infos name in
  let discography_of_pair pairs =
    let song = get_value pairs "song" in
    let name = get_value pairs "song_name" in
    let album = get_value pairs "album" in
    (song, name, album)
  in
  lwt dbpedia_results = query Dbpedia_query.(discography_query.query) in
  let pairs_list = (pairs_of_solutions ~display:false dbpedia_results Dbpedia_query.(discography_query.keys)) in
  Lwt.return (List.map discography_of_pair pairs_list)

lwt _ =
  (* lwt basic = get_basic_informations "Rhapsody of Fire" in *)
  (* Lwt.return (List.iter print_basic basic) *)

  lwt discography = get_discography "Green Day" in
  Lwt.return (List.iter print_discography discography)
