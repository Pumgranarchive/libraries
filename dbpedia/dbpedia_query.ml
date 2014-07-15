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

let basic_informations = {
  (* basic = [Title | Abstract | Rdf_type | Wiki_page | Is_primary_topic_of | Label | Same_as]; *)
  keys =
    ["title";"abstract";"type";"wikiPage";"isPrimaryTopicOf";"label";"sameAs"];
  query = "PREFIX dbpedia-owl: <http://dbpedia.org/ontology/>
PREFIX dbres: <http://dbpedia.org/resource/>
PREFIX dbprop: <http://dbpedia.org/property/>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX foaf: <http://xmlns.com/foaf/0.1/>

SELECT DISTINCT ?title ?abstract ?type ?wikiPage ?isPrimaryTopicOf ?label ?sameAs
WHERE
{

 {
   dbres:Rhapsody_of_Fire dbprop:name ?title.
   FILTER (lang(?title) = '' || lang(?title) = 'en')
 }
 UNION
 {
   dbres:Rhapsody_of_Fire dbpedia-owl:abstract ?abstract.
   FILTER (lang(?abstract) = '' || lang(?abstract) = 'en')
 }
 UNION
 {
   dbres:Rhapsody_of_Fire rdf:type ?type.
 }
 UNION
 {
   dbres:Rhapsody_of_Fire dbpedia-owl:wikiPageID ?wikiPage.
 }
 UNION
 {
   dbres:Rhapsody_of_Fire foaf:isPrimaryTopicOf ?isPrimaryTopicOf.
 }
 UNION
 {
   dbres:Rhapsody_of_Fire rdfs:label ?label.
   FILTER (lang(?label) = '' || lang(?label) = 'en')
 }
 UNION
 {
   dbres:Rhapsody_of_Fire owl:sameAs ?sameAs.
 }

}
limit 1000"
}
