NAME :=		xtractor

JAR_NAME :=	simplextractor.jar
JAR_LIB :=	jar/$(JAR_NAME)

ML :=		xtractor.ml

MLI :=		xtractor.mli

PACKAGES :=	lwt,lwt.unix,cohttp,yojson

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

RM :=		rm -rfv

LIB_PATH :=	$(shell ocamlfind printconf | grep "lib" | head -n 2 | tail -n 1 | sed "s/ //g")
JAR_PATH :=	$(LIB_PATH)/$(NAME)/$(JAR_NAME)

all:		$(NAME) lib

re:		clean all

java/org.json-20120521.jar:
		wget "https://org-json-java.googlecode.com/files/org.json-20120521.jar"
		mv org.json-20120521.jar java/.

java/commons-io-2.4.jar:
		wget "http://apache.websitebeheerjd.nl//commons/io/binaries/commons-io-2.4-bin.tar.gz"
		tar -xf commons-io-2.4-bin.tar.gz
		cp commons-io-2.4/commons-io-2.4.jar java/.
		rm -rf commons-io-2.4 commons-io-2.4-bin.tar.gz

$(JAR_LIB):	java/org.json-20120521.jar java/commons-io-2.4.jar
		./setup.sh
		cp lib/xtractor/target/dependency/*.jar java/.
		cp lib/xtractor/target/*.jar java/.
		cd java && javac -extdirs . simplextractor/simplextractor.java
		mkdir -p jar
		cd java && jar cmf0 MANIFEST.MF ../$@ org/* simplextractor/simplextractor.class *.jar

$(NAME):	$(JAR_LIB) .depend $(CMI) $(CMO)
		$(OCAMLC) -linkpkg $(CMO) -o $@

lib:		$(JAR_LIB) .depend $(CMI) $(CMO)
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
		@$(RM) java/simplextractor/*.class
		@$(RM) $(NAME) $(NAME).cma jar lib java/*.jar

.depend:
		$(OCAMLDEP) $(MLI) $(ML) > .depend

.PHONY:		doc

include .depend
