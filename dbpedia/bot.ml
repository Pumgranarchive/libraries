

lwt _ =

  lwt basic = Dbpedia_http.get_basic_informations "Tron" in
  Lwt.return (List.iter Dbpedia_http.print_basic basic)

  (* lwt discography = Dbpedia_http.get_discography "Green Day" in *)
  (* Lwt.return (List.iter Dbpedia_http.print_discography discography) *)

    (* lwt wikipedia = Dbpedia_http.get_minimal_informations "http://en.wikipedia.org/wiki/Metal_(song)" in *)
    (* Lwt.return (List.iter Dbpedia_http.print_lightweight wikipedia) *)
