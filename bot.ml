
(* open Rdf_sparql *)
open Yojson.Basic

(*
** Main()
*)

lwt _ =
    lwt tamer = Youtube_http.search_video "le fossoyeur" 2
    (* lwt tamer = *)
    (* let url_list = ["https://www.youtube.com/watch?v=WFDR6OwFcn4"; *)
    (*    "https://www.youtube.com/watch?v=a-7MKTjzW_I";"https://www.youtube.com/watch?v=j7uiWGEPxNQ"] in *)
    (* let id_list = List.map Youtube_http.get_id_from_url url_list *)
    (* in *)
    (* Youtube_http.get_videos_from_ids id_list *)
  in
  Lwt.return (List.map Youtube_http.print_youtube_video tamer)

lwt _ =
  lwt freebase_results = Freebase_http.search "bob" in
  Lwt.return (Freebase_http.print_json freebase_results)

