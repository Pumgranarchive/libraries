(**
   {b Pumgrana type -
   This module contains the API Pumgrana type}
*)

exception Invalid_uri of string
exception Invalid_link_id of string

type uri
type link_id
type filter = Most_recent | Most_used | Most_view
type type_name = Link | Content

(** Create a URI from a string.
    @raise Invalid_uri in case of the string does not represent an URI. *)
val uri_of_string : string -> uri

(** Create a string from a URI  *)
val string_of_uri : uri -> string

(** Create a link_id from a string
    @raise Invalid_link_id *)
val link_id_of_string : string -> link_id

(** Create a string from a link_id  *)
val string_of_link_id : link_id -> string
