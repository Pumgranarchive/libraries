exception Invalid_uri = Rdf_uri.Invalid_uri
exception Invalid_link_id of string

type uri = Rdf_uri.uri

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

let replace remove_list replace_list str =
  let aux str remove_str replace_str =
    let regexp = Str.regexp remove_str in
    Str.global_replace regexp replace_str str
  in
  List.fold_left2 aux str remove_list replace_list

let char_list =    ["/";  ":";  "?";  "=";  "&";  "#";  ";";  " ";  "<";  ">"]
let encoded_char = ["%2F";"%3A";"%3F";"%3D";"%26";"%23";"%3B";"%20";"%3C";"%3E"]

let uri_encode url =
  replace char_list encoded_char url

let uri_decode url =
  replace encoded_char char_list url
