
let query uri q =
  let mes =
    {
      Rdf_sparql_protocol.in_query = q ;
      Rdf_sparql_protocol.in_dataset = Rdf_sparql_protocol.empty_dataset ;
    }
  in
  let uri = uri in
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
    let create_pair key =
    (key, Rdf_sparql.get_string solution key) in
    List.map create_pair keys
  in
  List.map get_pair solutions
