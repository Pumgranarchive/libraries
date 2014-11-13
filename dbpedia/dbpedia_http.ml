
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

type basic = Dbpedia_record.Basic.t

type song = (url * title * album)

exception Dbpedia of string

(*
** PRIVATE
*)

let get_exc_string e = "DBpedia: " ^ (Printexc.to_string e)

let rec string_of_list = function
  | h::t      -> (h ^ "\n" ^ string_of_list t)
  | []        -> ""

(*
** PUBLIC
*)


let print_lightweight record =
  let open Dbpedia_record.LightWeight in
  print_endline "--- Lightweight ---";
  (Printf.printf "title: %s\nabstract: %s\nis_primary_topic_of: %s\n"
     (Ptype.string_of_uri record.is_primary_topic_of)
     record.title
     record.abstract
  )

let print_basic record =
  let open Dbpedia_record.Basic in
  print_endline "--------";
  (Printf.printf "title: %s\nabstract: %s\nwiki_page_id: %s\nis_primary_topic_of: %s\nsubject: %s\n"
     record.title
     record.abstract
     record.wiki_page_id
     (Ptype.string_of_uri record.is_primary_topic_of)
     (string_of_list record.subject)
  )

let print_discography
    (song, name, album) =
  print_endline "--------";
  print_endline song;
  print_endline name;
  print_endline album


let is_wikipedia_uri uri =
  let uri_reg =
    Str.regexp "\\(https?://\\)?\\(www\\.\\)?\\(meta\\.\\)?\\(..\\.\\)?wikipedia\\.org/\\(wiki/\\)?\\([-A-Za-z0-9_]\\)*" in
  Str.string_match uri_reg uri 0

(*
uri_list =  Ptype.uri
*)
let get_minimal_informations uri =
  let minimal_informations_query = Dbpedia_query.get_minimal_informations_query_infos uri in
  lwt dbpedia_results = Rdf_http.query
      (Rdf_uri.uri "http://dbpedia.org/sparql")
      Dbpedia_query.(minimal_informations_query.query)
  in
  let create_lightWeight = Dbpedia_record.LightWeight.parse dbpedia_results
  in
  Lwt.return (if (is_wikipedia_uri uri) = false
  then raise (Dbpedia "Dbpedia_http.get_minimal_informations: \"uri\" parameter must be a wikipedia uri")
  else (create_lightWeight))



let get_basic_informations name =
  try_lwt
    let basic_query = Dbpedia_query.get_basic_query_infos name in
    lwt dbpedia_results = Rdf_http.query
        (Rdf_uri.uri "http://dbpedia.org/sparql")
        Dbpedia_query.(basic_query.query)
    in
    let ret = Dbpedia_record.Basic.parse dbpedia_results in
    Lwt.return (ret)
  with e -> raise (Dbpedia (get_exc_string e))

let get_discography name =
  try_lwt
    let discography_query = Dbpedia_query.get_discography_query_infos name in
    lwt dbpedia_results = Rdf_http.query
        (Rdf_uri.uri "http://dbpedia.org/sparql")
        Dbpedia_query.(discography_query.query)
    in
    let format record =
      Dbpedia_record.Disco.(record.song, record.song_name, record.album)
    in
    let ret = Dbpedia_record.Disco.parse dbpedia_results in
    Lwt.return (List.map format ret)
  with e -> raise (Dbpedia (get_exc_string e))
