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
  (uri * string * string * string) Lwt.t

val get_contents : ?filter:filter -> ?tags_uri:uri list -> unit ->
  (uri * string * string) list Lwt.t

val insert_content : string -> string -> string ->
  ?tags_uri:uri list -> unit -> uri Lwt.t

val update_content : uri -> ?title:string -> ?summary:string ->
  ?body:string -> ?tags_uri:uri list -> unit -> unit Lwt.t

val update_content_tags : uri -> uri list -> unit Lwt.t

val delete_contents : uri list -> unit Lwt.t

(** {6 Tags}  *)

val tags_by_type : type_name -> (uri * string) list Lwt.t

val tags_from_content : uri -> (uri * string) list Lwt.t

val tags_from_content_links : uri -> (uri * string) list Lwt.t

val insert_tags : type_name -> ?uri:uri -> string list -> uri list Lwt.t

val delete_tags : uri list -> unit Lwt.t

(** {6 Links}  *)

val get_link_detail : link_id ->
  (link_id * uri * uri * (uri * string) list) Lwt.t

val links_from_content : uri ->
  (link_id * uri * string * string) list Lwt.t

val links_from_content_tags : uri -> uri list ->
  (link_id * uri * string * string) list Lwt.t

val insert_links : (uri * uri * uri list) list -> uri list Lwt.t

val update_links : (link_id * uri list) list -> unit Lwt.t

val delete_links : link_id list -> unit Lwt.t
