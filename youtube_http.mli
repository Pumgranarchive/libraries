
(*** Types ***)
(* private *)
type id

(* public *)
type title = string
type url = string
type description = string
type video = (title * url * description)

(*** Constructors ***)
val get_id_from_url     : string -> id

(*** Printing ***)
val print_youtube_video : video -> unit

(*** Requests ***)
val get_video_from_id   : id list -> video list Lwt.t
val search_video        : string -> int -> video list Lwt.t


