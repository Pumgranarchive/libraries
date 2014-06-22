PROJECT_NAME := pumfreebot

# FILES := $(wildcard *.ml *.mli)
#LIB_FILES := rdf_sparql_http.mli rdf_4s.mli rdf_sparql_http.ml rdf_4s.ml
LIB_FILES := rdf_sparql_http.mli rdf_sparql_http.ml
# LIB_FILES := rdf_4s.mli rdf_4s.ml
MY_FILES := youtube_http.ml freebase_http.ml bot.ml 

RM := rm -fv

all:
	ocamlfind ocamlc -syntax camlp4o -package lwt.syntax -linkpkg -package lwt,cohttp,cohttp.lwt,rdf,rdf.lwt,yojson -o $(PROJECT_NAME) $(LIB_FILES) $(MY_FILES)


clean:
	@$(RM) *.cmi *.cmo
	@$(RM) $(PROJECT_NAME)