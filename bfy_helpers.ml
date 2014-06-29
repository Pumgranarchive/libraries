
(*
** A couple of helpers used by the bindings of youtube and freebase
*)

let rec strings_of_list list separator =
  List.fold_right (fun l r -> l ^ separator ^ r) list ""


let reduce_string string length =
  if String.length string > length
  then (String.sub string 0 length) ^ "..."
  else string
