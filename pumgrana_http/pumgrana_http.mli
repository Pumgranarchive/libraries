(**
   {b Pumgrana -
   This module bind the Pumgrana API}
*)

exception Pumgrana of string

open Ptype

(** Set the pumgrana API uri
    Default: http://127.0.0.1:8081/api/ *)
val set_pumgrana_api_uri : uri -> unit

(** {6 Contents}  *)

val content_detail : uri ->
  (uri * string * string * string) Lwt.t

val contents : unit ->
  (uri * string * string) list Lwt.t

(** [research_contents research]  *)
val search_contents : string ->
  (uri * string * string) list Lwt.t

(**
   [insert_content uri title summary tags]
    - [tags] as (subject * mark) list
*)
val insert_content : uri -> string -> string ->
  (string * float) list -> uri Lwt.t

val delete_contents : uri list -> unit Lwt.t

(** {6 Tags}  *)

(** [tags_search search] *)
val tags_search : string -> (uri * string) list Lwt.t

val tags_from_content : uri -> (uri * string) list Lwt.t

(** {6 LinkedContents}  *)

(** [linkedcontent_detail link_id] *)
val linkedcontent_detail : int ->
  (int * uri * uri * (uri * string) list) Lwt.t

(** [links_search content_uri search] *)
val linkedcontent_search : uri -> string ->
  (int * uri * string * string * string) list Lwt.t

val linkedcontent_from_content : uri ->
  (int * uri * string * string * string) list Lwt.t

val linkedcontent_from_content_tags : uri -> uri list ->
  (int * uri * string * string * string) list Lwt.t

(** {6 Links}  *)

val insert_links : (uri * uri * string * float) list ->
  int list Lwt.t

val delete_links : int list -> unit Lwt.t
