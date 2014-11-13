DIRECTORIES :=	pumgrana_tools		\
		pumgrana_client_tools	\
		pumgrana_http		\
		pumgrana_client_http	\
		readability_http	\
		freebase_youtube	\
		dbpedia			\
		tidy

DOC_DIR :=	doc/html

one_all = for dir in $(DIRECTORIES) ; do $(1) $$dir ; done
cp_all = for dir in $(DIRECTORIES) ; do 		\
		mkdir -p $(DOC_DIR)/$$dir/;		\
		cp $$dir/doc/html/* $(DOC_DIR)/$$dir/.;	\
	 done


all:
	$(call one_all,$(MAKE) -C)

re:
	$(call one_all,$(MAKE) re -C)

clean:
	$(call one_all,$(MAKE) clean -C)

install:
	$(call one_all,$(MAKE) install -C)

uninstall:
	$(call one_all,$(MAKE) uninstall -C)

reinstall:
	$(call one_all,$(MAKE) reinstall -C)

doc:
	$(call one_all,$(MAKE) doc -C)
	$(call cp_all)

.PHONY: doc