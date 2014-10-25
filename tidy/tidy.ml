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

type 'a mode =
| Output of 'a Lwt_io.mode
| Input of 'a Lwt_io.mode

let output = Output Lwt_io.output
let input = Input Lwt_io.input

let my_open o_mode fname =
  let mode, rw_flag = match o_mode with
    | Output m -> m, Unix.O_WRONLY
    | Input m -> m, Unix.O_RDONLY
  in
  Lwt_io.open_file ~flags:[Unix.O_CREAT;rw_flag] ~mode fname

let init fname html =
  lwt oc = my_open output fname in
  lwt () = Lwt_io.write oc html in
  Lwt_io.close oc

let exec fname =
  let _ = Sys.command ("tidy -asxhtml -m "^fname^" > /dev/null 2>&1") in
  lwt ic = my_open input fname in
  lwt result = Lwt_io.read ic in
  lwt () = Lwt_io.close ic in
  Lwt.return result

let xhtml_of_html html =
  let fname = rd_name () in
  lwt () = init fname html in
  lwt result =
    try_lwt exec fname
    with e -> (Sys.remove fname; raise e)
  in
  Sys.remove fname;
  Lwt.return (clean_xhtml result)
