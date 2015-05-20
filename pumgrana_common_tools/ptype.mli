(**
   {b Pumgrana API types}
*)

(** Raised in case of invalid uri  *)
exception Invalid_uri of string

(** Raise in case od invalid link_id  *)
exception Invalid_link_id of string

type uri

val compare_uri : uri -> uri -> int

(** Create a URI from a string.
    @raise Invalid_uri in case of the string does not represent an URI. *)
val uri_of_string : string -> uri

(** Create a string from a URI  *)
val string_of_uri : uri -> string

(** Encode all slash of the given string url  *)
val uri_encode : string -> string

(** Decode all slash of the given string url  *)
val uri_decode : string -> string
