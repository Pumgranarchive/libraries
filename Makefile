NAME :=		bfy

ML :=		yojson_wrap.ml		\
		bfy_helpers.ml		\
		http_request_manager.ml	\
		freebase_http.ml	\
		youtube_http.ml		\
		bot.ml

MLI :=		youtube_http.mli


PACKAGES :=	lwt,cohttp,cohttp.lwt,yojson,str

CMX :=		$(ML:.ml=.cmx)
CMO :=		$(ML:.ml=.cmo)
CMI :=		$(MLI:.mli=.cmi)
LIB :=		-package $(PACKAGES)
SYNTAX :=	-syntax camlp4o -package lwt.syntax
OCAMLFIND :=	ocamlfind
OCAMLC :=	$(OCAMLFIND) ocamlc $(SYNTAX) -linkpkg $(LIB)
OCAMLOPT :=	$(OCAMLFIND) ocamlopt $(SYNTAX) -linkpkg $(LIB)
OCAMLDEP :=	$(OCAMLFIND) ocamldep $(SYNTAX) $(LIB)

RM :=		rm -fv

all:		$(NAME) lib

$(NAME):	.depend $(CMI) $(CMX)
		$(OCAMLOPT) -o $@ $(CMX)

lib:		$(CMI) $(CMO)
		$(OCAMLC) -a $(CMO) -o $(NAME).cmxa

install:	lib
		$(OCAMLFIND) install $(NAME) META $(NAME).cmxa

uninstall:
		$(OCAMLFIND) remove $(NAME)

.SUFFIXES:	.ml .mli .cmo .cmi .cmx

.ml.cmx:
		$(OCAMLOPT) -c $<

.ml.cmo:
		$(OCAMLC) -c $<

.mli.cmi:
		$(OCAMLC) -c $<

clean:
		@$(RM) *.cm[iox] *.o
		@$(RM) $(NAME) $(NAME).cmxa

re:		clean $(NAME)
.depend:	# $(ML)
		@$(RM) .depend
		$(OCAMLDEP) $(MLI) $(ML) > .depend

#include .dependbot.ml
