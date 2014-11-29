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

PODSHOME=/v/openssl/checkouts/openssl/doc
HTMLGOAL=docs

all: simple docs-depend docs
	@wmk -I $(PODSHOME)/.. -a
	@# Because there's a conflict and wmk skips this one...
	@wmk docs/apps/openssl.wml
	@# Because we're dependent of other files
	@wmk -f news/openssl-*notes.wml
	@wmk -f news/index.wml
	@echo "[" `date` "] Done"

simple:
	cp $(PODSHOME)/HOWTO/*.txt docs/HOWTO/.
	wmk -I $(PODSHOME)/.. -a about news related source support docs/HOWTO *.wml

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
