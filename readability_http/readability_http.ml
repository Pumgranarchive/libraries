(**
   Readability
   A ocaml readability binding
*)

module Yojson = Yojson.Basic

(******************************************************************************
****************************** Configuration **********************************
*******************************************************************************)

let readbility_uri = "https://www.readability.com/api/content/v1/parser"
let token = ref ""

(******************************************************************************
********************************** Tools **************************************
*******************************************************************************)

let set_token str =
  token := str

(******************************************************************************
********************************* Binding *************************************
*******************************************************************************)

let get_parser iuri =
  let str_iuri = Rdf_uri.string iuri in
  (* Printf.printf "Readability: enter: %s" str_iuri; *)
  (* print_endline ""; *)
  let headers = Cohttp.Header.init_with "accept" "application/json" in
  let str_uri = readbility_uri ^ "?url=" ^ str_iuri ^ "&token=" ^ !token in
  let uri = Uri.of_string str_uri in
  (* Printf.printf "Readability: request: %s" str_iuri; *)
  (* print_endline ""; *)
  lwt header, body =
      try_lwt Cohttp_lwt_unix.Client.get ~headers uri
      with e -> (Printf.printf "\nrequest failed %s\n" str_iuri; raise e)
  in
  (* Printf.printf "Readability: body: %s" str_iuri; *)
  (* print_endline ""; *)
  lwt body_string = Cohttp_lwt_body.to_string body in
  (* Printf.printf "Readability: json: %s" str_iuri; *)
  (* print_endline ""; *)
  let json =
    try Yojson.from_string body_string
    with e -> (Printf.printf "\njson failed %s\n" str_iuri; raise e)
  in
  (* Printf.printf "Readability: out: %s" str_iuri; *)
  (* print_endline ""; *)
  Lwt.return (json)
