
(* open Rdf_sparql *)
open Yojson.Basic

(*
** Main()
*)

(* youtube request part *)
lwt _ =
    (* lwt youtube_video = Youtube_http.search_video "le fossoyeur" "2" in *)
    lwt tamer = Youtube_http.get_video_from_url ["https://www.youtube.com/watch?v=WFDR6OwFcn4"; "https://www.youtube.com/watch?v=a-7MKTjzW_I"] in
    Lwt.return (List.map Youtube_http.print_youtube_video tamer)
    (* List.map print_endline (Rdf_uri.path tamer); *)
    (* Lwt.return ( *)
    (*   List.map Youtube_http.print_youtube_video youtube_video *)
    (* ) *)


(* freebase request part *)
(* let freebase_url_final = Freebase_http.create_freebase_search_url "bob" *)
(* lwt freebase_results = exec_http_request freebase_url_final *)
(* let freebase_json = get_json_from_http_results freebase_results *)
