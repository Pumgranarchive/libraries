NAME :=		bfy

MLI :=		$(wildcard *.mli)
ML :=		$(wildcard *.ml)

PACKAGES :=	lwt,cohttp,cohttp.lwt,yojson,str

CMO :=		$(ML:.ml=.cmo)
CMI :=		$(MLI:.mli=.cmi)
LIB :=		-package $(PACKAGES)
SYNTAX :=	-syntax camlp4o -package lwt.syntax
OCAMLC :=	ocamlfind ocamlc $(SYNTAX) -linkpkg $(LIB)
OCAMLDEP :=	ocamlfind ocamldep $(SYNTAX) $(LIB)

RM := rm -fv

all:    	$(NAME)

$(NAME):	$(CMI) $(CMO)
		$(OCAMLC) -o $@

.SUFFIXES:	.ml .mli .cmo .cmi

.ml.cmo:
		$(OCAMLC) -c $<

.mli.cmi:
		$(OCAMLC) -c $<

clean:
		@$(RM) *.cm[io]
		@$(RM) $(NAME)

.depend:	$(ML)
		$(OCAMLDEP) $(MLI) $(ML) > .depend

include .depend