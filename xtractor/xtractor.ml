(**
   Xtractor
   A ocaml xtractor binding
*)

module Yojson = Yojson.Basic

exception Failed of int
exception Killed of int
exception Stopped of int

type document = { title: string; content: string; body: string; summary: string;
                  image: string; video: string }

let jar_path = ref "/home/nox/.opam/4.00.1/lib/xtractor/simplextractor.jar"

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
    content = to_string (member "content" json);
    body = to_string (member "body" json);
    summary = to_string (member "summary" json);
    image = to_string (member "image" json);
    video = to_string (member "video" json) }

let xtractor uri =
  let str_uri = Uri.to_string uri in
  let command = ("java", [| "java"; "-jar"; !jar_path; str_uri |]) in
  let process = Lwt_process.open_process_in command in
  lwt output = read [] process#stdout in
  lwt status = process#close in
  let () = is_valid status in
  Lwt.return (format output)

let print doc =
  print_endline ("title:   \t" ^ doc.title);
  print_endline ("content:   \t" ^ doc.content);
  print_endline ("body:   \t" ^ doc.body);
  print_endline ("summary:   \t" ^ doc.summary);
  print_endline ("image:   \t" ^ doc.image);
  print_endline ("video:   \t" ^ doc.video)

let main () =
  let uri = Uri.of_string "http://www.bbc.com/sport/0/rugby-union/34385603" in
  lwt res = xtractor uri in
  Lwt.return (print res)

(* lwt () = main () *)
