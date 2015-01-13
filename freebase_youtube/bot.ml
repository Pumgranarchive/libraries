
open Yojson.Basic

(*
** Main()
*)

(* lwt  _ = *)
(*   lwt tamer = Youtube_http.search_video "le fossoyeur" 2 *)
(*   in *)
(*   Lwt.return (List.map Youtube_http.print_youtube_video tamer) *)

(* lwt  _ = *)
(*   lwt tamer = *)
(*     let url_list = ["https://www.youtube.com/watch?v=qW6D8rYppwY"; *)
(*                     "https://www.youtube.com/watch?v=ICsryK_w9P0"; *)
(*                     "https://www.youtube.com/watch?v=j7uiWGEPxNQ"; *)
(*                     "https://www.youtube.com/watch?v=g76drQoM3iM"] in *)
(*     let id_list = List.map Youtube_http.get_id_from_url url_list *)
(*     in *)
(*     Youtube_http.get_videos_from_ids id_list *)
(*   in *)
(*   Lwt.return (List.map Youtube_http.print_youtube_video tamer) *)

(* lwt _ = *)
(*   lwt freebase_results = Freebase_http.get_topics "/m/0ndwt2w" in *)
(*   Lwt.return (Freebase_http.print_freebase_object freebase_results) *)

(* lwt  _ = *)
(*   (\* https://www.youtube.com/channel/UCww2zZWg4Cf5xcRKG-ThmXQ *\) *)
(*   lwt tamer = Youtube_http.get_uploaded_videos_from_channel_ids ["UCww2zZWg4Cf5xcRKG-ThmXQ"] *)
(*   in *)
(*   Lwt.return (List.map Youtube_http.print_youtube_video tamer) *)

(* lwt  _ = *)
(*   lwt tamer = Youtube_http.get_uploaded_videos_from_user_name "NormanFaitDesVideos" *)
(*   in *)
(*   Lwt.return (List.map Youtube_http.print_youtube_video tamer) *)

(* lwt  _ = *)
(*   lwt tamer = Youtube_http.get_videos_from_playlist_id "UUww2zZWg4Cf5xcRKG-ThmXQ" 51 *)
(*   in *)
(*   Lwt.return (List.map Youtube_http.print_youtube_video tamer) *)

(* Search TEST *)
lwt () =
  Printf.printf "Launch test\n";
  lwt videos = Youtube_http.search_video ~query:"Test" 10 in
  Printf.printf "Videos %d \n" (List.length videos);
  Lwt.return ()
