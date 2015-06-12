module Yojson = Yojson.Basic

open Ptype

exception Pumgrana of string

(******************************************************************************
********************************** Common *************************************
*******************************************************************************)

module Common =
struct

  let append str p =
    if String.length str == 0
    then (uri_encode p)
    else str ^ "/" ^ (uri_encode p)

  let map f = function
    | Some x -> Some (f x)
    | None   -> None

  let bind f default = function
    | Some x -> f x
    | None   -> default

  let add_p p str = match p with
    | Some p -> append str p
    | None   -> str

  let add_p_list opt_lp str = match opt_lp with
    | Some lp -> (List.fold_left (fun str p -> append str p) str lp)
    | None    -> str

end

module List =
struct

  include List

  let split_to interval_size list =
    let rec aux i build old = function
      | []   ->
        let build' =
          if List.length old > 0
          then (List.rev old)::build
          else build
        in
        List.rev build'
      | h::t ->
        let i' = i + 1 in
        let old' = h::old in
        if i' >= interval_size
        then aux 0 ((List.rev old')::build) [] t
        else aux i' build old' t
    in
    if interval_size <= 0
    then raise (Invalid_argument "Interval size has to be >= 0");
    aux 0 [] [] list

end

module Lwt_list =
struct

  include Lwt_list

  let iter func list =
    let rec aux = function
      | []   -> Lwt.return ()
      | h::t ->
        lwt () = func h in
        aux t
    in
    aux list

  let fold_left func initial list =
    let rec aux data = function
      | []   -> Lwt.return data
      | h::t ->
        lwt data' = func data h in
        aux data' t
    in
    aux initial list

end

(******************************************************************************
*********************************** Json **************************************
*******************************************************************************)

module Json =
struct

  let of_uri uri = `String (string_of_uri uri)
  let of_uris uris = `List (List.map of_uri uris)
  let of_string str = `String str
  let of_strings strs = `List (List.map of_string strs)
  let of_int dec = `Int dec
  let of_ints decs = `List (List.map of_int decs)
  let of_float dec = `Float dec
  let of_floats decs = `List (List.map of_float decs)

  let add name f p list = Common.bind (fun x -> (name, f x)::list) list p

end

(******************************************************************************
******************************** Exception ************************************
*******************************************************************************)

module Exc =
struct

  let wrapper func =
    try_lwt func ()
    with e -> raise (Pumgrana ("Pumgrana: " ^ (Printexc.to_string e)))

end

(******************************************************************************
*********************************** HTTP **************************************
*******************************************************************************)

module Http =
struct

  let base_headers () =
    Cohttp.Header.init_with "accept" "application/json"

  let get uri parameters =
    let headers = base_headers () in
    let uri = !Ph_conf.pumgrana_api_uri ^ uri ^ parameters in
    let uri = Uri.of_string uri in
    lwt header, body =
        try Cohttp_lwt_unix.Client.get ~headers uri
        with e -> (print_endline (Printexc.to_string e); raise e)
    in
    lwt body_string = Cohttp_lwt_body.to_string body in
    Lwt.return (Yojson.from_string body_string)

  let post_headers content_length =
    let headers = base_headers () in
    let headers' = Cohttp.Header.add headers "content-type" "application/json" in
    Cohttp.Header.add headers' "content-length" (string_of_int content_length)

  let post uri json =
    let data = Yojson.to_string json in
    let headers = post_headers (String.length data) in
    let uri = Uri.of_string (!Ph_conf.pumgrana_api_uri ^ uri) in
    let body = ((Cohttp.Body.of_string data) :> Cohttp_lwt_body.t) in
    lwt h, body =
        try Cohttp_lwt_unix.Client.post ~body ~chunked:false ~headers uri
        with e -> (print_endline (Printexc.to_string e); raise e)
    in
    lwt body_string = Cohttp_lwt_body.to_string body in
    Lwt.return (Yojson.from_string body_string)

end
