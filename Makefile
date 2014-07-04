DIRECTORIES :=	pumgrana_client_tools	\
		pumgrana_tools		\
		pumgrana_api		\
		readability		\
		freebase_youtube	\
		tidy

one_all = for dir in $(DIRECTORIES) ; do $(1) $$dir ; done

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