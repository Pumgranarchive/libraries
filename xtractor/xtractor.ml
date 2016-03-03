(**
   Xtractor
   A ocaml xtractor binding
*)

module Yojson = Yojson.Basic

exception Failed of int
exception Killed of int
exception Stopped of int

type document = { title: string; body: string; summary: string }

let jar_path = ref "%%JAR_PATH%%"

let set_jar_path = (:=) jar_path

let rec read lines channel =
  try_lwt
    lwt line = Lwt_io.read_line channel in
    read (line :: lines) channel
  with End_of_file ->
    Lwt.return (List.rev lines)

let is_valid = function
  | Unix.WSIGNALED s -> raise (Killed s)
  | Unix.WSTOPPED s -> raise (Stopped s)
  | Unix.WEXITED s -> if s == 0 then () else raise (Failed s)

let format lines =
  let open Yojson.Util in
  let output = String.concat "" lines in
  let json = Yojson.from_string output in
  { title = to_string (member "title" json);
    body = to_string (member "body" json);
    summary = to_string (member "summary" json) }

let xtractor uri content =
  let str_uri = Uri.to_string uri in
  let contentLength = string_of_int (String.length content) in
  let command = ("java", [| "java"; "-jar"; !jar_path; str_uri; contentLength |]) in
  let process = Lwt_process.open_process command in
  lwt () = Lwt_io.write_line process#stdin content in
  lwt output = read [] process#stdout in
  lwt status = process#close in
  let () = is_valid status in
  Lwt.return (format output)

let print doc =
  print_endline ("title:   \t" ^ doc.title);
  print_endline ("body:   \t" ^ doc.body);
  print_endline ("summary:   \t" ^ doc.summary)

let basical_test () =
  let uri = Uri.of_string "http://www.random.com" in
  let html = "<html><body><div>Hello World</div></body></html>" in
  lwt res = xtractor uri html in
  Lwt.return (print res)

(* lwt () = basical_test () *)
