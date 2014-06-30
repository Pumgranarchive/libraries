exception Invalid_uri = Rdf_uri.Invalid_uri
exception Invalid_link_id of string

type uri = Rdf_uri.uri
type link_id = uri * uri
type filter = Most_recent | Most_used | Most_view
type type_name = Link | Content

let uri_of_string uri =
  let _ =
    try
      let regexp = Str.regexp "^http://" in
      Str.search_forward regexp uri 0
    with Not_found -> raise (Invalid_uri uri)
  in
  Rdf_uri.uri uri

let string_of_uri = Rdf_uri.string

let string_of_link_id (origin_uri, target_uri) =
  (string_of_uri origin_uri) ^ "@" ^ (string_of_uri target_uri)

let link_id_of_string link_id =
  let regexp = Str.regexp "@" in
  try
    let strings = Str.split regexp link_id in
    if List.length strings > 2 then raise (Invalid_argument "Too many @");
    let origin_str_uri = List.hd strings in
    let target_str_uri = List.hd (List.tl strings) in
    let origin_uri = uri_of_string origin_str_uri in
    let target_uri = uri_of_string target_str_uri in
    origin_uri, target_uri
  with e ->
    raise (Invalid_link_id (link_id ^ ": is not a valid link_id"))
