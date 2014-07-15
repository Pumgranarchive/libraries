
lwt _ =
  (* lwt basic = Dbpedia_http.get_basic_informations "Rhapsody of Fire" in *)
  (* Lwt.return (List.iter Dbpedia_http.print_basic basic) *)

  lwt discography = Dbpedia_http.get_discography "Green Day" in
  Lwt.return (List.iter Dbpedia_http.print_discography discography)
