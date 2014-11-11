NAME :=		pumgrana_http

ML :=		conf.ml		\
		utils.ml	\
		$(NAME).ml

MLI :=		$(NAME).mli


PACKAGES :=	lwt,cohttp,cohttp.lwt,rdf,str,yojson,ptools

CMX :=		$(ML:.ml=.cmx)
CMO :=		$(ML:.ml=.cmo)
CMI :=		$(MLI:.mli=.cmi)
LIB :=		-package $(PACKAGES)
SYNTAX :=	-syntax camlp4o -package lwt.syntax
DOC_DIR :=	doc/html
OCAMLFIND :=	ocamlfind
OCAMLDOC :=	$(OCAMLFIND) ocamldoc $(SYNTAX) $(LIB) -intro doc/indexdoc -html -d $(DOC_DIR)
OCAMLC :=	$(OCAMLFIND) ocamlc $(SYNTAX) $(LIB)
OCAMLOPT :=	$(OCAMLFIND) ocamlopt $(SYNTAX) $(LIB)
OCAMLDEP :=	$(OCAMLFIND) ocamldep $(SYNTAX) $(LIB)

RM :=		rm -fv

all:		$(NAME) lib

re:		clean all

$(NAME):	.depend $(CMI) $(CMO)
		$(OCAMLC) -linkpkg $(CMO) -o $@

lib:		.depend $(CMI) $(CMO)
		$(OCAMLC) -a $(CMO) -o $(NAME).cma

install:	lib $(NAME).cmi $(NAME).cmx $(NAME).cmo
		$(OCAMLFIND) install $(NAME) META $(NAME).cma $(NAME).cmi $(NAME).cmx $(NAME).cmo

uninstall:
		$(OCAMLFIND) remove $(NAME)

reinstall:	re uninstall install

doc:
		mkdir -p $(DOC_DIR)
		$(OCAMLDOC) $(MLI)

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

.PHONY:		doc

include .depend
