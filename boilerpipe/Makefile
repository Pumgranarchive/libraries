NAME :=		boilerpipe

JAR_NAME :=	simpleboilerpipe.jar
JAR_LIB :=	jar/$(JAR_NAME)

ML :=		boilerpipe.ml

MLI :=		boilerpipe.mli

PACKAGES :=	lwt,lwt.unix,cohttp

CMX :=		$(ML:.ml=.cmx)
CMO :=		$(ML:.ml=.cmo)
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

LIB_PATH :=	$(shell ocamlfind printconf | grep "lib" | head -n 2 | tail -n 1 | sed "s/ //g")
JAR_PATH :=	$(LIB_PATH)/$(NAME)/$(JAR_NAME)

all:		$(NAME) lib

re:		clean all

$(JAR_LIB):
		cp jar/boilerpipe.jar java/.
		cd java && javac -extdirs ../jar/ simpleboilerpipe/simpleboilerpipe.java
		cd java && jar cmf0 MANIFEST.MF ../$@ simpleboilerpipe/simpleboilerpipe.class org/* boilerpipe.jar
		rm java/boilerpipe.jar

$(NAME):	$(JAR_LIB) .depend $(CMI) $(CMO)
		$(OCAMLC) -linkpkg $(CMO) -o $@

lib:		.depend $(CMI) $(CMO)
		$(OCAMLC) -a $(CMO) -o $(NAME).cma

install:	$(CMI) $(CMX) $(CMO) lib
		$(OCAMLFIND) install $(NAME) META $(NAME).cma $(CMI) $(CMX) $(CMO) $(JAR_LIB)

uninstall:
		$(OCAMLFIND) remove $(NAME)

reinstall:	re uninstall install

doc:
		mkdir -p $(DOC_DIR)
		$(OCAMLDOC) $(MLI)

.SUFFIXES:	.ml .mli .cmo .cmi .cmx

.ml.cmx:
		sed "s\%%JAR_PATH%%\$(JAR_PATH)\g" $< > $<.tmp
		mv $< $<.2 && mv $<.tmp $<
		$(OCAMLOPT) -c $<
		mv $<.2 $<

.ml.cmo:
		sed "s\%%JAR_PATH%%\$(JAR_PATH)\g" $< > $<.tmp
		mv $< $<.2 && mv $<.tmp $<
		$(OCAMLC) -c $<
		mv $<.2 $<

.mli.cmi:
		sed "s\%%JAR_PATH%%\$(JAR_PATH)\g" $< > $<.tmp
		mv $< $<.2 && mv $<.tmp $<
		$(OCAMLC) -c $<
		mv $<.2 $<

clean:
		@$(RM) *.cm[iox] *.o *.tmp
		@$(RM) $(NAME) $(NAME).cma

.depend:
		$(OCAMLDEP) $(MLI) $(ML) > .depend

.PHONY:		doc

include .depend
