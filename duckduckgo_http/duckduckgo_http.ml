(*
** Aim to make an http request and extract the received json
*)

(*
** PRIVATE
*)

open Yojson.Basic

(* UTILS *)

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

let tags_from_results json_tags =
  let open Yojson.Basic.Util in
  let get_url str = Str.string_after (List.hd (Str.split (Str.regexp "\">.*</a>") str)) 9 in
  let call_result str_uri = request ~display_body:true str_uri in
  let get_tags lwt_l (json) =
    if (member "Topics" json) == `Null && (member "Result" json) != `Null && (member "Text" json) != `Null
    then
      lwt my_val = call_result (get_url (to_string (member "Result" json))) in
      lwt l = lwt_l in
      Lwt.return ((to_string my_val, (to_string (member "Text" json)))::l)
    else lwt_l
    in
  List.fold_left get_tags (Lwt.return []) (to_list (member "RelatedTopics" json_tags))

lwt result = request ~display_body:false "http://api.duckduckgo.com/?q=apple&format=json&pretty=0"

(* let _ = print_endline (Yojson.Basic.pretty_to_string ( Yojson.Basic.Util.member "RelatedTopics" result)) *)

lwt result_tab = tags_from_results result

let disp (a, b) = Printf.printf "\tURL : %s\n\n\tDescription : %s\n----\n" a b

let _ = List.iter (disp) result_tab
(* let __ = disp result *)
