(*
** Aim to make an http request and extract the received json
*)

(*
** PRIVATE
*)

open Yojson.Basic

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
  from_string results

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

let tags_from_results json_tags =
  let open Yojson.Basic.Util in
  let get_tags l (name, json) =
    if String.compare (pretty_to_string (member "_typeGroup" json)) "\"socialTag\"" == 0
    then (Str.global_replace (Str.regexp_string "_") " " (to_string (member "name" json)))::l
    else l
    in
  List.fold_left get_tags [] (to_assoc json_tags)
