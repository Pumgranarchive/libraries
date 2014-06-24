
open Rdf_sparql
open Yojson.Basic

(*
** Main()
*)

(* youtube request part *)
lwt _ =
    lwt youtube_video = Youtube_http.search_video "le fossoyeur" "2" in
    Lwt.return (
      List.map Youtube_http.print_youtube_video youtube_video
    )


(* freebase request part *)
(* let freebase_url_final = Freebase_http.create_freebase_search_url "bob" *)
(* lwt freebase_results = exec_http_request freebase_url_final *)
(* let freebase_json = get_json_from_http_results freebase_results *)
