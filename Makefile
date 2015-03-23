##
##  Makefile -- Top-level build procedure for www.openssl.org
##

# Used to have a hack with a lockfile.
# Not needed since this is fast now.

SNAP=/var/cache/openssl/checkouts/openssl
PODSHOME=$(SNAP)/doc

FORCE=#-f
QUIET=--quiet

DIRS= about docs news source support

all: generated simple manpages

generated:
	cp -f $(SNAP)/LICENSE source/license.inc
	cp -f $(PODSHOME)/HOWTO/*.txt docs/HOWTO/.
	perl run-changelog.pl <$(SNAP)/CHANGES >news/changelog.inc
	perl run-faq.pl <$(SNAP)/FAQ >support/faq.inc
	perl run-fundingfaq.pl < support/funding/support-faq.txt >support/funding/support-faq.inc
	( cd news && xsltproc vulnerabilities.xsl vulnerabilities.xml > vulnerabilities.wml )

simple: rebuild hack-source_htaccess
rebuild:
	wmk $(FORCE) -I $(SNAP) -a $(DIRS) index.wml
hack-source_htaccess:
	latest=`grep '<span class="latest">' < source/index.html | \
		sed -e 's|^.*<span class="latest">||' -e 's|</span>.*$$||'`; \
	    sed -e "s|%%LATEST%%|$$latest|" \
		< source/.htaccess.in > source/.htaccess

manpages:
	sh ./run-pod2html.sh $(PODSHOME)

# Update release notes (and other items, but relnotes is the use-case)
relupd:
	if [ "`id -un`" != openssl; then \
		echo "**** you must do 'sudo -u openssl -H bash'"; \
		exit 1; \
	fi
	cd $(SNAP)/.. ; for dir in openssl* ; do \
		echo Updating $$dir ; ( cd $$dir ; git pull $(QUIET) ) ; \
	done
	git pull $(QUIET)
	$(MAKE) generated simple
