
(*
** Binding http of youtube API with ocaml
*)

(*
** exceptions
*)
exception Bad_youtube_url of string
exception Yojson_exc of string

(*
** Types
*)
(* private *)
type id = string

(* public *)
type title = string
type url = string
type tight_description = string
type topic_ids = string list
type relevant_topic_ids = string list
type categories = (topic_ids * relevant_topic_ids)
type video = (title * url * tight_description * categories)

(*
** PRIVATE
*)

(*** Conf ***)
(* size of sliced description field got from the json of a video*)
let g_description_size = 50


(*** youtube API ***)
(* API Key *)
let g_youtube_api_key = "AIzaSyBlcjTwKF9UmOqnnExTZGgdY9nwS_0C5A8"

(* item kind (API values) *)
(* let search_result_item_kind = "youtube#searchResult" *)
(* let video_item_kind = "youtube#video" *)

(*** youtube url ***)
let g_youtube_base_url = "https://www.googleapis.com/youtube/v3/"

(*** Url creator ***)
let create_youtube_search_url query parts fields max_results type_of_result =
  g_youtube_base_url ^ "search"
  ^ "?type=" ^ type_of_result
  ^ "&part=" ^ parts
  ^ "&fields=" ^ fields
  ^ "&maxResults=" ^ max_results
  ^ "&q=" ^ query
  ^ "&key=" ^ g_youtube_api_key

let create_youtube_video_url video_ids parts fields =
  let rec comma_separated_strings_of_list video_ids =
    List.fold_right (fun l r -> l ^ "," ^ r) video_ids ""
  in
  g_youtube_base_url
  ^ "videos?id=" ^ (comma_separated_strings_of_list video_ids)
  ^ "&part=" ^ parts
  ^ "&fields=" ^ fields
  ^ "&key=" ^ g_youtube_api_key


(** same as Yojson.Basic.Util.member but return `Null if json is null *)
let member name json = match json with
  | `Null       -> `Null
  | _           -> Yojson.Basic.Util.member name json

(** Extract a list from JSON array or raise Yojson_exc.
    `Null are assume as empty list. *)
let to_list = function
  | `Null   -> []
  | `List l -> l
  | _       -> raise (Yojson_exc "Bad list format")

(** Extract a list from JSON array or raise Yojson_exc.
    `Null are assume as empty list. *)
let to_string = function
  | `Null   -> ""
  | `String s -> s
  | _       -> raise (Yojson_exc "Bad list format")


(*** json accessors ***)
let get_items_field json =
  to_list (member "items" json)

let get_kind_field json =
  to_string (member "kind" json)

let get_id_field json =
  member "id" json

let get_videoId_field json =
  to_string (member "videoId" json)

let get_snippet_field json =
  member "snippet" json

let get_title_field json =
  to_string (member "title" json)

let get_description_field json =
  to_string (member "description" json)

let get_topicDetails_field json =
  member "topicDetails" json

let get_topicIds_field json =
  List.map
    to_string
    (to_list (member "topicIds" json))

let get_relevantTopicIds_field json =
  List.map
    to_string
    (to_list (member "relevantTopicIds" json))

let video_of_json json =
  let get_video_url item =
    let item_id = get_id_field item in
    let get_url_from_assoc assoc =
      get_videoId_field assoc
    in
    match item_id with
    | `String s -> s
    | `Assoc a -> get_url_from_assoc item_id
    | _   -> "Unable to find url"
  in
  let get_categories item =
    let topic_details = get_topicDetails_field item in
    let topic_ids = get_topicIds_field topic_details in
    let relevant_topic_ids = get_relevantTopicIds_field topic_details in
    (topic_ids,relevant_topic_ids)
  in
  let create_video item =
    let snippet = get_snippet_field item in
    let url = get_video_url item in
    let description =
      let tmp = (get_description_field snippet) in
      if String.length tmp > g_description_size
      then (String.sub tmp 0 g_description_size) ^ "..."
      else tmp in
    let categories = get_categories item
    in
    (get_title_field snippet, url, description, categories)
  in
  List.map create_video (get_items_field json)

(*
** PUBLIC
*)

(*** Constructors ***)
let get_id_from_url url =
  (* README: Changing "uri_reg" may change the behavior of "extract_id url" because of "Str.group_end n"*)
  let uri_reg =
    Str.regexp "\\(https?://\\)?\\(www\\.\\)?youtu\\(\\.be/\\|be\\.com/\\)\\(\\(.+/\\)?\\(watch\\(\\?v=\\|.+&v=\\)\\)?\\(v=\\)?\\)\\([-A-Za-z0-9_]\\)*\\(&.+\\)?" in
  let is_url_from_youtube url = Str.string_match uri_reg url 0 in
  let extract_id_from_url url =
    let _ = Str.string_match uri_reg url 0 in
    let id_start = Str.group_end 4 and id_end = Str.group_end 9 in
    String.sub url id_start (id_end - id_start)
  in
  if (is_url_from_youtube url) = false
  then raise (Bad_youtube_url "Youtube url pattern not recognized.")
  else extract_id_from_url url


(*** Printing ***)

let print_youtube_video (title, url, description, categories) =
  let string_of_categories (topic_ids, relevant_topic_ids) =
    let rec aux = function
      | h::t    -> "\n    -" ^ h ^ (aux t)
      | _       -> ""
    in
    "\n  -TopicIds:" ^ (aux topic_ids)
    ^ "\n  -RelevantTopicIds:" ^ (aux relevant_topic_ids)
  in
  print_endline (
    "<== Video ==>\n"
    ^"->Title:\"" ^ title ^ "\"\n"
    ^ "->Url:\"" ^ url ^ "\"\n"
    ^ "->Description:\"" ^ description ^ "\"\n"
    ^ "->Categories:" ^ (string_of_categories categories) ^ "\n")

(*** Requests ***)

(**
** This function will make an http request and return a list of video as a list of tup** le (title * url * description)
*)
let search_video request max_result =
  let url =
    create_youtube_search_url
      request
      "snippet"
      "items(id,snippet(title,description))"
      (string_of_int max_result)
      "video"
  in
  lwt youtube_json = Http_request_manager.request ~display_body:false url in
  (* TODO: get_video_from_id *)
  Lwt.return (video_of_json youtube_json)

let get_video_from_id video_ids =
  let youtube_url_http =
    create_youtube_video_url
      video_ids
      "snippet,topicDetails"
      "items(id,snippet(title,description),topicDetails)" in
  lwt youtube_json = Http_request_manager.request ~display_body:false youtube_url_http
  in
  Lwt.return (video_of_json youtube_json)
