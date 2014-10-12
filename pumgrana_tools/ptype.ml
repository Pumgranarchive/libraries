exception Invalid_uri = Rdf_uri.Invalid_uri
exception Invalid_link_id of string

type uri = Rdf_uri.uri
type link_id = uri * uri
type filter = Most_recent | Most_used | Most_view
type type_name = Link | Content

let compare_uri = Rdf_uri.compare

let uri_of_string uri =
  let _ =
    try
      let regexp = Str.regexp "^https?://" in
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

let replace remove_list replace_list str =
  let aux str remove_str replace_str =
    let regexp = Str.regexp remove_str in
    Str.global_replace regexp replace_str str
  in
  List.fold_left2 aux str remove_list replace_list

let char_list =    ["/";  ":";  "?";  "=";  "&";  "#";  ";";  " "]
let encoded_char = ["%2F";"%3A";"%3F";"%3D";"%26";"%23";"%3B";"%20"]

let uri_encode url =
  replace char_list encoded_char url

let uri_decode url =
  replace encoded_char char_list url

let pumgrana_id_of_uri base uri =
  let str = string_of_uri uri in
  let regexp1 = Str.regexp ("^" ^ base) in
  let regexp2 = Str.regexp base in
  let pos =
    try (Str.search_forward regexp1 str 0) + (String.length base)
    with Not_found -> raise (Invalid_uri (str ^ ": is not a Pumgrana URI."))
  in
  let _ =
    try
      let _ = Str.search_forward regexp2 str pos in
      raise (Invalid_uri (str ^ ": looks to be an invalid URI."))
    with Not_found -> ()
  in
  String.sub str pos ((String.length str) - pos)

let link_id origin_uri target_uri = origin_uri, target_uri

let tuple_of_link_id link_id = link_id
