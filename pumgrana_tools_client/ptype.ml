exception Invalid_uri of string
exception Invalid_link_id of string

type uri = string
type link_id = uri * uri
type filter = Most_recent | Most_used | Most_view
type type_name = Link | Content

let search_forward ~start str1 str2 start_pos =
  let end1 = String.length str1 in
  let end2 = String.length str2 in
  let rec aux pos1 pos2 =
    if pos1 == end1 then pos2
    else if pos2 < end2 then
      let c1 = String.get str1 pos1 in
      let c2 = String.get str2 pos2 in
      if Char.compare c1 c2 == 0
      then aux (pos1 + 1) (pos2 + 1)
      else if start
      then raise Not_found
      else aux 0 (pos2 + 1)
    else raise Not_found
  in
  aux 0 start_pos

let split sep str =
  let sep_length = String.length sep in
  let rec aux list str =
    try
      let p = search_forward ~start:false sep str 0 in
      let sub = String.sub str 0 (p - sep_length) in
      let str2 = String.sub str p ((String.length str) - p) in
      aux (sub::list) str2
    with
      Not_found -> list
  in
  List.rev (aux [] str)

let uri_of_string str =
  let _ =
    try search_forward ~start:true "http://" str 0
    with Not_found -> raise (Invalid_uri str)
  in
  str

let string_of_uri uri = uri

let string_of_link_id (origin_uri, target_uri) =
  (string_of_uri origin_uri) ^ "@" ^ (string_of_uri target_uri)

let link_id_of_string link_id =
  try
    let strings = split "@" link_id in
    if List.length strings > 2 then raise (Invalid_argument "Too many @");
    let origin_str_uri = List.hd strings in
    let target_str_uri = List.hd (List.tl strings) in
    let origin_uri = uri_of_string origin_str_uri in
    let target_uri = uri_of_string target_str_uri in
    origin_uri, target_uri
  with e ->
    raise (Invalid_link_id (link_id ^ ": is not a valid link_id"))
