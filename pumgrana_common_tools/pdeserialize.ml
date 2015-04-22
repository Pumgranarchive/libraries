module Yojson = Yojson.Basic

open Yojson
open Yojson.Util
open Pjson

exception Not_found
exception Unknown_error of string
exception Internal_server_error of string
exception Bad_format of string

(******************************************************************************
********************************** Utils **************************************
*******************************************************************************)

let actions =
  [404,         (fun _ -> raise Not_found);
   500,         (fun err -> raise (Internal_server_error err))]

let string_of_unknown status err =
  (string_of_int status) ^ ": " ^ err

let output_line oc line =
  let line = line ^ "\n" in
  output oc line 0 (String.length line)

let options = [Open_wronly; Open_creat; Open_append; Open_text]
let right = 0o666

let log filename subject exc description =
  let now = Ptools.datetime () in
  let title = now ^ " #ERROR on " ^ subject in
  let oc = open_out_gen options right filename in
  output_line oc ("\n" ^ title);
  output_line oc (Printexc.to_string exc);
  if (String.length description > 0) then output_line oc description;
  output_line oc "";
  close_out oc;
  title

let manage_bad_format str_err exc json =
  let title = log "pdeserialize.error" str_err exc (pretty_to_string json) in
  raise (Bad_format title)

(******************************************************************************
******************************** Funtions *************************************
*******************************************************************************)

let get_service_return func json =
  let rec scan_status status err = function
    | [] ->
      if status >= 300
      then raise (Unknown_error (string_of_unknown status err))
    | (v, action)::t ->
      if status = v
      then action err
      else scan_status status err t
  in
  let name, data =
    try
      let status = to_int (member "status" json) in
      let error = to_string (not_null (`String "") (member "error" json)) in
      let () = scan_status status error actions in
      let assoc_list = to_assoc json in
      let idx_last_element = (List.length assoc_list) - 1 in
      List.nth assoc_list idx_last_element
    with e -> manage_bad_format "Bad service return format" e json
  in
  func data

let get_content_uri_return json =
  try
    let json_content_uri = member "content_uri" json in
    Ptype.uri_of_string (to_string (List.hd (to_list json_content_uri)))
  with e -> manage_bad_format "Bad content_uri format" e json

let get_content json_content =
  try
    let uri = member "uri" json_content in
    let title = member "title" json_content in
    let summary = member "summary" json_content in
    let body = member "body" json_content in
    let v_external = member "external" json_content in
    Ptype.uri_of_string (to_string uri),
    to_string title, to_string summary, to_string body,
    to_bool v_external
  with e -> manage_bad_format "Bad content format" e json_content

let get_short_content json_content =
  try
    let uri = member "uri" json_content in
    let title = member "title" json_content in
    let summary = member "summary" json_content in
    Ptype.uri_of_string (to_string uri),
    to_string title, to_string summary
  with e -> manage_bad_format "Bad short content format" e json_content

let get_link json_link =
  try
    let link_id = member "link_uri" json_link in
    let content_uri = member "content_uri" json_link in
    let content_title = member "content_title" json_link in
    let content_summary = member "content_summary" json_link in
    Ptype.link_id_of_string (to_string link_id),
    Ptype.uri_of_string (to_string content_uri),
    to_string content_title, to_string content_summary
  with e -> manage_bad_format "Bad link format" e json_link

let get_tags_uri_return json_tag =
  try
    let uris = to_list (member "tags_uri" json_tag) in
    List.map (fun x -> Ptype.uri_of_string (to_string (member "uri" x))) uris
  with e -> manage_bad_format "Bad tags_uri format" e json_tag

let get_tag json_tag =
  try
    let uri = to_string (member "uri" json_tag) in
    let subject = to_string (member "subject" json_tag) in
    Ptype.uri_of_string uri, subject
  with e -> manage_bad_format "Bad tag format" e json_tag

let get_links_uri_return json_tag =
  try
    let uris = to_list (member "links_uri" json_tag) in
    List.map (fun x -> Ptype.link_id_of_string (to_string (member "uri" x))) uris
  with e -> manage_bad_format "Bad links_uri format" e json_tag

let get_link_detail json_detail =
  try
    let link_id = to_string (member "link_uri" json_detail) in
    let origin_uri = to_string (member "origin_uri" json_detail) in
    let target_uri = to_string (member "target_uri" json_detail) in
    let tags = to_list (member "tags" json_detail) in
    Ptype.link_id_of_string link_id,
    Ptype.uri_of_string origin_uri,
    Ptype.uri_of_string target_uri,
    List.map get_tag tags
  with e -> manage_bad_format "Bad link detail format" e json_detail

let get_tag_list tl =
  List.map get_tag (to_list tl)

let get_content_list tl =
  List.map get_content (to_list tl)

let get_short_content_list tl =
  List.map get_short_content (to_list tl)

let get_link_list tl =
  List.map get_link (to_list tl)

let get_detail_link_list tl =
  List.map get_link_detail (to_list tl)
