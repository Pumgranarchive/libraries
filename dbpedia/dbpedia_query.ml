type sparql_information = { keys : string list; query : string}


(* type param = *)
(*   Title *)
(* | Abstract *)
(* | Rdf_type *)
(* | Wiki_page *)
(* | Is_primary_topic_of *)
(* | Label *)
(* | Same_as *)

(* type param = *)
(*   Title of string *)
(* | Abstract of string *)
(* | Rdf_type of string list *)
(* | Wiki_page of string *)
(* | Is_primary_topic_of of string *)
(* | Label of string *)
(* | Same_as of string list *)


(* let string_of_type = function *)
(*   Title s                -> "title" *)
(* | Abstract s             -> "abstract" *)
(* | Rdf_type l             -> "type" *)
(* | Wiki_page s            -> "wikiPage" *)
(* | Is_primary_topic_of s  -> "isPrimaryTopicOf" *)
(* | Label s                -> "label" *)
(* | Same_as l              -> "sameAs" *)

(* type basic = (title * abstract * rdf_type * wiki_page * is_primary_topic_of * label * same_as) *)

let get_minimal_informations_query_infos wiki_uri =
  let aux = {
    keys =
      ["isPrimaryTopicOf";"title";"abstract"];
    query = "PREFIX dbpedia-owl: <http://dbpedia.org/ontology/>
PREFIX dbres: <http://dbpedia.org/resource/>
PREFIX dbprop: <http://dbpedia.org/property/>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX foaf: <http://xmlns.com/foaf/0.1/>

SELECT DISTINCT ?isPrimaryTopicOf ?title ?abstract
WHERE
{
   ?band foaf:isPrimaryTopicOf <" ^ wiki_uri ^ ">.
   ?band foaf:isPrimaryTopicOf ?isPrimaryTopicOf.
   ?band dbprop:name ?title.
   ?band dbpedia-owl:abstract ?abstract.

   FILTER (lang(?title) = '' || lang(?title) = 'en')
   FILTER (lang(?abstract) = '' || lang(?abstract) = 'en')
}
limit 1000";
  }
  in
  aux


let get_basic_query_infos name =
  let aux = {
    (* basic = [Title | Abstract | Rdf_type | Wiki_page | Is_primary_topic_of | Label | Same_as]; *)
    keys =
      ["title";"abstract";(* "type"; *)"wikiPage";"isPrimaryTopicOf";"label"(*; "sameAs" *)];
    query = "PREFIX dbpedia-owl: <http://dbpedia.org/ontology/>
PREFIX dbres: <http://dbpedia.org/resource/>
PREFIX dbprop: <http://dbpedia.org/property/>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX foaf: <http://xmlns.com/foaf/0.1/>
PREFIX dbterms: <http://purl.org/dc/terms/>

SELECT DISTINCT ?title ?abstract ?wikiPage ?isPrimaryTopicOf ?label ?subject
WHERE
{

   ?band dbprop:name \"" ^ name ^ "\"@en.
   ?band dbprop:name ?title.
   ?band dbpedia-owl:abstract ?abstract.
   ?band dbpedia-owl:wikiPageID ?wikiPage.
   ?band foaf:isPrimaryTopicOf ?isPrimaryTopicOf.
   ?band rdfs:label ?label.
   ?band dcterms:subject ?subject.

   FILTER (lang(?title) = '' || lang(?title) = 'en')
   FILTER (lang(?abstract) = '' || lang(?abstract) = 'en')
   FILTER (lang(?label) = '' || lang(?label) = 'en')

}
limit 1000";
  }
  in
  aux

let get_discography_query_infos band_name =
  let aux = {
    keys =
      ["song";"song_name";"album"];
    query = "
PREFIX dbres: <http://dbpedia.org/resource/>
PREFIX dbprop: <http://dbpedia.org/property/>
PREFIx dbpedia-owl: <http://dbpedia.org/ontology/>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX foaf: <http://xmlns.com/foaf/0.1/>

SELECT DISTINCT ?song ?song_name ?album WHERE {
  ?band dbprop:name  \"" ^ band_name ^ "\"@en .
  ?song dbpedia-owl:musicalArtist ?band .
  ?song dbpprop:fromAlbum ?album .
  ?song dbprop:name ?song_name .
}"
  }
  in
  aux
