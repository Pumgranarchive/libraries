(**
   Pumgrana
   The Http Pumgrana API Binding
*)

module Yojson = Yojson.Basic

open Ptype

exception Pumgrana of string

(******************************************************************************
****************************** Configuration **********************************
*******************************************************************************)

let pumgrana_api_uri = ref "http://127.0.0.1:8081/api/"

let content_uri = "content/"
let content_detail_uri = content_uri ^ "detail/"
let contents_uri = content_uri ^ "list_content/"
let content_insert_uri = content_uri ^ "insert"
let content_update_uri = content_uri ^ "update"
let content_update_tags_uri = content_uri ^ "update_tags"
let content_delete_uri = content_uri ^ "delete"

let tag_uri = "tag/"
let tag_type_uri = tag_uri ^ "list_by_type/"
let tag_content_uri = tag_uri ^ "list_from_content/"
let tag_content_links_uri = tag_uri ^ "list_from_content_links/"
let tag_insert_uri = tag_uri ^ "insert"
let tag_delete_uri = tag_uri ^ "delete"

let link_uri = "link/"
let link_detail_uri = link_uri ^ "detail/"
let link_content_uri = link_uri ^ "from_content/"
let link_content_tags_uri = link_uri ^ "from_content_tags/"
let link_insert_uri = link_uri ^ "insert"
let link_update_uri = link_uri ^ "update"
let link_delete_uri = link_uri ^ "delete"

(******************************************************************************
********************************** Tools **************************************
*******************************************************************************)

let set_pumgrana_api_uri uri =
  pumgrana_api_uri := string_of_uri uri

let string_of_filter = function
  | Most_recent -> "MOST_RECENT"
  | Most_used   -> "MOST_USED"
  | Most_view   -> "MOST_VIEW"

let string_of_type_name = function
  | Content     -> "CONTENT"
  | Link        -> "LINK"

let append str p =
  if String.length str == 0
  then (uri_encode p)
  else str ^ "/" ^ (uri_encode p)

let map f = function
  | Some x -> Some (f x)
  | None   -> None

let bind f default = function
  | Some x -> f x
  | None   -> default


let add_p p str = match p with
  | Some p -> append str p
  | None   -> str

let add_p_list opt_lp str = match opt_lp with
  | Some lp -> (List.fold_left (fun str p -> append str p) str lp)
  | None    -> str


let json_of_uri uri = `String (string_of_uri uri)
let json_of_uris uris = `List (List.map json_of_uri uris)
let json_of_link_id id = `String (string_of_link_id id)
let json_of_link_ids ids = `List (List.map json_of_link_id ids)
let json_of_string str = `String str
let json_of_strings strs = `List (List.map json_of_string strs)

let add_j name f p list = bind (fun x -> (name, f x)::list) list p


let exc_wrapper func =
  try func ()
  with e -> raise (Pumgrana ("Pumgrana: " ^ (Printexc.to_string e)))


let base_headers () =
  Cohttp.Header.init_with "accept" "application/json"

let get uri parameters =
  let headers = base_headers () in
  let uri = !pumgrana_api_uri ^ uri ^ parameters in
  let uri = Uri.of_string uri in
  lwt header, body =
    try Cohttp_lwt_unix.Client.get ~headers uri
    with e -> (print_endline (Printexc.to_string e); raise e)
  in
  lwt body_string = Cohttp_lwt_body.to_string body in
  Lwt.return (Yojson.from_string body_string)

let post_headers content_length =
  let headers = base_headers () in
  let headers' = Cohttp.Header.add headers "content-type" "application/json" in
  Cohttp.Header.add headers' "content-length" (string_of_int content_length)

let post uri json =
  let data = Yojson.to_string json in
  let headers = post_headers (String.length data) in
  let uri = Uri.of_string (!pumgrana_api_uri ^ uri) in
  let body = ((Cohttp.Body.of_string data) :> Cohttp_lwt_body.t) in
  lwt h, body =
    try Cohttp_lwt_unix.Client.post ~body ~chunked:false ~headers uri
    with e -> (print_endline (Printexc.to_string e); raise e)
  in
  lwt body_string = Cohttp_lwt_body.to_string body in
  Lwt.return (Yojson.from_string body_string)


(******************************************************************************
********************************* Content *************************************
*******************************************************************************)

let get_content_detail content_uri =
  let aux () =
    let parameter = uri_encode (string_of_uri content_uri) in
    lwt json = get content_detail_uri parameter in
    Lwt.return (List.hd Pdeserialize.(get_service_return get_content_list json))
  in
  exc_wrapper aux


let get_contents ?filter ?tags_uri () =
  let aux () =
    let str_filter = map string_of_filter filter in
    let str_tags_uri = map (List.map string_of_uri) tags_uri in
    let parameters = (add_p_list str_tags_uri (add_p str_filter "")) ^ "/" in
    lwt json = get contents_uri parameters in
    Lwt.return (Pdeserialize.(get_service_return get_short_content_list json))
  in
  exc_wrapper aux

let insert_content title summary body ?tags_uri () =
  let aux () =
    let json = `Assoc (add_j "tags_uri" json_of_uris tags_uri
                         [("title", `String title);
                          ("summary", `String summary);
                          ("body", `String body)])
    in
    lwt json = post content_insert_uri json in
    Lwt.return (Pdeserialize.get_content_uri_return json)
  in
  exc_wrapper aux

let update_content uri ?title ?summary ?body ?tags_uri () =
  let aux () =
    let json =
      `Assoc (add_j "tags_uri" json_of_uris tags_uri
                (add_j "body" json_of_string body
                   (add_j "summary" json_of_string summary
                      (add_j "title" json_of_string title
                         ["content_uri", json_of_uri uri]))))
    in
    lwt _ = post content_update_uri json in
    Lwt.return ()
  in
  exc_wrapper aux

let update_content_tags uri tags_uri =
  let aux () =
    let json =
      `Assoc [("tags_uri", json_of_uris tags_uri);
              ("content_uri", json_of_uri uri)]
    in
    lwt _ = post content_update_tags_uri json in
    Lwt.return ()
  in
  exc_wrapper aux

let delete_contents uris =
  let aux () =
    let json = `Assoc [("contents_uri", json_of_uris uris)] in
    lwt _ = post content_delete_uri json in
    Lwt.return ()
  in
  exc_wrapper aux

(******************************************************************************
*********************************** Tag ***************************************
*******************************************************************************)

let tags_by_type type_name =
  let aux () =
    let parameter = string_of_type_name type_name in
    lwt json = get tag_type_uri parameter in
    Lwt.return (Pdeserialize.(get_service_return get_tag_list json))
  in
  exc_wrapper aux

let tags_from_content content_uri =
  let aux () =
    let parameter = uri_encode (string_of_uri content_uri) in
    lwt json = get tag_content_uri parameter in
    Lwt.return (Pdeserialize.(get_service_return get_tag_list json))
  in
  exc_wrapper aux

let tags_from_content_links content_uri =
  let aux () =
    let parameter = uri_encode (string_of_uri content_uri) in
    lwt json = get tag_content_links_uri parameter in
    Lwt.return (Pdeserialize.(get_service_return get_tag_list json))
  in
  exc_wrapper aux

let insert_tags type_name ?uri tags_subject =
  let aux () =
    let json = `Assoc (add_j "uri" json_of_uri uri
                         [("type_name", `String (string_of_type_name type_name));
                          ("tags_subject", (json_of_strings tags_subject))])
    in
    lwt json = post tag_insert_uri json in
    Lwt.return (Pdeserialize.get_tags_uri_return json)
  in
  exc_wrapper aux

let delete_tags tags_uri =
  let aux () =
    let json = `Assoc [("tags_uri", json_of_uris tags_uri)] in
    lwt _ = post tag_delete_uri json in
    Lwt.return ()
  in
  exc_wrapper aux

(******************************************************************************
*********************************** Link **************************************
*******************************************************************************)

let get_link_detail link_id =
  let aux () =
    let parameter = string_of_link_id link_id in
    lwt json = get link_detail_uri parameter in
    Lwt.return (List.hd Pdeserialize.(get_service_return get_detail_link_list json))
  in
  exc_wrapper aux

let links_from_content content_uri =
  let aux () =
    let parameter = uri_encode (string_of_uri content_uri) in
    lwt json = get link_content_uri parameter in
    Lwt.return (Pdeserialize.(get_service_return get_link_list json))
  in
  exc_wrapper aux

let links_from_content_tags content_uri tags_uri =
  let aux () =
    let content_str_uri = string_of_uri content_uri in
    let str_tags_uri = List.map string_of_uri tags_uri in
    let parameters =
      (List.fold_left append (append "" content_str_uri) str_tags_uri ) ^ "/"
    in
    lwt json = get link_content_tags_uri parameters in
    Lwt.return (Pdeserialize.(get_service_return get_link_list json))
  in
  exc_wrapper aux

let insert_links links =
  let aux () =
    let json_of_links (origin_uri, target_uri, tags_uri) =
      `Assoc [("origin_uri", json_of_uri origin_uri);
              ("target_uri", json_of_uri target_uri);
              ("tags_uri", json_of_uris tags_uri)]
    in
    let json = `List (List.map json_of_links links) in
    let json = `Assoc [("data", json)] in
    lwt json = post link_insert_uri json in
    Lwt.return (Pdeserialize.get_links_uri_return json)
  in
  exc_wrapper aux

let update_links links =
  let aux () =
    let json_of_links (link_uri, tags_uri) =
      `Assoc [("link_uri", json_of_link_id link_uri);
              ("tags_uri", json_of_uris tags_uri)]
    in
    let json = `Assoc [("data", `List (List.map json_of_links links))] in
    lwt json = post link_update_uri json in
    Lwt.return ()
  in
  exc_wrapper aux

let delete_links uris =
  let aux () =
    let json = `Assoc [("links_uri", json_of_link_ids uris)] in
    lwt json = post link_delete_uri json in
    Lwt.return ()
  in
  exc_wrapper aux
