
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

exception BadYoutubeUrl of string
exception Youtube of string

(*** Constructors ***)
(** create an id from a youtube url.
    An exception will be raised if the url is not correct *)
val get_video_id_from_url     : string -> video_id

(*** Printing ***)
(** Print a video on stdout *)
val print_youtube_video : video -> unit

(*** Requests ***)
(** return a list of video from a list of id *)
val get_videos_from_ids                         : video_id list -> video list Lwt.t

(** get a list of video from a research *)
val search_video                                : string -> int -> video list Lwt.t

(** return a list of video from an id *)
val get_videos_from_playlist_id                 : string -> int -> video list Lwt.t

(** return a list of video of a channel from its id *)
val get_uploaded_videos_from_channel_ids        : string list -> video list Lwt.t

(** return a list of video of a channel from the name of the user owner of the channel *)
val get_uploaded_videos_from_user_name          : string -> video list Lwt.t

