
(*** Types ***)
(* private *)
type video_id

(* public *)
type title = string
type url = string
type sliced_description = string
type topic_ids = string list
type relevant_topic_ids = string list
type categories = (topic_ids * relevant_topic_ids)
type video = (video_id * title * url * sliced_description * categories)

(*** Constructors ***)
val get_video_id_from_url     : string -> video_id

(*** Printing ***)
val print_youtube_video : video -> unit

(*** Requests ***)
val get_videos_from_ids                         : video_id list -> video list Lwt.t
val search_video                                : string -> int -> video list Lwt.t

val get_videos_from_playlist_id                 : string -> int -> video list Lwt.t
val get_uploaded_videos_from_channel_ids        : string list -> video list Lwt.t

