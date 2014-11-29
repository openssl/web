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

DOCS = docs/HOWTO docs/index.wml
all:
	cp $(PODSHOME)/HOWTO/*.txt docs/HOWTO/.
	wmk -I $(PODSHOME)/.. -a about news related source support $(DOCS) *.wml
	sh ./run-pod2html.sh $(PODSHOME)
