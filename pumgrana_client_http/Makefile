VPATH =		../pumgrana_common_http

NAME :=		pumgrana_client_http

ML :=		$(VPATH)/ph_conf.ml	\
		$(VPATH)/ph_utils.ml	\
		$(VPATH)/pumgrana_http.ml

MLI :=		$(VPATH)/pumgrana_http.mli


PACKAGES :=	lwt,cohttp,cohttp.lwt,yojson,pctools

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
		$(OCAMLC) -linkpkg $(patsubst $(VPATH)/%,%,$(CMO)) -o $@

lib:		$(CMI) $(CMO)
		$(OCAMLC) -a $(patsubst $(VPATH)/%,%,$(CMO)) -o $(NAME).cma

install:	lib $(CMI) $(CMX) $(CMO)
		$(OCAMLFIND) install $(NAME) META $(NAME).cma $(patsubst $(VPATH)/%,%,$(CMI)) $(patsubst $(VPATH)/%,%,$(CMX)) $(patsubst $(VPATH)/%,%,$(CMO))

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
