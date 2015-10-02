(**
   Boilerpipe
   A ocaml boilerpipe binding
*)

exception Failed of int
exception Killed of int
exception Stopped of int

type mode = Article | Default

let jar_path = ref "jar/simpleboilerpipe.jar"

let set_jar_path = (:=) jar_path

let string_of_mode = function
  | Article -> "article"
  | Default -> "default"

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

let boilerpipe mode uri =
  let str_uri = Uri.to_string uri in
  let str_mode = string_of_mode mode in
  let command = ("java", [| "java"; "-jar"; !jar_path; str_mode; str_uri |]) in
  let process = Lwt_process.open_process_in command in
  lwt output = read [] process#stdout in
  lwt status = process#close in
  let () = is_valid status in
  Lwt.return output

(* let main () = *)
(*   let uri = Uri.of_string "http://www.bbc.com/sport/0/rugby-union/34385603" in *)
(*   lwt res = boilerpipe Article uri in *)
(*   Lwt.return (List.iter print_endline res) *)

(* lwt () = main () *)
