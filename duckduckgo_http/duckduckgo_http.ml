open Yojson.Basic.Util

let base_url = "http://api.duckduckgo.com"

let result_of_abstract json =
  let url = to_string (member "AbstractURL" json) in
  let text = to_string (member "AbstractText" json) in
  Printf.printf "%s => %s\n" url text;
  [(url, text)]

let to_result json =
  let url = to_string (member "FirstURL" json) in
  let text = to_string (member "Text" json) in
  Printf.printf "%s => %s\n" url text;
  [(url, text)]

let extractor json =
  let topics = (member "Topics" json) in
  match topics with
  | `Null -> to_result json
  | _     -> List.flatten (List.map to_result (to_list topics))

let to_results str_json =
  let json = Yojson.Basic.from_string str_json in
  let related_topics = to_list (member "RelatedTopics" json) in
  let first = List.flatten (List.map extractor related_topics) in
  let abstract = result_of_abstract json in
  let results = to_list (member "Results" json) in
  let second = List.flatten (List.map extractor results) in
  first@abstract@second

let search field =
  let q = "q="^ field in
  let format = "format=json" in
  let uri = Uri.of_string (base_url ^"?"^ q ^"&"^ format) in
  let headers = Cohttp.Header.init_with "accept" "application/json" in
  lwt (header, body) = Cohttp_lwt_unix.Client.get ~headers uri in
  lwt body_string = Cohttp_lwt_body.to_string body in
  print_endline body_string;
  let results = to_results body_string in
  Lwt.return ()

let main () =
  let field = List.nth (Array.to_list Sys.argv) 1 in
  print_endline field;
  search field

lwt () = main ()
