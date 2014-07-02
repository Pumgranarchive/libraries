(*
** Binding http of freebase with ocaml
*)

(*
** PRIVATE
*)

(*** freebase url ***)
let api_base_url = "https://www.googleapis.com/freebase/v1/"
let api_search_url = api_base_url ^ "search?query="
let api_topic_url = api_base_url ^ "topic"

(*** url creators ***)
let create_search_url request = api_search_url ^ request
let create_topic_url ids filter lang =
  api_topic_url ^ ids
  ^ "?filter=" ^ (Bfy_helpers.strings_of_list filter "&filter=")
  ^ "&lang=" ^ lang

(*** json accessor ***)
let get_result_field json =
  Yojson_wrap.(to_list (member "result" json))

let get_mid_field json =
  Yojson_wrap.(to_string (member "mid" json))

let get_property_field json =
  Yojson_wrap.member "property" json

let get_ctdescription_field json =
  Yojson_wrap.member "/common/topic/description" json

let get_values_field json =
  Yojson_wrap.(to_list (member "values" json))

let get_value_field json =
  Yojson_wrap.(to_string (member "value" json))

let get_id_field json =
  Yojson_wrap.(to_string (member "id" json))

let get_text_field json =
  Yojson_wrap.(to_string (member "text" json))

let get_ctsocial_media_presence_field json =
  Yojson_wrap.member "/common/topic/social_media_presence" json

let get_toname_field json =
  Yojson_wrap.member "/type/object/name" json

let get_totype_field json =
  Yojson_wrap.member "/type/object/type" json

let get_cttopic_equivalent_webpage_field json =
  Yojson_wrap.member "/common/topic/topic_equivalent_webpage" json

(*** Unclassed ***)
let freebase_object_of_json json =
  let id = get_id_field json in
  let property = get_property_field json in
  let sliced_description =
    let ct_descr = List.hd (get_values_field (get_ctdescription_field property)) in
    get_text_field ct_descr in
  let social_media_presences =
    List.map
      get_value_field
      (get_values_field (get_ctsocial_media_presence_field property)) in
  let name =
    get_value_field (List.hd (get_values_field (get_toname_field property))) in
  let types =
    let create_type json = (get_id_field json, get_text_field json) in
    List.map create_type (get_values_field (get_totype_field property)) in
  let rec wiki_url =
    let rec get_wiki_url =
      let uri_reg =
        Str.regexp "\\(https?://\\)?\\(www\\.\\)?en\\.wikipedia.org/wiki/.+" in
      let is_en_wiki_url url = Str.string_match uri_reg url 0 in
      function
      | (url::t)  ->
        if ((is_en_wiki_url url) = true)
        then [url]
        else get_wiki_url t
      | _       -> []
    in
    let url_list =
      List.map
        get_value_field
        (get_values_field (get_cttopic_equivalent_webpage_field property))
    in
    get_wiki_url url_list
  in
  (id, name, sliced_description, social_media_presences, types, wiki_url)

(*
** PUBLIC
*)

(*** printing ***)
let print_freebase_object
    (id, name, sliced_description, sm_presences, types, wiki_url) =
  let rec string_of_sm = function
    | (h::t)    -> "\n  -" ^ h ^ (string_of_sm t)
    | _         -> "" in
  let rec string_of_type = function
    | (id, text)::t     ->
      "\n  -id:\"" ^ id ^ "\"\n  -text:\"" ^ text ^ "\"\n" ^ (string_of_type t)
    | _                 -> ""
  in
  print_endline ("\n<== Freebase object ==>\n"
    ^"->id:\"" ^ id ^ "\"\n"
    ^ "->name:\"" ^ name ^ "\"\n"
    ^ "->sliced_description:\"" ^ sliced_description ^ "\"\n"
    ^ "->sm_presences:" ^ (string_of_sm sm_presences) ^ "\n"
    ^ "->types:" ^ (string_of_type types) ^ "\n"
    ^ "->wiki_url:\"" ^ (List.hd wiki_url) ^ "\"\n")


(*** requests ***)
let search query =
  let url = create_search_url query in
  lwt freebase_json = Http_request_manager.request url
  in
  Lwt.return (freebase_json)

(* TODO: ids must become a list *)
let get_topics ids =
  let url =
    create_topic_url
      ids
      [
        "/common/topic/description";
        "/common/topic/topic_equivalent_webpage";
        "/type/object/name";
        "/type/object/type";
        "/common/topic/description";
        "/common/topic/social_media_presence"
      ]
      "en"
  in
  lwt freebase_json = Http_request_manager.request ~display_body:false url
  in
  Lwt.return (freebase_object_of_json freebase_json)

