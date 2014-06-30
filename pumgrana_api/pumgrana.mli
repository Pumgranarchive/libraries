(**
   {b Pumgrana -
   This module bind the Pumgrana API}
*)

exception Internal_error of string

open Ptype

(** Set the pumgrana API uri
    Default: http://127.0.0.1:8081/api/ *)
val set_pumgrana_api_uri : uri -> unit

(** {6 Contents}  *)

val get_content_detail : uri ->
  (uri * string * string * string option) Lwt.t

val get_contents : ?filter:filter -> ?tags_uri:uri list -> unit ->
  (uri * string * string) list Lwt.t

(** {6 Tags}  *)

val tags_by_type : type_name -> (uri * string) list Lwt.t

val tags_from_content : uri -> (uri * string) list Lwt.t

val tags_from_content_links : uri -> (uri * string) list Lwt.t

(** {6 Links}  *)

val get_link_detail : link_id ->
  (link_id * uri * uri * (uri * string) list) Lwt.t

val links_from_content : uri ->
  (link_id * uri * string * string) list Lwt.t

val links_from_content_tags : uri -> uri list ->
  (link_id * uri * string * string) list Lwt.t
