
(*
** A couple of helpers used by the bindings of youtube and freebase
*)

let rec strings_of_list list separator =
  let tmp = List.fold_left (fun l r -> l ^ separator ^ r) "" list in
  let sep_len = String.length separator
  in
  String.sub tmp sep_len ((String.length tmp) - sep_len)

let reduce_string string length =
  if String.length string > length
  then (String.sub string 0 length) ^ "..."
  else string
