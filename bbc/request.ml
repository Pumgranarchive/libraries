(*
** Aim to make an http request and extract the received json
*)

(*
** PRIVATE
*)



let get_results_from_request (header, body) =
  lwt body_string = Cohttp_lwt_body.to_string body in
  Lwt.return body_string

(*** json extractor ***)
let get_json_from_results display_body results  =
  if display_body then print_endline results;
  Yojson.Basic.from_string results


let request ?(display_body = false) uri_string =
  let base_headers () =
    let headers = Cohttp.Header.init_with "accept" "application/json" in
    Cohttp.Header.add headers "user-agent" "ocaml-rdf/0.8" in
  let uri = Uri.of_string uri_string in
  let headers = base_headers () in
  lwt request_response = Cohttp_lwt_unix.Client.get ~headers uri in
  lwt results = get_results_from_request request_response in
  Lwt.return (get_json_from_results display_body results)


let url = "http://www.bbc.co.uk/nature/life/Spider.rdf"


lwt json_result = request ~display_body:true url

