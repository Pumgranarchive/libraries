(*
** Aim to make an http request and extract the received json
*)

(*
** PRIVATE
*)

let get_results_from_http_request (header, body) =
  lwt body_string = Cohttp_lwt_body.to_string body in
  Lwt.return (Rdf_sparql_http.Ok body_string)

(*** json extractor ***)
let get_json_from_http_results ?(display_string = false) results  =
  let solutions_string = match results with
    | Rdf_sparql_http.Ok s        -> s
    | Rdf_sparql_http.Error e     -> e
  in
  if display_string then print_endline solutions_string;
  Yojson.Basic.from_string solutions_string


let request uri_string =
  let base_headers () =
    let headers = Cohttp.Header.init_with "accept" "application/json" in
    Cohttp.Header.add headers "user-agent" "ocaml-rdf/0.8" in
  let uri = Uri.of_string uri_string in
  let headers = base_headers () in
  lwt res = Cohttp_lwt_unix.Client.get ~headers uri in
  get_results_from_http_request res
