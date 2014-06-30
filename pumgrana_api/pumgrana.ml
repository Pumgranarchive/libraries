(**
   Pumgrana
   The Http Pumgrana API Binding
*)

module Yojson = Yojson.Basic

open Ptype

exception Internal_error of string

(******************************************************************************
****************************** Configuration **********************************
*******************************************************************************)

let pumgrana_api_uri = ref "http://127.0.0.1:8081/api/"

let content_uri = "content/"
let content_detail_uri = content_uri ^ "detail/"
let contents_uri = content_uri ^ "list_content/"

let tag_uri = "tag/"
let tag_type_uri = tag_uri ^ "list_by_type/"
let tag_content_uri = tag_uri ^ "list_from_content/"
let tag_content_links_uri = tag_uri ^ "list_from_content_links/"

let link_uri = "link/"
let link_detail_uri = link_uri ^ "detail/"
let link_content_uri = link_uri ^ "from_content/"
let link_content_tags_uri = link_uri ^ "from_content_tags/"

(******************************************************************************
********************************** Tools **************************************
*******************************************************************************)

let set_pumgrana_api_uri uri =
  pumgrana_api_uri := string_of_uri uri

let slash_encode str =
  let regexp = Str.regexp "/" in
  Str.global_replace regexp "%2F" str

let string_of_filter = function
  | Most_recent -> "MOST_RECENT"
  | Most_used   -> "MOST_USED"
  | Most_view   -> "MOST_VIEW"

let string_of_type_name = function
  | Content     -> "CONTENT"
  | Link        -> "LINK"

let append str p =
  if String.length str == 0
  then (slash_encode p)
  else str ^ "/" ^ (slash_encode p)

let map f = function
  | Some x -> Some (f x)
  | None   -> None

let add_p p str = match p with
  | Some p -> append str p
  | None   -> str

let add_p_list opt_lp str = match opt_lp with
  | Some lp -> (List.fold_left (fun str p -> append str p) str lp)
  | None    -> str

let base_headers () =
  Cohttp.Header.init_with "accept" "application/json"

let get uri parameters =
  let headers = base_headers () in
  let uri = !pumgrana_api_uri ^ uri ^ parameters in
  print_endline uri;
  let uri = Uri.of_string uri in
  lwt header, body = Cohttp_lwt_unix.Client.get ~headers uri in
  lwt body_string = Cohttp_lwt_body.to_string body in
  Lwt.return (Yojson.from_string body_string)

(******************************************************************************
********************************* Content *************************************
*******************************************************************************)

let get_content_detail content_uri =
  let parameter = string_of_uri content_uri in
  lwt json = get content_detail_uri parameter in
  Lwt.return (List.hd Pdeserialize.(get_service_return get_content_list json))

let get_contents ?filter ?tags_uri () =
  let str_filter = map string_of_filter filter in
  let str_tags_uri = map (List.map string_of_uri) tags_uri in
  let parameters = (add_p_list str_tags_uri (add_p str_filter "")) ^ "/" in
  lwt json = get contents_uri parameters in
  Lwt.return (Pdeserialize.(get_service_return get_short_content_list json))

(******************************************************************************
*********************************** Tag ***************************************
*******************************************************************************)

let tags_by_type type_name =
  let parameter = string_of_type_name type_name in
  lwt json = get tag_type_uri parameter in
  Lwt.return (Pdeserialize.(get_service_return get_tag_list json))

let tags_from_content content_uri =
  let parameter = string_of_uri content_uri in
  lwt json = get tag_content_uri parameter in
  Lwt.return (Pdeserialize.(get_service_return get_tag_list json))

let tags_from_content_links content_uri =
  let parameter = string_of_uri content_uri in
  lwt json = get tag_content_links_uri parameter in
  Lwt.return (Pdeserialize.(get_service_return get_tag_list json))


(******************************************************************************
*********************************** Link **************************************
*******************************************************************************)

let get_link_detail link_id =
  let parameter = string_of_link_id link_id in
  lwt json = get link_detail_uri parameter in
  Lwt.return (List.hd Pdeserialize.(get_service_return get_detail_link_list json))

let links_from_content content_uri =
  let parameter = string_of_uri content_uri in
  lwt json = get link_content_uri parameter in
  Lwt.return (Pdeserialize.(get_service_return get_link_list json))

let links_from_content_tags content_uri tags_uri =
  let content_str_uri = string_of_uri content_uri in
  let str_tags_uri = List.map string_of_uri tags_uri in
  let parameters =
    (List.fold_left append (append "" content_str_uri) str_tags_uri ) ^ "/"
  in
  lwt json = get link_content_tags_uri parameters in
  Lwt.return (Pdeserialize.(get_service_return get_link_list json))


(******************************************************************************
*********************************** Test **************************************
*******************************************************************************)

lwt _ =
  lwt res = get_contents () in
  let print (uri, title, summary) =
    let str_uri = string_of_uri uri in
    Printf.printf "[%s] %s - %s\n" str_uri title summary
  in
  Lwt.return (List.map print res)

(* lwt _ = *)
(*   let uri = uri_of_string *)
(*     "http://pumgrana.com/content/detail/52780cbdc21477f7aa5b9107" *)
(*   in *)
(*   lwt res = get_content_detail uri in *)
(*   let print (uri, title, summary, opt_body) = *)
(*     let str_uri = string_of_uri uri in *)
(*     Printf.printf "\n[%s] %s - %s\n" str_uri title summary; *)
(*     match opt_body with *)
(*     | Some body -> print_endline body *)
(*     | None      -> () *)
(*   in *)
(*   Lwt.return (print res) *)
