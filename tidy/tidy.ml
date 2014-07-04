(* Initialize the random *)
let _ = Random.self_init ()

let rd_name () =
  let rec aux name length =
    if length = 0 then name
    else aux (name ^ (string_of_int (Random.int 10))) (length - 1)
  in
  (aux "" 10) ^ ".tmp"

let clean_xhtml xhtml =
  (* Clean up a little *)
  let regexp = Str.regexp "[\n \t]+" in
  let xhtml = Str.global_replace regexp " " xhtml in
  let regexp = Str.regexp "&nbsp;" in
  let xhtml = Str.global_replace regexp " " xhtml in
  (* Remove not excepting addition *)
  let beginning = Str.regexp "^.*<body> ?" in
  let xhtml = Str.global_replace beginning "" xhtml in
  let ending = Str.regexp " ?</body>.*$" in
  Str.global_replace ending "" xhtml

let xhtml_of_html string =
  let file = rd_name () in
  lwt oc = Lwt_io.open_file
      ~flags:[Unix.O_CREAT;Unix.O_WRONLY]
      ~mode:Lwt_io.Output
      file
  in
  lwt () = Lwt_io.write oc string in
  lwt () = Lwt_io.close oc in
  let _ = Sys.command ("tidy -asxhtml -m "^file^" > /dev/null 2>&1") in
  lwt ic = Lwt_io.open_file
      ~flags:[Unix.O_CREAT;Unix.O_RDONLY]
      ~mode:Lwt_io.Input
      file
  in
  lwt result = Lwt_io.read ic in
  lwt () = Lwt_io.close ic in
  Sys.remove file;
  Lwt.return (clean_xhtml result)
