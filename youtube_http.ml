
(*
** Binding http of youtube API with ocaml
*)

(*
** exceptions
*)
exception Bad_youtube_url of string

(*
** Types
*)
(* private *)
type id = string

(* public *)
type title = string
type url = string
type sliced_description = string
type topic_ids = string list
type relevant_topic_ids = string list
type categories = (topic_ids * relevant_topic_ids)
type video = (id * title * url * sliced_description * categories)

(*
** PRIVATE
*)

(*** Conf ***)
(* API Key *)
let g_youtube_api_key = "AIzaSyBlcjTwKF9UmOqnnExTZGgdY9nwS_0C5A8"

(* youtube url *)
let g_api_base_url = "https://www.googleapis.com/youtube/v3/"
let g_video_base_url = "https://www.youtube.com/watch?v="

(*** Url creators ***)
let create_youtube_search_url query parts fields max_results type_of_result =
  g_api_base_url ^ "search"
  ^ "?type=" ^ type_of_result
  ^ "&part=" ^ parts
  ^ "&fields=" ^ fields
  ^ "&maxResults=" ^ max_results
  ^ "&q=" ^ query
  ^ "&key=" ^ g_youtube_api_key

let create_youtube_video_url video_ids parts fields =
  g_api_base_url
  ^ "videos?id=" ^ (Bfy_helpers.strings_of_list video_ids ",")
  ^ "&part=" ^ parts
  ^ "&fields=" ^ fields
  ^ "&key=" ^ g_youtube_api_key

(*** json accessors ***)
let get_items_field json =
  Yojson_wrap.to_list (Yojson_wrap.member "items" json)

let get_kind_field json =
  Yojson_wrap.to_string (Yojson_wrap.member "kind" json)

let get_id_field json =
  Yojson_wrap.member "id" json

let get_videoId_field json =
  Yojson_wrap.to_string (Yojson_wrap.member "videoId" json)

let get_snippet_field json =
  Yojson_wrap.member "snippet" json

let get_title_field json =
  Yojson_wrap.to_string (Yojson_wrap.member "title" json)

let get_description_field json =
  Yojson_wrap.to_string (Yojson_wrap.member "description" json)

let get_topicDetails_field json =
  Yojson_wrap.member "topicDetails" json

let get_topicIds_field json =
  List.map
    Yojson_wrap.to_string
    (Yojson_wrap.to_list (Yojson_wrap.member "topicIds" json))

let get_relevantTopicIds_field json =
  List.map
    Yojson_wrap.to_string
    (Yojson_wrap.to_list (Yojson_wrap.member "relevantTopicIds" json))

(*** Unclassed ***)
let videos_of_json json =
  let get_video_id item =
    let item_id = get_id_field item in
    match item_id with
    | `String s -> s
    | `Assoc a -> get_videoId_field item_id
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
    let id = get_video_id item in
    let url = g_video_base_url ^ id in
    let description =
      Bfy_helpers.reduce_string (get_description_field snippet) 50 in
    let categories = get_categories item
    in
    (id, get_title_field snippet, url, description, categories)
  in
  List.map create_video (get_items_field json)

(*
** PUBLIC
*)

(*** Constructors ***)
(** create an id from a youtube url.
    An exception will be raised if the url is not correct *)
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
(** Print a video on stdout *)
let print_youtube_video (id, title, url, description, categories) =
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
    ^"->Id:\"" ^ id ^ "\"\n"
    ^ "->Title:\"" ^ title ^ "\"\n"
    ^ "->Url:\"" ^ url ^ "\"\n"
    ^ "->Description:\"" ^ description ^ "\"\n"
    ^ "->Categories:" ^ (string_of_categories categories) ^ "\n")

(*** Requests ***)

(**
** return a list of video from a list of id
*)
let get_videos_from_ids video_ids =
  let youtube_url_http =
    create_youtube_video_url
      video_ids
      "snippet,topicDetails"
      "items(id,snippet(title,description),topicDetails)" in
  lwt youtube_json = Http_request_manager.request ~display_body:false youtube_url_http
  in
  Lwt.return (videos_of_json youtube_json)


(**
** get a list of video from a research
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
  let get_id_from_video (id, _, _, _, _) = id in
  lwt youtube_json = Http_request_manager.request ~display_body:false url in
  let videos = videos_of_json youtube_json in
  let ids = (List.map get_id_from_url (List.map get_id_from_video videos)) in
  get_videos_from_ids ids
