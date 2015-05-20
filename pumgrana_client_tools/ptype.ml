exception Invalid_uri of string
exception Invalid_link_id of string

type uri = string

(******************************************************************************
********************************** Tools **************************************
*******************************************************************************)

let search_forward ~start str1 str2 start_pos =
  let end1 = String.length str1 in
  let end2 = String.length str2 in
  let rec aux pos1 pos2 =
    if pos1 >= end1 then pos2
    else if pos2 >= end2 then raise Not_found else
      let c1 = String.get str1 pos1 in
      let c2 = String.get str2 pos2 in
      if Char.compare c1 c2 == 0 then aux (pos1 + 1) (pos2 + 1)
      else if start then raise Not_found
      else aux 0 (pos2 + 1)
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
      Not_found -> str::list
  in
  List.rev (aux [] str)

let insert str p_start p_end str2 =
  let str1 = String.sub str 0 p_start in
  let str3 = String.sub str p_end ((String.length str) - p_end) in
  str1 ^ str2 ^ str3

let replace remove_list replace_list str =
  let aux str remove_str replace_str =
    let remove_length = String.length remove_str in
    let rec search_and_replace str start =
      try
        let p = search_forward ~start:false remove_str str start in
        let new_p = p - remove_length in
        let new_url = insert str new_p p replace_str in
         search_and_replace new_url new_p
      with
        Not_found -> str
    in
    search_and_replace str 0
  in
  List.fold_left2 aux str remove_list replace_list

let char_list =    ["/";  ":";  "?";  "=";  "&";  "#";  ";";  " ";  "<";  ">"]
let encoded_char = ["%2F";"%3A";"%3F";"%3D";"%26";"%23";"%3B";"%20";"%3C";"%3E"]

let uri_encode url =
  replace char_list encoded_char url

let uri_decode url =
  replace encoded_char char_list url

(******************************************************************************
*********************************** Type **************************************
*******************************************************************************)

let compare_uri = String.compare

let uri_of_string str =
  let _ =
    try search_forward ~start:true "http://" str 0
    with Not_found ->
      try search_forward ~start:true "https://" str 0
      with Not_found -> raise (Invalid_uri str)
  in
  str

let string_of_uri uri = uri
