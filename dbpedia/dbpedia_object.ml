(* module type GENERIC = *)
(*     sig *)

(*       type key = Title | Abstract | Type | Wikipage | IsPrimaryTopicOf *)
(*                  | Label | SameAs | Song | SongName | Album *)

(*       type result *)

(*       val string_of_key : key -> string *)

(*      (\** [parse keys solutions]  *\) *)
(*       val parse : key list -> Rdf_sparql.solution list -> result list *)

(*      (\** [get result key] *)
(*          @raise Not_found is the value of key is not found *\) *)
(*       val get : key list -> result list -> key -> result *)

(*       (\** Use get but return a string  *\) *)
(*       val get_string : key list -> result list -> key -> string *)

(*     end;; *)

module Generic =
    struct

      type key = Title | Abstract | Type | Wikipage | IsPrimaryTopicOf
                 | Label | SameAs | Song | SongName | Album

      type result = String of string

      (* let find pairs key_to_find = *)
      (*   let is_equal (key, value) = *)
      (*     let r = (String.compare key key_to_find = 0) in *)
      (*     Printf.printf "%s %s %b\n" key key_to_find r; *)
      (*     r *)
      (*   in *)
      (*   let pair = List.find is_equal pairs in *)
      (*   let (key, value) = pair in *)
      (*   value *)

      let to_string term =
        String (Rdf_term.string_of_term term)

      let data_of_key = function
        | Title                -> (to_string, "title")
        | Abstract             -> (to_string, "abstract")
        | Type                 -> (to_string, "type")
        | Wikipage             -> (to_string, "wikiPage")
        | IsPrimaryTopicOf     -> (to_string, "isPrimaryTopicOf")
        | Label                -> (to_string, "label")
        | SameAs               -> (to_string, "sameAs")
        | Song                 -> (to_string, "song")
        | SongName             -> (to_string, "song_name")
        | Album                -> (to_string, "album")


      let string_of_key key =
        let func, name = data_of_key key in
        name

      let function_of_key key =
        let func, name = data_of_key key in
        func

      let values_of_solutions keys solutions =
        let get_pair solution =
          let aux l key =
            let convert_f, str_key = data_of_key key in
            if Rdf_sparql.is_bound solution str_key
            then convert_f (Rdf_sparql.get_term solution str_key)::l
            else l
          in
          List.fold_left aux [] keys
        in
        List.map get_pair solutions

      (* let get_value pairs key = *)
      (*   let key_name = string_of_key key in *)
      (*   let convert =  in *)
      (*   convert pairs key_name *)

      let print_pair = function
        | Some (key, value) -> Printf.printf "%s :: %s\n" key value
        | None              -> ()

      let print_value = function
        | Some v -> print_endline v;
        | None   -> ()

      let parse keys solutions =
        values_of_solutions keys solutions

      let key_compare k1 k2 =
        let str_k1 = string_of_key k1 in
        let str_k2 = string_of_key k2 in
        String.compare str_k1 str_k2

      let get keys res key =
        let get_pos select_f list =
          let rec aux select_f count = function
            | k::tail   ->
              if select_f k
              then count
              else aux select_f (count + 1) tail
            | []        -> count
          in
          let pos = aux select_f 0 list in
          if pos < List.length list then pos else
            (print_endline (string_of_key key);
             raise Not_found)
        in
        let compare k = key_compare k key = 0 in
        let pos = get_pos compare keys in
        List.nth res pos

      let get_string keys res key =
        let ret = get keys res key in
        match ret with
        | String r -> r
        | _        -> failwith ((string_of_key key) ^ " : is not a string")

    end;;

class ground_record v =
  object
    val mutable keys = ref []
    val mutable values = v
    method private k_add k = keys := k::!keys
    method keys = !keys
    method private get_string k = (Generic.get_string !keys values k : string)
  end

class model k v =
  object (self)
    inherit ground_record v
    initializer self#k_add k
  end;;

class model_string k v =
  object (self)
    inherit model k v
    method private get = self#get_string k
  end;;

class record_title v =
  object
    inherit model_string Generic.Title v as m
    method title = m#get
  end;;

class record_abstract v =
  object
    inherit model_string Generic.Abstract v as m
    method abstract = m#get
  end;;

class record_type v =
  object (self)
    inherit model_string Generic.Type v as m
    method type_v = m#get
  end;;

class record_wiki_page v =
  object (self)
    inherit model_string Generic.Wikipage v as m
    method wiki_page = m#get
  end;;

class record_is_primary_topic_of v =
  object (self)
    inherit model_string Generic.IsPrimaryTopicOf v as m
    method is_primary_topic_of = m#get
  end;;

class record_label v =
  object (self)
    inherit model_string Generic.Label v as m
    method label = m#get
  end;;

class record_same_as v =
  object (self)
    inherit model_string Generic.SameAs v as m
    method same_as = m#get
  end;;

class record_song v =
  object (self)
    inherit model_string Generic.Song v as m
    method song = m#get
  end;;

class record_song_name v =
  object (self)
    inherit model_string Generic.SongName v as m
    method song_name = m#get
  end;;

class record_album v =
  object (self)
    inherit model_string Generic.Album v as m
    method album = m#get
  end;;

let parse new_t solutions =
  let values = Generic.parse (new_t [])#keys solutions in
  List.map (new_t) values

module Basic =
struct
  class t v =
  object
    inherit record_title v
    inherit record_abstract v
    inherit record_type v
    inherit record_wiki_page v
    inherit record_is_primary_topic_of v
    inherit record_label v
    inherit record_same_as v
  end
  let parse = parse (new t)
end;;

module Disco =
struct
  class t v =
  object
    inherit record_song v
    inherit record_song_name v
    inherit record_album v
  end
  let parse = parse (new t)
end;;
