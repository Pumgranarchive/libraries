
open Rdf_sparql
open Yojson.Basic

(*
** Request Http
*)

let get_results_from_http_request (header, body) =
  lwt body_string = Cohttp_lwt_body.to_string body in
  Lwt.return (Rdf_sparql_http.Ok body_string)

let exec_http_request uri_string =
  let base_headers () =
    let headers = Cohttp.Header.init_with "accept" "application/json" in
    Cohttp.Header.add headers "user-agent" "ocaml-rdf/0.8" in
  let uri = Uri.of_string uri_string in
  let headers = base_headers () in
  lwt res = Cohttp_lwt_unix.Client.get ~headers uri in
  get_results_from_http_request res

(*
** get_json_from_http_results
*)
let get_json_from_http_results ?(display_string = false) results  =
  let solutions_string = match results with
    | Rdf_sparql_http.Ok s        -> s
    | Rdf_sparql_http.Error e     -> e
  in
  if display_string then print_endline solutions_string;
  Yojson.Basic.from_string solutions_string

(*
** Main()
*)

(* youtube request part *)
let youtube_url_final =
  Youtube_http.create_youtube_search_url "le fossoyeur" "snippet" "2"
(* let youtube_url_final =
   Youtube_http.create_youtube_video_url "wf_77z1H-vQ" "snippet" *)
lwt youtube_results = exec_http_request youtube_url_final
let youtube_json = get_json_from_http_results youtube_results

(* freebase request part *)
(* let freebase_url_final = Freebase_http.create_freebase_search_url "bob" *)
(* lwt freebase_results = exec_http_request freebase_url_final *)
(* let freebase_json = get_json_from_http_results freebase_results *)


(* result printing part *)
(* let _ = Freebase_http.print_freebase_json freebase_json *)
let _ = Youtube_http.print_youtube_json youtube_json
