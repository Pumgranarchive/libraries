(**
   {b Pghttp -
   Implementing the redirection over cohttp}
*)

val get :
    ?headers:Cohttp.Header.t ->
    Uri.t -> (Cohttp.Response.t * Cohttp_lwt_body.t) Lwt.t

val post :
    ?body:Cohttp_lwt_body.t ->
    ?chunked:bool ->
    ?headers:Cohttp.Header.t ->
    Uri.t -> (Cohttp.Response.t * Cohttp_lwt_body.t) Lwt.t
