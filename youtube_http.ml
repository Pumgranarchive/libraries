
(*
** Binding http of youtube API with ocaml
*)

(*
** PRIVATE
*)


(*** youtube API ***)
(* API Key *)
let youtube_api_key = "AIzaSyBlcjTwKF9UmOqnnExTZGgdY9nwS_0C5A8"

(* item kind (API values) *)
(* let search_result_item_kind = "youtube#searchResult" *)
(* let video_item_kind = "youtube#video" *)

(*** youtube url ***)
let youtube_base_url = "https://www.googleapis.com/youtube/v3/"

(*** Url creator ***)
let create_youtube_search_url query parts max_results =
  youtube_base_url ^ "search"
  ^ "?part=" ^ parts
  ^ "&maxResults=" ^ max_results
  ^ "&q=" ^ query
  ^ "&key=" ^ youtube_api_key

let create_youtube_search_url query parts max_results type_of_result =
  youtube_base_url ^ "search"
  ^ "?type=" ^ type_of_result
  ^ "&part=" ^ parts
  ^ "&maxResults=" ^ max_results
  ^ "&q=" ^ query
  ^ "&key=" ^ youtube_api_key

(* let create_youtube_video_url video_id parts = *)
(*   youtube_base_url *)
(*   ^ "videos?id=" ^ video_id *)
(*   ^ "&part=" ^ parts *)
(*   ^ "&key=" ^ youtube_api_key *)

let create_youtube_video_url video_ids parts =
  let rec comma_separated_strings_of_list video_ids =
    List.fold_right (fun l r -> l ^ "," ^ r) video_ids ""
  in
  youtube_base_url
  ^ "videos?id=" ^ (comma_separated_strings_of_list video_ids)
  ^ "&part=" ^ parts
  ^ "&key=" ^ youtube_api_key


(*** json accessors ***)
let get_items_field json =
  Yojson.Basic.Util.to_list (Yojson.Basic.Util.member "items" json)

let get_kind_field json =
  Yojson.Basic.Util.to_string (Yojson.Basic.Util.member "kind" json)

let get_id_field json =
  Yojson.Basic.Util.member "id" json

let get_videoid_field json =
  Yojson.Basic.Util.to_string (Yojson.Basic.Util.member "videoId" json)

let get_snippet_field json =
  Yojson.Basic.Util.member "snippet" json

let get_title_field json =
  Yojson.Basic.Util.to_string (Yojson.Basic.Util.member "title" json)

let get_description_field json =
  Yojson.Basic.Util.to_string (Yojson.Basic.Util.member "description" json)

let get_video_url item =
  let item_id = get_id_field item in
  let get_url_from_assoc assoc =
    get_videoid_field assoc
  in
  match item_id with
  | `String s -> s
  | `Assoc a -> get_url_from_assoc item_id
  | _   -> "Unable to find url"



(* DEBUG: Printer *)
let print_youtube_json json =
  let print_current_item item =
    let snippet = get_snippet_field item in
    let url = get_video_url item
    in
    print_endline (
      "<== ITEM ==>\n"
      ^"-->Title:\"" ^ (get_title_field snippet) ^ "\"\n"
      ^ "-->Url:\"" ^ url ^ "\"\n"
      ^ "-->Description:\"" ^ (get_description_field snippet) ^ "\"\n") in
  List.map print_current_item (get_items_field json)


(* a video is a tuple (title * url * description) *)
(* TODO: limit description to 50 chars *)
let video_of_json json =
  let create_video current_item =
    let snippet = get_snippet_field current_item in
    let url = get_video_url current_item in
    (get_title_field snippet, url, get_description_field snippet)
  in
  List.map create_video (get_items_field json)

(*
** PUBLIC
*)

let print_youtube_video (title, url, description) =
  print_endline (
    "<== Video ==>\n"
    ^"->Title:\"" ^ title ^ "\"\n"
    ^ "->Url:\"" ^ url ^ "\"\n"
    ^ "->Description:\"" ^ description ^ "\"\n")

(*** Other ***)

(**
** This function will make an http request and return a list of video as a list of tup** le (title * url * description)
*)
let search_video request max_result =
  let url =
    create_youtube_search_url request "snippet" max_result "video"
  in
  lwt youtube_json = Http_request_manager.request ~display_body:false url in
  Lwt.return (video_of_json youtube_json)

let get_video_from_url video_urls =
  (* README: Changing "uri_reg" may change the behavior of "extract_id url" because of "Str.group_end n"*)
  let uri_reg =
    Str.regexp "\\(https?://\\)?\\(www\\.\\)?youtu\\(\\.be/\\|be\\.com/\\)\\(\\(.+/\\)?\\(watch\\(\\?v=\\|.+&v=\\)\\)?\\(v=\\)?\\)\\([-A-Za-z0-9_]\\)*\\(&.+\\)?" in
  let get_id_from_url url =
    let is_url_from_youtube url = Str.string_match uri_reg url 0 in
    let extract_id_from_url url =
      let _ = Str.string_match uri_reg url 0 in
      let id_start = Str.group_end 4 and id_end = Str.group_end 9 in
      String.sub url id_start (id_end - id_start)
    in
    if (is_url_from_youtube url) = false
    then ""
    else extract_id_from_url url
  in
  let video_ids = List.map get_id_from_url video_urls in
  let youtube_url_http = create_youtube_video_url video_ids "snippet" in
  lwt youtube_json = Http_request_manager.request youtube_url_http
  in
  Lwt.return (video_of_json youtube_json)
