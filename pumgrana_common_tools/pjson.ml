module Yojson = Yojson.Basic

open Yojson.Util

(** return the Some member associate of name, and None if not found *)
let opt_member name json =
  match member name json with
  | `Null -> None
  | res   -> Some res

(** Extract a list from JSON array or raise Bad_format.
    `Null are assume as empty list. *)
let to_list = function
  | `Null   -> []
  | `List l -> l
  | r       -> raise (Type_error ("`List or `Null expected", r))

(** map the given yojson with the given func *)
let map func = function
  | Some x      -> Some (func x)
  | None        -> None
