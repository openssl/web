##
##  Makefile -- Top-level build procedure for www.openssl.org
##

lock-hack: FRC.lock-hack
	@pid=$$$$; \
	[ ! -f .lock_pid ] \
	|| [ -z "`cat .lock_pid`" ] \
	||(ps -ef | sed -e 's/[ 	][ 	]*/ /g' | \
	   awk "\$$2 == \"`cat .lock_pid`\"  { print \$$2; exit 1 }" > /dev/null) \
	&& (echo $$pid > .lock_pid; $(MAKE) all; rm .lock_pid) \
	|| echo "There's already a build going on.  Skipping"
FRC.lock-hack:

all: docs-depend docs HOWTOs
	@echo "[" `date` "] Recursive HTML Generation.... (be patient)"
	@wmk -a
	@# Because there's a conflict and wmk skips this one...
	@wmk docs/apps/openssl.wml
	@# Because we're dependent of other files
	@wmk -f source/index.wml contrib/index.wml docs/HOWTO/index.wml
	@wmk -f source/mirror.wml
	@echo "[" `date` "] Done"

PODSHOME=/e/openssl/exp/openssl/doc
HTMLGOAL=docs

FRC.docs :
docs : FRC.docs
	@echo "[" `date` "] Documentation WML Generation... (be patient)"
	@$(MAKE) -f Makefile.docs PODSHOME=$(PODSHOME) HTMLGOAL=$(HTMLGOAL)

FRC.docs-depend :
docs-depend : FRC.docs-depend
	@echo "[" `date` "] Documentation dependency Generation..."
	@find $(PODSHOME) -name '*.pod' -print | \
		PODSHOME=$(PODSHOME) HTMLGOAL=$(HTMLGOAL) ./make-docs-makefile.pl \
		> Makefile.docs

FRC.HOWTOs :
HOWTOs : FRC.HOWTOs
	cp $(PODSHOME)/HOWTO/*.txt $(HTMLGOAL)/HOWTO/
