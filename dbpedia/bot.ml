
let get_basic_informations =

"PREFIX dbpedia-owl: <http://dbpedia.org/ontology/>
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


(* let print_sol sol = *)
(*   let print varname term = *)
(*     Printf.printf "%s => %s\n" varname (Rdf_term.string_of_term term) *)
(*   in *)
(*   Rdf_sparql.solution_iter print sol ; *)
(*   print_newline() *)

let t_of_solutions solutions =
  let print varname term =
    Printf.printf "%s => %s\n" varname (Rdf_term.string_of_term term)
  in
  let iter solutions =
    print_endline (string_of_bool (Rdf_sparql.is_bound solutions "sameAs"));
    Rdf_sparql.solution_iter print solutions ;
    print_newline()
  in
  let toto solution =
    solution
  in
  let rdf_sparql_map func list =
    let rec aux final_list = function
      | h::t    -> aux ((func h)::final_list) t
      | _       -> final_list
    in
    aux [] list
  in
  rdf_sparql_map toto solutions

lwt _ =
  lwt dbpedia_results = query
    (Rdf_uri.uri "http://dbpedia.org/sparql") get_basic_informations
  in
  print_endline (string_of_int (List.length dbpedia_results));
  (* List.iter print_sol dbpedia_results; *)
  t_of_solutions dbpedia_results;
  Lwt.return ()



(* lwt query_web =  Rdf_sparql_http_lwt.get *)
(*   (Rdf_uri.uri "http://fr.dbpedia.org") *)
(*   web_query_get_member_of_rhapsody *)

(* (\* let solutions = match query_web with *\) *)
(* (\*   | Rdf_sparql_http.Ok s        -> s *\) *)
(* (\*   | Rdf_sparql_http.Error e     -> print_endline e; [] *\) *)

(* (\* let print_sol = *\) *)
(* (\*   let print varname term = *\) *)
(* (\*     Printf.printf "%s => %s\n" varname (Rdf_term.string_of_term term) *\) *)
(* (\*   in *\) *)
(* (\*   fun sol -> *\) *)
(* (\*     print_endline "Solution:"; *\) *)
(* (\*     solution_iter print sol ; *\) *)
(* (\*     print_newline();; *\) *)

(* (\* let _ = *\) *)
(* (\*   begin *\) *)
(* (\*     print_endline "Printing solution..."; *\) *)
(* (\*     List.iter print_sol solutions; *\) *)
(* (\*     print_endline "...Done" *\) *)
(* (\*   end *\) *)


