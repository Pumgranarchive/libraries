PROJECT_NAME := pumfreebot

MY_FILES := http_request_manager.ml youtube_http.ml freebase_http.ml bot.ml
DEPS := str.cma

RM := rm -fv

all:
	ocamlfind ocamlc -syntax camlp4o -package lwt.syntax -linkpkg -package lwt,cohttp,cohttp.lwt,yojson -o $(PROJECT_NAME) $(DEPS) $(MY_FILES)


clean:
	@$(RM) *.cmi *.cmo
	@$(RM) $(PROJECT_NAME)