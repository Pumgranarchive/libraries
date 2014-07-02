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
OCAMLC :=	$(OCAMLFIND) ocamlc $(SYNTAX) $(LIB)
OCAMLOPT :=	$(OCAMLFIND) ocamlopt $(SYNTAX) $(LIB)
OCAMLDEP :=	$(OCAMLFIND) ocamldep $(SYNTAX) $(LIB)

RM :=		rm -fv

all:		$(NAME) lib

re:		clean all

$(NAME):	.depend $(CMI) $(CMX)
		$(OCAMLOPT) -linkpkg $(CMX) -o $@

lib:		.depend $(CMI) $(CMO)
		$(OCAMLC) -a $(CMO) -o $(NAME).cma

install:	$(CMI) $(CMX) $(CMO) lib
		$(OCAMLFIND) install $(NAME) META $(NAME).cma $(CMI) $(CMX) $(CMO)

uninstall:
		$(OCAMLFIND) remove $(NAME)

reinstall:	re uninstall install

.SUFFIXES:	.ml .mli .cmo .cmi .cmx

.ml.cmx:
		$(OCAMLOPT) -c $<

.ml.cmo:
		$(OCAMLC) -c $<

.mli.cmi:
		$(OCAMLC) -c $<

clean:
		@$(RM) *.cm[iox] *.o
		@$(RM) $(NAME) $(NAME).cma

.depend:
		@$(RM) .depend
		$(OCAMLDEP) $(MLI) $(ML) > .depend

include .depend
