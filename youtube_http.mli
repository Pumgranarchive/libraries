
(*** Types ***)
(* private *)
type id

(* public *)
type title = string
type url = string
type tight_description = string
type topic_ids = string list
type relevant_topic_ids = string list
type categories = (topic_ids * relevant_topic_ids)
type video = (title * url * tight_description * categories)

(*** Constructors ***)
val get_id_from_url     : string -> id

(*** Printing ***)
val print_youtube_video : video -> unit

(*** Requests ***)
val get_video_from_id   : id list -> video list Lwt.t
val search_video        : string -> int -> video list Lwt.t


