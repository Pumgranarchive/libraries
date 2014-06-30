NAME :=		pumgrana_api

ML :=		pumgrana.ml

MLI :=		pumgrana.mli


PACKAGES :=	lwt,cohttp,cohttp.lwt,rdf,str,yojson,ptools

CMX :=		$(ML:.ml=.cmx)
CMO :=		$(ML:.ml=.cmo)
CMI :=		$(wildcard *.cmi)
LIB :=		-package $(PACKAGES)
SYNTAX :=	-syntax camlp4o -package lwt.syntax
OCAMLFIND :=	ocamlfind
OCAMLC :=	$(OCAMLFIND) ocamlc $(SYNTAX) $(LIB)
OCAMLOPT :=	$(OCAMLFIND) ocamlopt $(SYNTAX) $(LIB)
OCAMLDEP :=	$(OCAMLFIND) ocamldep $(SYNTAX) $(LIB)

RM :=		rm -fv

all:		$(NAME) lib

re:		clean $(NAME)

$(NAME):	.depend $(CMI) $(CMO)
		$(OCAMLC) -linkpkg $(CMO) -o $@

lib:		.depend $(CMI) $(CMO)
		$(OCAMLC) -a $(CMO) -o $(NAME).cma

install:	lib $(CMI) $(CMX) $(CMO)
		$(OCAMLFIND) install $(NAME) META $(NAME).cma $(CMI) $(CMX) $(CMO)

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
		@$(RM) $(NAME) $(NAME).cma

.depend:
		$(OCAMLDEP) $(MLI) $(ML) > .depend

include .depend
