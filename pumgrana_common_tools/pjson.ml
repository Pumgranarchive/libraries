module Yojson = Yojson.Basic

open Yojson.Util

let opt_member name json =
  match member name json with
  | `Null -> None
  | res   -> Some res

let not_null default value =
  match value with
  | `Null -> default
  | v     -> v

let to_list = function
  | `Null   -> []
  | `List l -> l
  | r       -> raise (Type_error ("`List or `Null expected", r))

let map func = function
  | Some x      -> Some (func x)
  | None        -> None
