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

SNAP=/v/openssl/checkouts/openssl
PODSHOME=$(SNAP)/doc
FORCE=#-f

DOCS = docs/HOWTO docs/index.wml

all: simple manpages

simple:
	perl run-changelog.pl <$(SNAP)/CHANGES >news/changelog.inc
	perl run-faq.pl <$(SNAP)/FAQ >support/faq.inc
	perl run-fundingfaq.pl < support/funding/support-faq.txt >support/funding/support-faq.inc
	cp $(PODSHOME)/HOWTO/*.txt docs/HOWTO/.
	wmk $(FORCE) -I $(SNAP) -a about news related source support $(DOCS) *.wml

manpages:
	sh ./run-pod2html.sh $(PODSHOME)
