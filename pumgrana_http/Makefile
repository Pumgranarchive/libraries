NAME :=		pumgrana_http

ML :=		ph_conf.ml	\
		ph_utils.ml	\
		pumgrana_http.ml

MLI :=		pumgrana_http.mli


PACKAGES :=	lwt,cohttp,cohttp.lwt,yojson,str,rdf,ptools

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

$(NAME):	$(CMI) $(CMO)
		$(OCAMLC) -linkpkg $(CMO) -o $@

lib:		$(CMI) $(CMO)
		$(OCAMLC) -a $(CMO) -o $(NAME).cma

install:	lib $(CMI) $(CMX) $(CMO)
		$(OCAMLFIND) install $(NAME) META $(NAME).cma $(CMI) $(CMX) $(CMO)

uninstall:
		$(OCAMLFIND) remove $(NAME)

reinstall:	re uninstall install

doc:
		mkdir -p $(DOC_DIR)
		$(OCAMLDOC) $(MLI)

.SUFFIXES:	.ml .mli .cmo .cmi .cmx

%.cmx:		%.ml
		$(OCAMLOPT) -c $< -o $@

%.cmo:		%.ml
		$(OCAMLC) -c $< -o $@

%.cmi:		%.mli
		$(OCAMLC) -c $< -o $@

clean:
		@$(RM) *.cm[iox] *.o
		@$(RM) $(NAME) $(NAME).cma

.depend:
		$(OCAMLDEP) $(MLI) $(ML) > .depend

.PHONY:		doc

include .depend
