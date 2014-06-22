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
let search_result_item_kind = "youtube#searchResult"
let video_item_kind = "youtube#video"

(*** youtube url ***)
let youtube_url = "https://www.googleapis.com/youtube/v3/"

(*** json accessors ***)
let get_items_field json =
  Yojson.Basic.Util.to_list (Yojson.Basic.Util.member "items" json)

let get_kind_field json =
  Yojson.Basic.Util.to_string (Yojson.Basic.Util.member "kind" json)

let get_id_field json =
  Yojson.Basic.Util.member "id" json

let get_video_id_field json =
  Yojson.Basic.Util.to_string (Yojson.Basic.Util.member "videoId" json)

let get_snippet_field json =
  Yojson.Basic.Util.member "snippet" json

let get_title_field json =
  Yojson.Basic.Util.to_string (Yojson.Basic.Util.member "title" json)

let get_description_field json =
  Yojson.Basic.Util.to_string (Yojson.Basic.Util.member "description" json)

let get_video_url item =
  let item_kind = get_kind_field item in
  let item_id = get_id_field item in
  let get_url_from_string item_id = Yojson.Basic.Util.to_string item_id in
  let get_url_from_object item_id =
    if get_kind_field item_id = video_item_kind
    then get_video_id_field item_id
    else "Not_a_video --> " ^ (get_kind_field item_id)
  in
  if item_kind = video_item_kind
  then get_url_from_string item_id
  else get_url_from_object item_id

(*
** PUBLIC
*)

(*** Url creator ***)
let create_youtube_search_url query parts max_results =
  youtube_url ^"search"
  ^ "?part=" ^ parts
  ^ "&maxResults=" ^ max_results
  ^ "&q=" ^ query
  ^ "&key=" ^ youtube_api_key

let create_youtube_video_url video_id parts =
  youtube_url
  ^ "videos?id=" ^ video_id
  ^ "&part=" ^ parts
  ^ "&key=" ^ youtube_api_key


(*** Printer ***)
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
  let rec print_video_infos = function
    | (h::t)      -> (print_current_item h); print_video_infos t
    | _           -> ()
  in
  print_video_infos (get_items_field json)
