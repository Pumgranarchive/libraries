module Yojson = Yojson.Basic

open Yojson.Util
open Pjson

exception Bad_format of string

(** Get service return data *)
let get_service_return func json =
  let data =
    try
      let assoc_list = to_assoc json in
      let idx_last_element = (List.length assoc_list) - 1 in
      let name, data = List.nth assoc_list idx_last_element in
      data
    with
    | e -> print_endline (Printexc.to_string e);
      raise (Bad_format "Bad service return format")
  in
  func data

(** Get id into content_id return  *)
let get_content_uri_return json =
  try
    let json_content_uri = member "content_uri" json in
    Ptype.uri_of_string (to_string (List.hd (to_list json_content_uri)))
  with
  | e -> print_endline (Printexc.to_string e);
    raise (Bad_format "Bad content_uri format")

(** deserialize content from yojson to ocaml format *)
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
  with
  | e -> print_endline (Printexc.to_string e);
    raise (Bad_format  "Bad content format")

(** deserialize short content from yojson to ocaml format *)
let get_short_content json_content =
  try
    let uri = member "uri" json_content in
    let title = member "title" json_content in
    let summary = member "summary" json_content in
    Ptype.uri_of_string (to_string uri),
    to_string title, to_string summary
  with
  | e -> print_endline (Printexc.to_string e);
    raise (Bad_format  "Bad short content format")

(** deserialize link from yojson to ocaml format *)
let get_link json_link =
  try
    let link_id = member "link_uri" json_link in
    let content_uri = member "content_uri" json_link in
    let content_title = member "content_title" json_link in
    let content_summary = member "content_summary" json_link in
    Ptype.link_id_of_string (to_string link_id),
    Ptype.uri_of_string (to_string content_uri),
    to_string content_title, to_string content_summary
  with
  | e -> print_endline (Printexc.to_string e);
    raise (Bad_format  "Bad link format")

(** deserialize tags_uri from yojson to ocaml format *)
let get_tags_uri_return json_tag =
  try
    let uris = to_list (member "tags_uri" json_tag) in
    List.map (fun x -> Ptype.uri_of_string (to_string (member "uri" x))) uris
  with
  | e -> print_endline (Printexc.to_string e);
    raise (Bad_format  "Bad tags_uri format")

(** deserialize tag from yojson to ocaml format *)
let get_tag json_tag =
  try
    let uri = to_string (member "uri" json_tag) in
    let subject = to_string (member "subject" json_tag) in
    Ptype.uri_of_string uri, subject
  with
  | e -> print_endline (Printexc.to_string e);
    raise (Bad_format  "Bad tag format")

(** deserialize links_uri from yojson to ocaml format *)
let get_links_uri_return json_tag =
  try
    let uris = to_list (member "links_uri" json_tag) in
    List.map (fun x -> Ptype.uri_of_string (to_string (member "uri" x))) uris
  with
  | e -> print_endline (Printexc.to_string e);
    raise (Bad_format  "Bad links_uri format")

(** deserialize json link detail to ocaml  *)
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
  with
  | e -> print_endline (Printexc.to_string e);
    raise (Bad_format  "Bad link detail format")

(** deserialize tag list from yojson to ocaml *)
let get_tag_list tl =
  List.map get_tag (to_list tl)

(** deserialize content list from yojson to ocaml *)
let get_content_list tl =
  List.map get_content (to_list tl)

(** deserialize short content list from yojson to ocaml *)
let get_short_content_list tl =
  List.map get_short_content (to_list tl)

(** deserialize link list from yojson to ocaml *)
let get_link_list tl =
  List.map get_link (to_list tl)

(** deserialize detail link list from yojson to ocaml *)
let get_detail_link_list tl =
  List.map get_link_detail (to_list tl)
