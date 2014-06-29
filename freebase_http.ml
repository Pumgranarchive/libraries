(*
** Binding http of freebase with ocaml
*)

(*
** PRIVATE
*)

(*** freebase url ***)
let api_base_url = "https://www.googleapis.com/freebase/v1/"
let api_search_url = api_base_url ^ "search?query="
let api_topic_url = api_base_url ^ "topic/"


(*** url creators ***)
let create_freebase_search_url request = api_search_url ^ request

(*** json accessor ***)
let get_result_field json =
  Yojson.Basic.Util.(to_list (member "result" json))

let get_mid_field json =
  Yojson.Basic.Util.(to_string (member "mid" json))

(*
** PUBLIC
*)

let search query =
  let url = create_freebase_search_url query in
  lwt freebase_json = Http_request_manager.request url
  in
  Lwt.return (freebase_json)

let print_json json =
  let rec print_mid = function
    | (h::t)      -> (print_endline (get_mid_field h)); print_mid t
    | _           -> ()
  in
  print_mid (get_result_field json)
