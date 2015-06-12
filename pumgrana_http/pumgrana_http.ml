(**
   Pumgrana
   The Http Pumgrana API Binding
*)

open Ph_utils

exception Pumgrana = Ph_utils.Pumgrana

let set_pumgrana_api_uri uri =
  Ph_conf.pumgrana_api_uri := Ptype.string_of_uri uri

(******************************************************************************
********************************* Content *************************************
*******************************************************************************)

let content_detail content_uri =
  let aux () =
    let parameter = Ptype.uri_encode (Ptype.string_of_uri content_uri) in
    lwt json = Http.get Ph_conf.content_detail_uri parameter in
    Lwt.return (List.hd Pdeserialize.(get_service_return get_content_list json))
  in
  Exc.wrapper aux

let contents () =
  let aux () =
    let parameters = "" in
    lwt json = Http.get Ph_conf.contents_uri parameters in
    Lwt.return (Pdeserialize.(get_service_return get_short_content_list json))
  in
  Exc.wrapper aux

let search_contents search =
  let aux () =
    let parameters = search in
    lwt json = Http.get Ph_conf.search_contents_uri parameters in
    Lwt.return (Pdeserialize.(get_service_return get_short_content_list json))
  in
  Exc.wrapper aux

let insert_content uri title summary subjects =
  let aux () =
    let json = `Assoc ([("uri", `String (Ptype.string_of_uri uri));
                        ("title", `String title);
                        ("summary", `String summary);
                        ("subjects", Json.of_strings subjects)])
    in
    lwt json = Http.post Ph_conf.content_insert_uri json in
    Lwt.return (Pdeserialize.get_content_uri_return json)
  in
  Exc.wrapper aux

let delete_contents uris =
  let aux () =
    let json = `Assoc [("contents_uri", Json.of_uris uris)] in
    lwt _ = Http.post Ph_conf.content_delete_uri json in
    Lwt.return ()
  in
  Exc.wrapper aux

(******************************************************************************
*********************************** Tag ***************************************
*******************************************************************************)

let tags_search search =
  let aux () =
    lwt json = Http.get Ph_conf.search_tag_content_uri search in
    Lwt.return (Pdeserialize.(get_service_return get_tag_list json))
  in
  Exc.wrapper aux

let tags_from_content content_uri =
  let aux () =
    let parameter = Ptype.uri_encode (Ptype.string_of_uri content_uri) in
    lwt json = Http.get Ph_conf.tag_content_uri parameter in
    Lwt.return (Pdeserialize.(get_service_return get_tag_list json))
  in
  Exc.wrapper aux

(******************************************************************************
******************************* LinkedContent *********************************
*******************************************************************************)

let linkedcontent_detail linkedcontent_id =
  let aux () =
    let parameter = string_of_int linkedcontent_id in
    lwt json = Http.get Ph_conf.linkedcontent_detail_uri parameter in
    let ret = Pdeserialize.(get_service_return get_detail_linkedcontent_list json) in
    Lwt.return (List.hd ret)
  in
  Exc.wrapper aux

let linkedcontent_search content_uri search =
  let aux () =
    let encoded_uri = Ptype.uri_encode (Ptype.string_of_uri content_uri) in
    let parameter = encoded_uri ^ "/" ^ search in
    lwt json = Http.get Ph_conf.search_linkedcontent_content_uri parameter in
    Lwt.return (Pdeserialize.(get_service_return get_linkedcontent_list json))
  in
  Exc.wrapper aux

let linkedcontent_from_content content_uri =
  let aux () =
    let parameter = Ptype.uri_encode (Ptype.string_of_uri content_uri) in
    lwt json = Http.get Ph_conf.linkedcontent_content_uri parameter in
    Lwt.return (Pdeserialize.(get_service_return get_linkedcontent_list json))
  in
  Exc.wrapper aux

let linkedcontent_from_content_tags content_uri tags_uri =
  let aux () =
    let content_str_uri = Ptype.string_of_uri content_uri in
    let str_tags_uri = List.map Ptype.string_of_uri tags_uri in
    let parameters =
      (List.fold_left Common.append
         (Common.append "" content_str_uri) str_tags_uri ) ^ "/"
    in
    lwt json = Http.get Ph_conf.linkedcontent_content_tags_uri parameters in
    Lwt.return (Pdeserialize.(get_service_return get_linkedcontent_list json))
  in
  Exc.wrapper aux

(******************************************************************************
************************************ Link *************************************
*******************************************************************************)

let insert_links links =
  let aux links () =
    let json_of_links (origin_uri, target_uri, nature, mark) =
      `Assoc [("origin_uri", Json.of_uri origin_uri);
              ("target_uri", Json.of_uri target_uri);
              ("nature", Json.of_string nature);
              ("mark", Json.of_float mark)]
    in
    let json = `List (List.map json_of_links links) in
    let json = `Assoc [("data", json)] in
    lwt json = Http.post Ph_conf.link_insert_uri json in
    Lwt.return (Pdeserialize.get_link_id_return json)
  in
  let wrapper ret links =
    lwt tmp = Exc.wrapper (aux links) in
    Lwt.return (ret@tmp)
  in
  let links_list = List.split_to Ph_conf.max_request_list_size links in
  Lwt_list.fold_left wrapper [] links_list

let delete_links ids =
  let aux () =
    let json = `Assoc [("links_id", Json.of_ints ids)] in
    lwt json = Http.post Ph_conf.link_delete_uri json in
    Lwt.return ()
  in
  Exc.wrapper aux
