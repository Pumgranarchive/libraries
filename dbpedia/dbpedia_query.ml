type sparql_information = { keys : string list; query : string}

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


let get_basic_query_infos_by_uri wiki_uri =
  let aux = {
    keys =
      ["title";"abstract";(* "type"; *)"wikiPage";"isPrimaryTopicOf";"label"(*; "sameAs" *)];
    query = "PREFIX dbpedia-owl: <http://dbpedia.org/ontology/>
PREFIX dbres: <http://dbpedia.org/resource/>
PREFIX dbprop: <http://dbpedia.org/property/>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX foaf: <http://xmlns.com/foaf/0.1/>
PREFIX dcterms: <http://purl.org/dc/terms/>

SELECT DISTINCT ?title ?abstract ?wikiPage ?isPrimaryTopicOf ?label (group_concat(distinct ?subject;separator=\";\") as ?subject)
WHERE
{

   ?band foaf:isPrimaryTopicOf <" ^ wiki_uri ^ ">.
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

let get_basic_query_infos_by_name name =
  let aux = {
    keys =
      ["title";"abstract";(* "type"; *)"wikiPage";"isPrimaryTopicOf";"label"(*; "sameAs" *)];
    query = "PREFIX dbpedia-owl: <http://dbpedia.org/ontology/>
PREFIX dbres: <http://dbpedia.org/resource/>
PREFIX dbprop: <http://dbpedia.org/property/>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX foaf: <http://xmlns.com/foaf/0.1/>
PREFIX dcterms: <http://purl.org/dc/terms/>

SELECT DISTINCT ?title ?abstract ?wikiPage ?isPrimaryTopicOf ?label (group_concat(distinct ?subject;separator=\";\") as ?subject)
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
PREFIX dbpedia-owl: <http://dbpedia.org/ontology/>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX foaf: <http://xmlns.com/foaf/0.1/>

SELECT DISTINCT ?song ?song_name ?album WHERE {
  ?band dbprop:name  \"" ^ band_name ^ "\"@en .
  ?song dbpedia-owl:musicalArtist ?band .
  ?song dbprop:fromAlbum ?album .
  ?song dbprop:name ?song_name .
}"
  }
  in
  aux
