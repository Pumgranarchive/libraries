
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
type video_id = string

(* public *)
type title = string
type url = string
type sliced_description = string
type topic_ids = string list
type relevant_topic_ids = string list
type categories = (topic_ids * relevant_topic_ids)

type video = (video_id * title * url * sliced_description * categories)

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
let create_search_url query parts fields max_results type_of_result =
  g_api_base_url ^ "search"
  ^ "?type=" ^ type_of_result
  ^ "&part=" ^ parts
  ^ "&fields=" ^ fields
  ^ "&maxResults=" ^ max_results
  ^ "&q=" ^ query
  ^ "&key=" ^ g_youtube_api_key

let create_video_url video_ids parts fields =
  g_api_base_url
  ^ "videos?id=" ^ (Bfy_helpers.strings_of_list video_ids ",")
  ^ "&part=" ^ parts
  ^ "&fields=" ^ fields
  ^ "&key=" ^ g_youtube_api_key

let create_playlist_item_url playlist_id ?(page_token = None) max_results parts fields  =
  let page_token =
    match page_token with Some s -> ("&pageToken=" ^ s) | None -> "" in
  g_api_base_url
  ^ "playlistItems?playlistId=" ^ playlist_id
  ^ page_token
  ^ "&maxResults=" ^ max_results
  ^ "&part=" ^ parts
  ^ "&fields=" ^ fields
  ^ "&key=" ^ g_youtube_api_key

let create_channel_url_from_id ?(id = None) ?(user_name = None) parts fields =
  let id =
    match id with Some ids -> ("?id=" ^ (Bfy_helpers.strings_of_list (ids) ",")) | None -> "" in
  let user_name =
    match user_name with Some name -> ("?forUsername=" ^ name) | None -> "" in
  g_api_base_url
  ^ "channels"
  ^ id
  ^ user_name
  ^ "&part=" ^ parts
  ^ "&fields=" ^ fields
  ^ "&key=" ^ g_youtube_api_key

(*** json accessors ***)
let get_nextPageToken_field json =
  Yojson_wrap.to_string (Yojson_wrap.member "nextPageToken" json)

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

(* channel fields *)
let get_contentDetails_field json =
  Yojson_wrap.member "contentDetails" json

let get_relatedPlaylists_field json =
  Yojson_wrap.member "relatedPlaylists" json

let get_uploads_field json =
  Yojson_wrap.to_string (Yojson_wrap.member "uploads" json)

let get_statistics_field json =
  Yojson_wrap.member "statistics" json

let get_videoCount_field json =
  Yojson_wrap.to_string (Yojson_wrap.member "videoCount" json)


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
let get_video_id_from_url url =
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
    create_video_url
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
    create_search_url
      request
      "snippet"
      "items(id,snippet(title,description))"
      (string_of_int max_result)
      "video"
  in
  let get_id_from_video (id, _, _, _, _) = id in
  lwt youtube_json = Http_request_manager.request ~display_body:false url in
  let videos = videos_of_json youtube_json in
  let ids = (List.map get_id_from_video videos) in
  get_videos_from_ids ids


(**
** return a list of video from an id
*)
let get_videos_from_playlist_id playlist_id max_result =
  let get_id item = get_videoId_field (get_contentDetails_field item) in
  let rec aux playlist_id ?(page_token = None) max_result =
    let (max_result, next_max_result) =
      if max_result > 50 then (50, max_result - 50) else (max_result, 0) in
    let youtube_url_http =
      create_playlist_item_url
        playlist_id
        ~page_token:page_token
        (string_of_int max_result)
        "id,contentDetails,snippet"
        "nextPageToken,items(contentDetails(videoId),snippet(position))"
    in
    lwt youtube_json = Http_request_manager.request ~display_body:false youtube_url_http in
    let next_page_token = get_nextPageToken_field youtube_json in
    lwt ids = get_videos_from_ids (List.map get_id (get_items_field youtube_json)) in
    if next_max_result = 0 || next_page_token = ""
    then (Lwt.return ids)
    else (lwt new_ids = aux playlist_id (~page_token:(Some next_page_token)) next_max_result in Lwt.return (ids@new_ids))
  in
  aux playlist_id max_result


(**
** return a list of video from a channel id or username
*)
(* NOTE: this function is private and can't be moved in private section *)
(* TODO:
** - remove List.hd and process all channels
** - add max_result based on number channel expected
*)
let get_uploaded_videos_from_channel ids user_name =
  let youtube_url_http =
    create_channel_url_from_id
      ~id:ids
      ~user_name:user_name
      "contentDetails,statistics"
      "items(contentDetails(relatedPlaylists(uploads)),statistics(videoCount))" in
  lwt youtube_json = Http_request_manager.request ~display_body:false youtube_url_http in
  let item = List.hd(get_items_field youtube_json) in
  let content_details = (get_contentDetails_field item) in
  let playlist_id = get_uploads_field (get_relatedPlaylists_field content_details) in
  let video_count = get_videoCount_field (get_statistics_field item) in
  get_videos_from_playlist_id playlist_id (int_of_string video_count)

let get_uploaded_videos_from_channel_ids ids =
  get_uploaded_videos_from_channel (Some ids) None

let get_uploaded_videos_from_user_name user_name =
  get_uploaded_videos_from_channel None (Some user_name)

