##
##  Makefile -- Top-level build procedure for www.openssl.org
##

all: docs-depend docs
	@echo "Recursive HTML Generation.... (be patient)"
	@wmk -a
	@# Because there's a conflict and wmk skips this one...
	@wmk docs/apps/openssl.wml

PODSHOME=/e/openssl/exp/openssl/doc
HTMLGOAL=docs

FRC.docs :
docs : FRC.docs
	@echo "Documentation WML Generation... (be patient)"
	@$(MAKE) -f Makefile.docs PODSHOME=$(PODSHOME) HTMLGOAL=$(HTMLGOAL)

FRC.docs-depend :
docs-depend : FRC.docs-depend
	@echo "Documentation dependency Generation..."
	@find $(PODSHOME) -name '*.pod' -print | \
		PODSHOME=$(PODSHOME) HTMLGOAL=$(HTMLGOAL) ./make-docs-makefile.pl \
		> Makefile.docs
