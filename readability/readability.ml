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
  let headers = Cohttp.Header.init_with "accept" "application/json" in
  let str_iuri = Rdf_uri.string iuri in
  let str_uri = readbility_uri ^ "?url=" ^ str_iuri ^ "&token=" ^ !token in
  let uri = Uri.of_string str_uri in
  lwt header, body = Cohttp_lwt_unix.Client.get ~headers uri in
  lwt body_string = Cohttp_lwt_body.to_string body in
  Lwt.return (Yojson.from_string body_string)
