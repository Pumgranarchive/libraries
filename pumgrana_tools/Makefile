VPATH =		../pumgrana_common_tools

NAME :=		ptools

ML :=		pjson.ml		\
		ptype.ml		\
		ptools.ml		\
		pdeserialize.ml

MLI :=		$(VPATH)/pjson.mli		\
		$(VPATH)/ptype.mli


PACKAGES :=	cohttp,str,yojson,urlnorm,netstring

CMX :=		$(ML:.ml=.cmx)
CMO :=		$(ML:.ml=.cmo)
CMI :=		$(MLI:.mli=.cmi)
ALL_CMI :=	$(ML:.ml=.cmi)
LIB :=		-package $(PACKAGES)
SYNTAX :=	-syntax camlp4o -package lwt.syntax
DOC_DIR :=	doc/html/
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

install:	$(CMI) $(CMX) $(CMO) lib
		$(OCAMLFIND) install $(NAME) META $(NAME).cma $(ALL_CMI) $(CMX) $(CMO)

uninstall:
		$(OCAMLFIND) remove $(NAME)

reinstall:	re uninstall install

doc:
		mkdir -p $(DOC_DIR)
		$(OCAMLDOC) $(MLI)

.SUFFIXES:	.ml .mli .cmo .cmi .cmx

%.cmx:		%.ml
		$(OCAMLOPT) -c $< -o $(patsubst $(VPATH)/%,%,$@)

%.cmo:		%.ml
		$(OCAMLC) -c $< -o $(patsubst $(VPATH)/%,%,$@)

%.cmi:		%.mli
		$(OCAMLC) -c $< -o $(patsubst $(VPATH)/%,%,$@)

clean:
		@$(RM) *.cm[iox] *.o
		@$(RM) $(NAME) $(NAME).cma

# .depend:
# 		$(OCAMLDEP) $(MLI) $(ML) > .depend

.PHONY:		doc

# include .depend
