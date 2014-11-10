(**
   Pumgrana
   The Http Pumgrana API Binding
*)

open Utils

exception Pumgrana = Utils.Pumgrana

let set_pumgrana_api_uri uri =
  Conf.pumgrana_api_uri := Ptype.string_of_uri uri

(******************************************************************************
********************************* Content *************************************
*******************************************************************************)

let get_content_detail content_uri =
  let aux () =
    let parameter = Ptype.uri_encode (Ptype.string_of_uri content_uri) in
    lwt json = Http.get Conf.content_detail_uri parameter in
    Lwt.return (List.hd Pdeserialize.(get_service_return get_content_list json))
  in
  Exc.wrapper aux

let get_contents ?filter ?tags_uri () =
  let aux () =
    let str_filter = Common.map Common.string_of_filter filter in
    let str_tags_uri = Common.map (List.map Ptype.string_of_uri) tags_uri in
    let parameters = Common.(add_p_list str_tags_uri
                               (add_p str_filter "")) ^ "/"
    in
    lwt json = Http.get Conf.contents_uri parameters in
    Lwt.return (Pdeserialize.(get_service_return get_short_content_list json))
  in
  Exc.wrapper aux

let research_contents ?filter research =
  let aux () =
    let str_filter = Common.map Common.string_of_filter filter in
    let parameters = Common.(add_p str_filter "") ^ "/" ^ research in
    lwt json = Http.get Conf.research_contents_uri parameters in
    Lwt.return (Pdeserialize.(get_service_return get_short_content_list json))
  in
  Exc.wrapper aux

let insert_content title summary body ?tags_uri () =
  let aux () =
    let json = `Assoc (Json.add "tags_uri" Json.of_uris tags_uri
                         [("title", `String title);
                          ("summary", `String summary);
                          ("body", `String body)])
    in
    lwt json = Http.post Conf.content_insert_uri json in
    Lwt.return (Pdeserialize.get_content_uri_return json)
  in
  Exc.wrapper aux

let update_content uri ?title ?summary ?body ?tags_uri () =
  let aux () =
    let json =
      `Assoc (Json.add "tags_uri" Json.of_uris tags_uri
                (Json.add "body" Json.of_string body
                   (Json.add "summary" Json.of_string summary
                      (Json.add "title" Json.of_string title
                         ["content_uri", Json.of_uri uri]))))
    in
    lwt _ = Http.post Conf.content_update_uri json in
    Lwt.return ()
  in
  Exc.wrapper aux

let update_content_tags uri tags_uri =
  let aux () =
    let json =
      `Assoc [("tags_uri", Json.of_uris tags_uri);
              ("content_uri", Json.of_uri uri)]
    in
    lwt _ = Http.post Conf.content_update_tags_uri json in
    Lwt.return ()
  in
  Exc.wrapper aux

let delete_contents uris =
  let aux () =
    let json = `Assoc [("contents_uri", Json.of_uris uris)] in
    lwt _ = Http.post Conf.content_delete_uri json in
    Lwt.return ()
  in
  Exc.wrapper aux

(******************************************************************************
*********************************** Tag ***************************************
*******************************************************************************)

let tags_by_type type_name =
  let aux () =
    let parameter = Common.string_of_type_name type_name in
    lwt json = Http.get Conf.tag_type_uri parameter in
    Lwt.return (Pdeserialize.(get_service_return get_tag_list json))
  in
  Exc.wrapper aux

let tags_from_research research =
  let aux () =
    lwt json = Http.get Conf.research_tag_content_uri research in
    Lwt.return (Pdeserialize.(get_service_return get_tag_list json))
  in
  Exc.wrapper aux

let tags_from_content content_uri =
  let aux () =
    let parameter = Ptype.uri_encode (Ptype.string_of_uri content_uri) in
    lwt json = Http.get Conf.tag_content_uri parameter in
    Lwt.return (Pdeserialize.(get_service_return get_tag_list json))
  in
  Exc.wrapper aux

let tags_from_content_links content_uri =
  let aux () =
    let parameter = Ptype.uri_encode (Ptype.string_of_uri content_uri) in
    lwt json = Http.get Conf.tag_content_links_uri parameter in
    Lwt.return (Pdeserialize.(get_service_return get_tag_list json))
  in
  Exc.wrapper aux

let insert_tags type_name ?uri tags_subject =
  let aux () =
    let json = `Assoc (Json.add "uri" Json.of_uri uri
                         [("type_name",
                           `String (Common.string_of_type_name type_name));
                          ("tags_subject", (Json.of_strings tags_subject))])
    in
    lwt json = Http.post Conf.tag_insert_uri json in
    Lwt.return (Pdeserialize.get_tags_uri_return json)
  in
  Exc.wrapper aux

let delete_tags tags_uri =
  let aux () =
    let json = `Assoc [("tags_uri", Json.of_uris tags_uri)] in
    lwt _ = Http.post Conf.tag_delete_uri json in
    Lwt.return ()
  in
  Exc.wrapper aux

(******************************************************************************
*********************************** Link **************************************
*******************************************************************************)

let get_link_detail link_id =
  let aux () =
    let parameter = Ptype.string_of_link_id link_id in
    lwt json = Http.get Conf.link_detail_uri parameter in
    let ret = Pdeserialize.(get_service_return get_detail_link_list json) in
    Lwt.return (List.hd ret)
  in
  Exc.wrapper aux

let links_from_research content_uri research =
  let aux () =
    let encoded_uri = Ptype.uri_encode (Ptype.string_of_uri content_uri) in
    let parameter = encoded_uri ^ "/" ^ research in
    lwt json = Http.get Conf.research_link_content_uri parameter in
    Lwt.return (Pdeserialize.(get_service_return get_link_list json))
  in
  Exc.wrapper aux

let links_from_content content_uri =
  let aux () =
    let parameter = Ptype.uri_encode (Ptype.string_of_uri content_uri) in
    lwt json = Http.get Conf.link_content_uri parameter in
    Lwt.return (Pdeserialize.(get_service_return get_link_list json))
  in
  Exc.wrapper aux

let links_from_content_tags content_uri tags_uri =
  let aux () =
    let content_str_uri = Ptype.string_of_uri content_uri in
    let str_tags_uri = List.map Ptype.string_of_uri tags_uri in
    let parameters =
      (List.fold_left Common.append
         (Common.append "" content_str_uri) str_tags_uri ) ^ "/"
    in
    lwt json = Http.get Conf.link_content_tags_uri parameters in
    Lwt.return (Pdeserialize.(get_service_return get_link_list json))
  in
  Exc.wrapper aux

let insert_links links =
  let aux links () =
    let json_of_links (origin_uri, target_uri, tags_uri) =
      `Assoc [("origin_uri", Json.of_uri origin_uri);
              ("target_uri", Json.of_uri target_uri);
              ("tags_uri", Json.of_uris tags_uri)]
    in
    let json = `List (List.map json_of_links links) in
    let json = `Assoc [("data", json)] in
    lwt json = Http.post Conf.link_insert_uri json in
    Lwt.return (Pdeserialize.get_links_uri_return json)
  in
  let wrapper ret links =
    lwt tmp = Exc.wrapper (aux links) in
    Lwt.return (ret@tmp)
  in
  let links_list = List.split_to Conf.max_request_list_size links in
  Lwt_list.fold_left wrapper [] links_list

let update_links links =
  let aux links () =
    let json_of_links (link_uri, tags_uri) =
      `Assoc [("link_uri", Json.of_link_id link_uri);
              ("tags_uri", Json.of_uris tags_uri)]
    in
    let json = `Assoc [("data", `List (List.map json_of_links links))] in
    lwt json = Http.post Conf.link_update_uri json in
    Lwt.return ()
  in
  let wrapper links = Exc.wrapper (aux links) in
  let links_list = List.split_to Conf.max_request_list_size links in
  Lwt_list.iter wrapper links_list

let delete_links uris =
  let aux () =
    let json = `Assoc [("links_uri", Json.of_link_ids uris)] in
    lwt json = Http.post Conf.link_delete_uri json in
    Lwt.return ()
  in
  Exc.wrapper aux
