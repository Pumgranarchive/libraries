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

(* let _ = set_token "z3k9bmug6udbqcqdwgt8qzq2" *)

(* let body = "The Hobbit, or There and Back Again, is a fantasy novel and children's book by English author J. R. R. Tolkien. It was published on 21 September 1937 to wide critical acclaim, being nominated for the Carnegie Medal and awarded a prize from the New York Herald Tribune for best juvenile fiction. The book remains popular and is recognized as a classic in children's literature." *)

(* lwt json_result = request ~display_body:true body *)
