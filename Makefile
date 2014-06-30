NAME :=		pumgrana

ML :=		pjson.ml		\
		ptype.ml		\
		pdeserialize.ml		\
		pumgrana.ml		\

MLI :=		ptype.mli		\
		pumgrana.mli		\


PACKAGES :=	lwt,cohttp,cohttp.lwt,rdf,str,yojson

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
		$(OCAMLC) -a $(CMO) -o $(NAME).cma

install:	lib
		$(OCAMLFIND) install $(NAME) META $(NAME).cma

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

re:		clean $(NAME)
.depend:	# $(ML)
		@$(RM) .depend
		$(OCAMLDEP) $(MLI) $(ML) > .depend

#include .dependbot.ml
