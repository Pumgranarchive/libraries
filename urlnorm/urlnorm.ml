exception Failed of int
exception Killed of int
exception Stopped of int

let rec read init channel =
  try read ( (input_line channel) :: init ) channel
  with End_of_file -> List.rev init

let is_valid = function
  | Unix.WSIGNALED s -> raise (Killed s)
  | Unix.WSTOPPED s -> raise (Stopped s)
  | Unix.WEXITED s -> if s == 0 then () else raise (Failed s)

let python ?(imports=[]) cmds =
  let cmd_imports = List.map (fun i -> "import "^ i) imports in
  let encoding = "#coding=utf-8" in
  let oneline = encoding ^ "\\n" ^ String.concat ";" (cmd_imports @ cmds) ^ ";" in
  let wrap_cmd = "echo \""^ oneline ^"\" | python" in
  print_endline wrap_cmd;
  let cin = Unix.open_process_in wrap_cmd in
  let output = read [] cin in
  let status = Unix.close_process_in cin in
  begin is_valid status; output end

let urlnorm urls =
  let imports = ["urlnorm"] in
  let make_cmd url = "print(urlnorm.norm(u'"^ url ^"').encode('utf-8'))" in
  let cmds = List.map make_cmd urls in
  python ~imports cmds

let substitute_array = [
  (Str.regexp "^https://",      "http://");
  (Str.regexp "#.+$",           "");
  (Str.regexp "://www.",        "://")
]

let rec replaces str = function
  | (r, s)::next -> replaces (Str.replace_first r s str) next
  | [] -> str

let sep = Str.regexp "\\(\\?\\|&\\)"
let setter = Str.regexp "="

let search_or_length regexp str start =
  try Str.search_forward regexp str start
  with Not_found -> String.length str

let rec parse_query query url =
  try
    let start = Str.search_forward sep url 0 + 1 in
    let equal = Str.search_forward setter url start + 1 in
    let end_q = search_or_length sep url equal in
    let name = String.sub url start (equal - start - 1) in
    let value = String.sub url equal (end_q - equal) in
    let next = String.sub url end_q (String.length url - end_q) in
    parse_query ((name, value)::query) next
  with Not_found -> (query, url)

let sort_query url =
  let query, _ = parse_query [] url in
  Sort.list (fun (n1, _) (n2, _) -> String.compare n1 n2 < 0) query

let limit_2params query =
  if List.length query <= 2 then query
  else [List.nth query 0; List.nth query 1]

let rewrite_query url query =
  let rec rewrite url sep = function
    | [] -> url
    | (n, v)::next -> rewrite (url ^ sep ^ n ^"="^ v) "&" next
  in
  let start = search_or_length sep url 0 in
  let base = String.sub url 0 start in
  rewrite base "?" query

let internal_normalize durty_url =
  let url = replaces durty_url substitute_array in
  rewrite_query url (limit_2params (sort_query url))

let normalize durty_urls =
  let urls = urlnorm durty_urls in
  List.map internal_normalize urls

(* let main () = *)
(*   let durty_urls = [ *)
(*     "Http://exAMPLE.com./foo"; *)
(*     "Http://exAMPLE.com./foo//d"; *)
(*     "Https://exAMPLE.com./foo"; *)
(*     "Https://exAMPLE.com./foo/../bar"; *)
(*     "Http://exAMPLE.com./foo#test"; *)
(*     "Http://exAMPLE.com./foo?c=1&d=2&a=1#test"; *)
(*     "http://en.wikipedia.org/wiki/Astra_19.2%C2%B0E"; *)
(*     "https://en.wikipedia.org/wiki/Astra_19.2°E" *)
(*   ] *)
(*   in *)
(*   let urls = normalize durty_urls in *)
(*   print_endline "\nResults"; *)
(*   List.iter print_endline urls *)

(* let () = main () *)
