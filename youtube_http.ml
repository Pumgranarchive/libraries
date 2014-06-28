
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
type id = string
type title = string
type url = string
type description = string
type video = (title * url * description)

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
let create_youtube_search_url query parts max_results =
  g_youtube_base_url ^ "search"
  ^ "?part=" ^ parts
  ^ "&maxResults=" ^ max_results
  ^ "&q=" ^ query
  ^ "&key=" ^ g_youtube_api_key

let create_youtube_search_url query parts max_results type_of_result =
  g_youtube_base_url ^ "search"
  ^ "?type=" ^ type_of_result
  ^ "&part=" ^ parts
  ^ "&maxResults=" ^ max_results
  ^ "&q=" ^ query
  ^ "&key=" ^ g_youtube_api_key

let create_youtube_video_url video_ids parts =
  let rec comma_separated_strings_of_list video_ids =
    List.fold_right (fun l r -> l ^ "," ^ r) video_ids ""
  in
  g_youtube_base_url
  ^ "videos?id=" ^ (comma_separated_strings_of_list video_ids)
  ^ "&part=" ^ parts
  ^ "&key=" ^ g_youtube_api_key


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


let video_of_json json =
  let create_video current_item =
    let snippet = get_snippet_field current_item in
    let url = get_video_url current_item in
    let description =
      let tmp = (get_description_field snippet) in
      if String.length tmp > g_description_size
      then (String.sub tmp 0 g_description_size) ^ "..."
      else tmp
    in
    (get_title_field snippet, url, description)
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

let print_youtube_video (title, url, description) =
  print_endline (
    "<== Video ==>\n"
    ^"->Title:\"" ^ title ^ "\"\n"
    ^ "->Url:\"" ^ url ^ "\"\n"
    ^ "->Description:\"" ^ description ^ "\"\n")

(*** Requests ***)

(**
** This function will make an http request and return a list of video as a list of tup** le (title * url * description)
*)
let search_video request max_result =
  let url =
    create_youtube_search_url request "snippet" (string_of_int max_result) "video"
  in
  lwt youtube_json = Http_request_manager.request ~display_body:false url in
  Lwt.return (video_of_json youtube_json)

let get_video_from_id video_ids =
  let youtube_url_http = create_youtube_video_url video_ids "snippet" in
  lwt youtube_json = Http_request_manager.request youtube_url_http
  in
  Lwt.return (video_of_json youtube_json)
