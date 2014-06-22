(*
** Binding http of freebase with ocaml
*)

(*
** PRIVATE
*)

(*** freebase url ***)
let freebase_url = "https://www.googleapis.com/freebase/v1/"
let freebase_url_search = freebase_url ^ "search?query="


(*** json accessor ***)
let get_result_field json =
  Yojson.Basic.Util.(to_list (member "result" json))

let get_mid_field json =
  Yojson.Basic.Util.(to_string (member "mid" json))

(*
** PUBLIC
*)

let create_freebase_search_url request = freebase_url_search ^ request

let print_freebase_json json =
  let rec print_mid = function
    | (h::t)      -> (print_endline (get_mid_field h)); print_mid t
    | _           -> ()
  in
  print_mid (get_result_field json)
