##
## Build procedure for www.openssl.org

##  Snapshot directory
SNAP = /var/cache/openssl/checkouts/openssl
## Where releases are found.
RELEASEDIR = /var/www/openssl/source


# All simple generated files.
SIMPLE = newsflash.inc sitemap.txt \
	 docs/faq.txt docs/faq.inc docs/fips.inc \
	 news/changelog.inc news/changelog.txt \
	 news/newsflash.inc \
	 news/vulnerabilities.inc \
	 source/.htaccess \
	 source/license.txt \
	 source/index.inc
SRCLISTS = \
	   source/old/0.9.x/index.inc \
	   source/old/1.0.0/index.inc \
	   source/old/1.0.1/index.inc \
	   source/old/1.0.2/index.inc \
	   source/old/fips/index.inc \

all: $(SIMPLE) $(SRCLISTS)

relupd: all
	if [ "`id -un`" != openssl ]; then \
	    echo "You must run this as 'openssl'" ; \
	    echo "     sudo -u openssl -H make"; \
	    exit 1; \
	fi
	cd $(SNAP)/.. ; for dir in openssl* ; do \
	    echo Updating $$dir ; ( cd $$dir ; git pull $(QUIET) ) ; \
	done
	git pull $(QUIET)
	$(MAKE)

# Legacy targets
hack-source_htaccess: all
simple: all
generated: all
manpages: all
rebuild: all

clean:
	rm -f $(SIMPLE) $(SRCLISTS)

newsflash.inc: news/newsflash.inc
	@rm -f $@
	head -6 $? >$@
sitemap.txt:
	@rm -f $@
	./bin/mk-sitemap >$@

news/changelog.inc: news/changelog.txt bin/mk-changelog
	@rm -f $@
	./bin/mk-changelog <news/changelog.txt >$@
news/changelog.txt: $(SNAP)/CHANGES
	@rm -f $@
	cp $? $@
news/newsflash.inc: news/newsflash.txt
	sed <$? >$@ \
	    -e 's@^@<tr><td class="d">@' \
	    -e 's@: @</td><td class="t">@' \
	    -e 's@$$@</td></tr>@'
news/vulnerabilities.inc: bin/vulnerabilities.xsl news/vulnerabilities.xml
	@rm -f $@
	xsltproc bin/vulnerabilities.xsl news/vulnerabilities.xml >$@

docs/faq.txt: $(SNAP)/FAQ
	@rm -f $@
	cp $? $@
docs/faq.inc: docs/faq.txt
	@rm -f $@
	./bin/mk-faq <$? >$@
docs/fips.inc:
	@rm -f $@
	./bin/mk-filelist docs/fips fips/ '*' >$@

source/.htaccess:
	@rm -f @?
	./bin/mk-latest source >$@
source/license.txt: $(SNAP)/LICENSE
	@rm -f $@
	cp $? $@
source/index.inc:
	@rm -f $@
	./bin/mk-filelist $(RELEASEDIR) '' 'openssl-*.tar.gz' >$@

source/old/0.9.x/index.inc:
	@rm -f $@
	./bin/mk-filelist source/old/0.9.x '' '*.gz' >$@
source/old/1.0.0/index.inc:
	@rm -f $@
	./bin/mk-filelist source/old/1.0.0 '' '*.gz' >$@
source/old/1.0.1/index.inc:
	@rm -f $@
	./bin/mk-filelist source/old/1.0.1 '' '*.gz' >$@
source/old/1.0.2/index.inc:
	@rm -f $@
	./bin/mk-filelist source/old/1.0.2 '' '*.gz' >$@
source/old/fips/index.inc:
	@rm -f $@
	./bin/mk-filelist source/old/fips '' '*.gz' >$@
