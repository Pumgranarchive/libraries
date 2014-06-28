
(* open Rdf_sparql *)
open Yojson.Basic

(*
** Main()
*)

lwt _ =
    (* lwt youtube_video = Youtube_http.search_video "le fossoyeur" x2 in *)
    lwt tamer =
    let url_list = ["https://www.youtube.com/watch?v=WFDR6OwFcn4";
       "https://www.youtube.com/watch?v=a-7MKTjzW_I"] in
    let id_list = List.map Youtube_http.get_id_from_url url_list
    in
    Youtube_http.get_video_from_id id_list
  in
  Lwt.return (List.map Youtube_http.print_youtube_video tamer)

(* freebase request part *)
(* let freebase_url_final = Freebase_http.create_freebase_search_url "bob" *)
(* lwt freebase_results = exec_http_request freebase_url_final *)
(* let freebase_json = get_json_from_http_results freebase_results *)
