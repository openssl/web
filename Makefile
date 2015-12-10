##
## Build procedure for www.openssl.org

##  Checkouts.
CHECKOUTS = /var/cache/openssl/checkouts
##  Snapshot directory
SNAP = $(CHECKOUTS)/openssl
## Where releases are found.
RELEASEDIR = /var/www/openssl/source


# All simple generated files.
SIMPLE = newsflash.inc sitemap.txt \
	 docs/faq.inc docs/fips.inc \
	 news/changelog.inc news/changelog.txt \
	 news/cl098.txt news/cl100.txt news/cl101.txt news/cl102.txt \
	 news/openssl-0.9.8-notes.inc news/openssl-1.0.0-notes.inc \
	 news/openssl-1.0.1-notes.inc news/openssl-1.0.2-notes.inc \
	 news/openssl-1.1.0-notes.inc \
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

all: $(SIMPLE) $(SRCLISTS) manmaster

relupd: all
	if [ "`id -un`" != openssl ]; then \
	    echo "You must run this as 'openssl'" ; \
	    echo "     sudo -u openssl -H make"; \
	    exit 1; \
	fi
	cd $(CHECKOUTS) ; for dir in openssl* ; do \
	    echo Updating $$dir ; ( cd $$dir ; git pull $(QUIET) ) ; \
	done
	git pull $(QUIET)
	$(MAKE) all manpages

define makemanpages
	./bin/mk-manpages $(1) $(2) docs
	./bin/mk-filelist -a docs/man$(2)/apps '' '*.html' >docs/man$(2)/apps/index.inc
	./bin/mk-filelist -a docs/man$(2)/crypto '' '*.html' >docs/man$(2)/crypto/index.inc
	./bin/mk-filelist -a docs/man$(2)/ssl '' '*.html' >docs/man$(2)/ssl/index.inc
endef
manpages: manmaster
	$(call makemanpages,$(CHECKOUTS)/openssl-1.0.2-stable,1.0.2)
	$(call makemanpages,$(CHECKOUTS)/openssl-1.0.1-stable,1.0.1)
	$(call makemanpages,$(CHECKOUTS)/openssl-1.0.0-stable,1.0.0)
	$(call makemanpages,$(CHECKOUTS)/openssl-0.9.8-stable,0.9.8)

manmaster:
	$(call makemanpages,$(CHECKOUTS)/openssl,master)

# Legacy targets
hack-source_htaccess: all
simple: all
generated: all
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
news/cl098.txt: $(CHECKOUTS)/openssl-0.9.8-stable/CHANGES
	@rm -f $@
	cp $? $@
news/cl100.txt: $(CHECKOUTS)/openssl-1.0.0-stable/CHANGES
	@rm -f $@
	cp $? $@
news/cl101.txt: $(CHECKOUTS)/openssl-1.0.1-stable/CHANGES
	@rm -f $@
	cp $? $@
news/cl102.txt: $(CHECKOUTS)/openssl-1.0.2-stable/CHANGES
	@rm -f $@
	cp $? $@

news/openssl-0.9.8-notes.html: news/openssl-notes.html.in
	@rm -f $@
	sed -e 's|@VERSION@|0.9.8|g' < $< > $@
news/openssl-1.0.0-notes.html: news/openssl-notes.html.in
	@rm -f $@
	sed -e 's|@VERSION@|1.0.0|g' < $< > $@
news/openssl-1.0.1-notes.html: news/openssl-notes.html.in
	@rm -f $@
	sed -e 's|@VERSION@|1.0.1|g' < $< > $@
news/openssl-1.0.2-notes.html: news/openssl-notes.html.in
	@rm -f $@
	sed -e 's|@VERSION@|1.0.2|g' < $< > $@
news/openssl-1.1.0-notes.html: news/openssl-notes.html.in
	@rm -f $@
	sed -e 's|@VERSION@|1.1.0|g' < $< > $@
news/openssl-0.9.8-notes.inc: $(CHECKOUTS)/openssl-0.9.8-stable/NEWS news/openssl-0.9.8-notes.html
	@rm -f $@
	./bin/mk-notes 0.9.8 < $(CHECKOUTS)/openssl-0.9.8-stable/NEWS > $@
news/openssl-1.0.0-notes.inc: $(CHECKOUTS)/openssl-1.0.0-stable/NEWS news/openssl-1.0.0-notes.html
	@rm -f $@
	./bin/mk-notes 1.0.0 < $(CHECKOUTS)/openssl-1.0.0-stable/NEWS > $@
news/openssl-1.0.1-notes.inc: $(CHECKOUTS)/openssl-1.0.1-stable/NEWS news/openssl-1.0.1-notes.html
	@rm -f $@
	./bin/mk-notes 1.0.1 < $(CHECKOUTS)/openssl-1.0.1-stable/NEWS > $@
news/openssl-1.0.2-notes.inc: $(CHECKOUTS)/openssl-1.0.2-stable/NEWS news/openssl-1.0.2-notes.html
	@rm -f $@
	./bin/mk-notes 1.0.2 < $(CHECKOUTS)/openssl-1.0.2-stable/NEWS > $@
news/openssl-1.1.0-notes.inc: $(CHECKOUTS)/master/NEWS news/openssl-1.1.0-notes.html
	@rm -f $@
	./bin/mk-notes 1.1.0 < $(CHECKOUTS)/master/NEWS > $@

news/newsflash.inc: news/newsflash.txt
	sed <$? >$@ \
	    -e '/^#/d' \
	    -e 's@^@<tr><td class="d">@' \
	    -e 's@: @</td><td class="t">@' \
	    -e 's@$$@</td></tr>@'
news/vulnerabilities.inc: bin/vulnerabilities.xsl news/vulnerabilities.xml
	@rm -f $@
	xsltproc bin/vulnerabilities.xsl news/vulnerabilities.xml >$@

docs/faq.inc: docs/faq.txt
	@rm -f $@
	./bin/mk-faq <$? >$@
docs/fips.inc: $(wildcard docs/fips/*)
	@rm -f $@
	./bin/mk-filelist docs/fips fips/ '*' >$@

source/.htaccess: $(wildcard source/openssl-*.tar.gz)
	@rm -f @?
	./bin/mk-latest source >$@
source/license.txt: $(SNAP)/LICENSE
	@rm -f $@
	cp $? $@
source/index.inc: $(wildcard $(RELEASEDIR)/openssl-*.tar.gz)
	@rm -f $@
	./bin/mk-filelist -a $(RELEASEDIR) '' 'openssl-*.tar.gz' >$@

source/old/0.9.x/index.inc: $(wildcard source/old/0.9.x/*.gz)
	@rm -f $@
	./bin/mk-filelist source/old/0.9.x '' '*.gz' >$@
source/old/1.0.0/index.inc: $(wildcard source/old/1.0.0/*.gz)
	@rm -f $@
	./bin/mk-filelist source/old/1.0.0 '' '*.gz' >$@
source/old/1.0.1/index.inc: $(wildcard source/old/1.0.1/*.gz)
	@rm -f $@
	./bin/mk-filelist source/old/1.0.1 '' '*.gz' >$@
source/old/1.0.2/index.inc: $(wildcard source/old/1.0.2/*.gz)
	@rm -f $@
	./bin/mk-filelist source/old/1.0.2 '' '*.gz' >$@
source/old/fips/index.inc: $(wildcard source/old/fips/*.gz)
	@rm -f $@
	./bin/mk-filelist source/old/fips '' '*.gz' >$@

# Because these the indexes of old tarballs will inevitably be newer
# than the tarballs that are moved into their respective directory,
# we must declare them phony, or they will not be regenerated when
# they should.
.PHONY : source/old/0.9.x/index.inc source/old/1.0.0/index.inc \
	 source/old/1.0.1/index.inc source/old/1.0.2/index.inc \
	 source/old/fips/index.inc
