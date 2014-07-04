(*
** A couple of function wraping Yojson library
*)

(*** exceptions ***)
exception Yojson_exc of string

(*** wrapers ***)
(** Same as Yojson.Basic.Util.member but return `Null if json is null *)
let member name json = match json with
  | `Null       -> `Null
  | _           -> Yojson.Basic.Util.member name json

(** Extract a list from JSON array or raise Yojson_exc.
    `Null are assume as empty list. *)
let to_list = function
  | `Null   -> []
  | `List l -> l
  | _       -> raise (Yojson_exc "Bad list format")

(** Extract a list from JSON array or raise Yojson_exc.
    `Null are assume as empty list. *)
let to_string = function
  | `Null   -> ""
  | `String s -> s
  | _       -> raise (Yojson_exc "Bad list format")
