(**
   {b Pumgrana json }
*)

(** return the Some member associate of name, and None if not found *)
val opt_member : string -> Yojson.Basic.json -> Yojson.Basic.json option

(** not_null default value return default if value is `Null  *)
val not_null : Yojson.Basic.json -> Yojson.Basic.json -> Yojson.Basic.json

(** Extract a list from JSON array
    @raise Bad_format.
    `Null are assume as empty list. *)
val to_list : Yojson.Basic.json -> Yojson.Basic.json list

(** map the given yojson with the given func *)
val map : (Yojson.Basic.json -> 'b) -> Yojson.Basic.json option -> 'b option
