NAME :=		dbpedia

ML :=		dbpedia_query.ml	\
		rdf_http.ml		\
		dbpedia_record.ml	\
		dbpedia_http.ml

ML_EXEC :=	$(ML)			\
		bot.ml

MLI :=		dbpedia_record.mli	\
		dbpedia_query.mli	\
		dbpedia_http.mli	\
		rdf_http.mli


PACKAGES :=	lwt,cohttp,cohttp.lwt,rdf,rdf.lwt,urlnorm,ptools

CMX :=		$(ML_EXEC:.ml=.cmx)
CMO :=		$(ML:.ml=.cmo)
CMO_EXEC :=	$(ML_EXEC:.ml=.cmo)
CMI :=		$(MLI:.mli=.cmi)
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

$(NAME):	.depend $(CMI) $(CMO_EXEC)
		$(OCAMLC) -linkpkg $(CMO_EXEC) -o $@


lib:		.depend $(CMI) $(CMO)
		$(OCAMLC) -a $(CMO) -o $(NAME).cma

install:	$(CMI) $(CMX) $(CMO) lib
		$(OCAMLFIND) install $(NAME) META $(NAME).cma $(CMI) $(CMX) $(CMO)

uninstall:
		$(OCAMLFIND) remove $(NAME)

reinstall:	re uninstall install

doc:
		mkdir -p $(DOC_DIR)
		$(OCAMLDOC) $(MLI)

.SUFFIXES:	.ml .mli .cmo .cmi .cmx


dbpedia_record.ml:	dbpedia_record.template dbpedia_record.model
			./dbpedia_record_generator.sh

dbpedia_record.cmx:	dbpedia_record.ml
			$(OCAMLOPT) -c dbpedia_record.ml

dbpedia_record.cmo:	dbpedia_record.ml
			$(OCAMLC) -c dbpedia_record.ml

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

.PHONY:		doc

include .depend
