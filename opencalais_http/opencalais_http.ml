(**
   {b OpenCalais -
   A ocaml OpenCalais binding}
*)

open Yojson.Basic

(******************************************************************************
****************************** Configuration **********************************
*******************************************************************************)

(* let opencalais_uri = ref (Uri.of_string "http://api.opencalais.com/tag/rs/enrich") *)
let opencalais_uri = ref (Uri.of_string "https://api.thomsonreuters.com/permid/calais")
let token = ref ""

(******************************************************************************
********************************** Tools **************************************
*******************************************************************************)

let set_uri = (:=) opencalais_uri
let set_token = (:=) token

let base_headers length =
  let headers = Cohttp.Header.init_with "accept" "application/json" in
  let headers = Cohttp.Header.add headers "x-ag-access-token" !token in
  let headers = Cohttp.Header.add headers "content-type" "text/html" in
  let headers = Cohttp.Header.add headers "outputformat" "application/json" in
  let headers = Cohttp.Header.add headers "content-length" (string_of_int length) in
  Cohttp.Header.add headers "enableMetadataType" "SocialTags"

(******************************************************************************
********************************* Binding *************************************
*******************************************************************************)

let request text =
  let body = ((Cohttp.Body.of_string text) :> Cohttp_lwt_body.t) in
  let length = String.length text in
  let headers = base_headers length in
  lwt (header, rbody) =
      Cohttp_lwt_unix.Client.post ~body ~chunked:false ~headers !opencalais_uri
  in
  lwt rbody_string = Cohttp_lwt_body.to_string rbody in
  Lwt.return (from_string rbody_string)

let to_social_tags json =
  let open Yojson.Basic.Util in
  let aux blist (title, elm) =
    let type_group = member "_typeGroup" elm in
    if (type_group != `Null &&
        String.compare (to_string type_group) "socialTag" == 0)
    then
      let name = to_string (member "name" elm) in
      let name' = Str.global_replace (Str.regexp "[_\\.]") " " name in
      name'::blist
    else blist
  in
  let list = to_assoc json in
  List.fold_left aux [] list
