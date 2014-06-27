NAME :=		bfy

MLI :=		$(wildcard *.mli)
ML :=		$(wildcard *.ml)

PACKAGES :=	lwt,cohttp,cohttp.lwt,yojson,str

CMO :=		$(ML:.ml=.cmo)
CMI :=		$(MLI:.mli=.cmi)
LIB :=		-package $(PACKAGES)
SYNTAX :=	-syntax camlp4o -package lwt.syntax
OCAMLFIND :=	ocamlfind
OCAMLC :=	$(OCAMLFIND) ocamlc $(SYNTAX) -linkpkg $(LIB)
OCAMLDEP :=	$(OCAMLFIND) ocamldep $(SYNTAX) $(LIB)

RM :=		rm -fv

all:		$(NAME) lib

$(NAME):	$(CMI) $(CMO)
		$(OCAMLC) -o $@

lib:		$(CMI) $(CMO)
		$(OCAMLC) -a $(CMI) $(CMO) -o $(NAME).cma

install:	lib
		$(OCAMLFIND) install $(NAME) META $(NAME).cma

uninstall:
		$(OCAMLFIND) remove $(NAME)

.SUFFIXES:	.ml .mli .cmo .cmi

.ml.cmo:
		$(OCAMLC) -c $<

.mli.cmi:
		$(OCAMLC) -c $<

clean:
		@$(RM) *.cm[io]
		@$(RM) $(NAME) $(NAME).cma

.depend:	$(ML)
		$(OCAMLDEP) $(MLI) $(ML) > .depend

include .depend