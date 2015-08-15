##
## Build procedure for www.openssl.org

##  Snapshot directory
SNAP = /var/cache/openssl/checkouts/openssl
RELEASEDIR = /var/www/openssl/source

# All simple generated files.
SIMPLE = newsflash.inc sitemap.txt \
	 docs/faq.txt docs/faq.inc docs/fips.inc \
	 news/changelog.inc news/changelog.txt \
	 news/newsflash.inc \
	 news/vulnerabilities.inc \
	 source/license.txt \
	 source/index.inc
SRCLISTS = source/old/index.inc \
	   source/old/0.9.x/index.inc \
	   source/old/1.0.0/index.inc \
	   source/old/1.0.1/index.inc \
	   source/old/1.0.2/index.inc \
	   source/old/fips/index.inc \

all: $(SIMPLE) $(SRCLISTS)

# Legacy targets
simple: all
generated: all
manpages: all
rebuild: all
relupd: all

# To be fixed.
hack-source_htaccess:
	exit 1;

clean:
	rm -f $(SIMPLE)

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

source/license.txt: $(SNAP)/LICENSE
	@rm -f $@
	cp $? $@
source/index.inc:
	@rm -f $@
	./bin/mk-filelist $(RELEASEDIR) '' 'openssl-*.tar.gz' >$@

source/old/0.9.x/index.inc:
	@rm -f $@
	./bin/mk-filelist source/old/0.9.8 '' '*.gz' >$@
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
