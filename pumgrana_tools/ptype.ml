(**
   Ptype
   Pumgrana type for internal uses
*)

(******************************************************************************
****************************** Implementation *********************************
*******************************************************************************)

exception Invalid_uri of string

type uri = Uri.t

let start_with_http_s uri =
  try
    let regexp = Str.regexp "^https?://" in
    let _ = Str.search_forward regexp uri 0 in
    true
  with Not_found -> false

let uri_of_string uri =
  begin
    if (not (start_with_http_s uri)) then raise (Invalid_uri uri);
    Uri.of_string uri
  end

let string_of_uri = Uri.to_string

let compare_uri u1 u2 =
  let str_u1 = List.hd (Urlnorm.normalize [string_of_uri u1]) in
  let str_u2 = List.hd (Urlnorm.normalize [string_of_uri u2]) in
  String.compare str_u1 str_u2

let uri_encode url = Netencoding.Url.encode url
  (* replace char_list encoded_char url *)

let uri_decode url = Netencoding.Url.decode url
  (* replace encoded_char char_list url *)


(******************************************************************************
*********************************** Test **************************************
*******************************************************************************)

module Test =
struct

  let encode () =
    let uri = "https://en.wikipedia.org/wiki/Johnny_Hallyday#" in
    let should_be = "https%3A%2F%2Fen.wikipedia.org%2Fwiki%2FJohnny_Hallyday%23" in
    let encoded = uri_encode uri in
    if (String.compare encoded should_be == 0)
    then print_endline "[Success]\t encode_uri"
    else print_endline "[Fail]\t encode_uri"

  let decode () =
    let encoded = "https%3A%2F%2Fen.wikipedia.org%2Fwiki%2FJohnny_Hallyday%23" in
    let should_be = "https://en.wikipedia.org/wiki/Johnny_Hallyday#" in
    let decoded = uri_decode encoded in
    if (String.compare decoded should_be == 0)
    then print_endline "[Success]\t decode_uri"
    else print_endline "[Fail]\t decode_uri"

  let compare () =
    let uri_1 = uri_of_string "https://en.wikipedia.org/wiki/Astra_19.2°E" in
    let uri_2 = uri_of_string "http://en.wikipedia.org/wiki/Astra_19.2°E" in
    if (compare_uri uri_1 uri_2 == 0)
    then print_endline "[Success]\t compare_uri"
    else print_endline "[Fail]\t compare_uri"

  let cast () =
    let should_succed uri =
      try begin ignore (uri_of_string uri); true end
      with Invalid_uri u -> false
    in
    let should_fail uri = not (should_succed uri) in
    let good_string_uris = ["https://en.wikipedia.org/wiki/Astra_19.2°E";
                            "http://en.wikipedia.org/wiki/Astra_19.2°E"]
    in
    let bad_string_uris = ["fjkelwf://en.wikipedia.org/wiki/Astra_19.2°E";
                           "ipoo://en.wikipedia.org/wiki/Astra_19.2°E"]
    in
    let all_succed = List.for_all should_succed good_string_uris  in
    let all_failed = List.for_all should_fail bad_string_uris  in
    if (all_succed && all_failed)
    then print_endline "[Success]\t cast_uri"
    else print_endline "[Fail]\t cast_uri"

end

let main () =
  begin
    Test.cast ();
    Test.compare ();
    Test.encode ();
    Test.decode ()
  end

(* let () = main () *)
