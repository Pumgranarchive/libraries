(*
** Aim to make an http request and extract the received json
*)

(*
** PRIVATE
*)

(* CONFIG *)

let opencalais_uri = Uri.of_string "http://api.opencalais.com/tag/rs/enrich"
let token = ref ""

let set_token str =
  token := str

(* UTILS *)

let get_results_from_request (header, body) =
  lwt body_string = Cohttp_lwt_body.to_string body in
  Lwt.return body_string

let get_json_from_results display_body results  =
  if display_body then print_endline results;
  Yojson.Basic.from_string results

let base_headers length =
  let headers = Cohttp.Header.init_with "accept" "application/json" in
  let headers = Cohttp.Header.add headers "x-calais-licenseID" !token in
  let headers = Cohttp.Header.add headers "content-type" "text/html" in
  let headers = Cohttp.Header.add headers "content-length" (string_of_int length) in
  Cohttp.Header.add headers "enableMetadataType" "SocialTags"

let request ?(display_body=false) body_str =
  let body = ((Cohttp.Body.of_string body_str) :> Cohttp_lwt_body.t) in
  let headers = base_headers (String.length body_str) in
  lwt request_response =
      Cohttp_lwt_unix.Client.post ~body ~chunked:false ~headers opencalais_uri
  in
  lwt result = get_results_from_request request_response in
  Lwt.return (get_json_from_results display_body result)


(* TEST *)

let _ = set_token "z3k9bmug6udbqcqdwgt8qzq2"

let body = "The Hobbit, or There and Back Again, is a fantasy novel and children's book by English author J. R. R. Tolkien. It was published on 21 September 1937 to wide critical acclaim, being nominated for the Carnegie Medal and awarded a prize from the New York Herald Tribune for best juvenile fiction. The book remains popular and is recognized as a classic in children's literature."

lwt json_result = request ~display_body:false body

let display_json json_tags = Yojson.Basic.pretty_to_string json_tags

let get_json_list json_tags = Yojson.Basic.Util.to_list json_tags

let list_displayer list_json = 
  let displayer (name, json) = Printf.printf "%s - %s\n===\n" name (Yojson.Basic.pretty_to_string json) in 
  List.iter displayer list_json

let tags_from_results json_tags = 
  let get_str_f_json json = Yojson.Basic.Util.to_string json in
  let get_assoc json_tags = Yojson.Basic.Util.to_assoc json_tags in
  let get_tags l json = 
    if (get_str_f_json (Yojson.Basic.Util.member "_typeGroup" json)) == "socialTag"
    then l::[(get_str_f_json (Yojson.Basic.Util.member "name" json))]
    else l
    in
  List.fold_left get_tags [] (get_assoc json_tags)

(* let parse_json result json_tags = result::[json_tags]

let tags_from_results json_tags = Yojson.Basic.Util.to_list json_tags
  List.fold_left parse_json [] json_tags *)

let _ = list_displayer (Yojson.Basic.Util.to_assoc json_result);
(* let _ = print_endline (display_json json_result); *)
