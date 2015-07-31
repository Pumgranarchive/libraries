(**
   {b
   Urlnorm -
   A ocaml Urlnorm binding
   https://pypi.python.org/pypi/urlnorm
   }

   This binding need urlnorm to be installed
*)

(**
   normalize url
   - lowercasing the scheme and hostname
   - converting the hostname to IDN format
   - taking out default port if present (e.g., http://www.foo.com:80/)
   - collapsing the path (./, ../, etc)
   - removing the last character in the hostname if it is ‘
   - unquoting any % escaped characters (where possible)

   plus some personal addition
   - replace https to http
   - remove fragement of urls
   - remove subdomaine www
   - sort query in the alphabetic order
   - limit the query with 2 parameters
*)
val normalize : string list -> string list
