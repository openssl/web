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
	 community/committers.inc \
	 community/omc.inc community/omc-alumni.inc \
	 docs/faq.inc docs/fips.inc \
	 docs/OpenSSLStrategicArchitecture.html \
	 docs/OpenSSL300Design.html \
         news/changelog.inc news/changelog.txt \
         news/cl102.txt news/cl110.txt news/cl111.txt \
         news/openssl-1.0.2-notes.inc \
         news/openssl-1.1.0-notes.inc \
         news/openssl-1.1.1-notes.inc \
	 news/newsflash.inc \
	 news/vulnerabilities.inc \
	 news/vulnerabilities-1.1.1.inc \
	 news/vulnerabilities-1.1.0.inc \
	 news/vulnerabilities-1.0.2.inc \
	 news/vulnerabilities-1.0.1.inc \
	 news/vulnerabilities-1.0.0.inc \
	 news/vulnerabilities-0.9.8.inc \
	 news/vulnerabilities-0.9.7.inc \
	 news/vulnerabilities-0.9.6.inc \
	 source/.htaccess \
	 source/index.inc
SRCLISTS = \
	   source/old/0.9.x/index.inc \
	   source/old/1.0.0/index.inc \
	   source/old/1.0.1/index.inc \
	   source/old/1.0.2/index.inc \
	   source/old/1.1.0/index.inc \
	   source/old/1.1.1/index.inc \
	   source/old/fips/index.inc \


all: suball manmaster mancross

suball: $(SIMPLE) $(SRCLISTS)

relupd: suball manpages mancross

clean:
	rm -f $(SIMPLE) $(SRCLISTS)

# Legacy targets
hack-source_htaccess: all
simple: all
generated: all
rebuild: all

define makemanpages
	./bin/mk-manpages $(1)/doc $(2) docs/man$(2)
	./bin/mk-apropos docs/man$(2)/man1 > docs/man$(2)/man1/index.inc
	./bin/mk-apropos docs/man$(2)/man3 > docs/man$(2)/man3/index.inc
	./bin/mk-apropos docs/man$(2)/man5 > docs/man$(2)/man5/index.inc
	./bin/mk-apropos docs/man$(2)/man7 > docs/man$(2)/man7/index.inc
endef
define makemanmap
	./bin/mk-manmap docs/man$(1) > docs/man$(1)/.htaccess
endef
manpages: manmaster
	$(call makemanpages,$(CHECKOUTS)/openssl-1.1.1-stable,1.1.1)
	$(call makemanpages,$(CHECKOUTS)/openssl-1.1.0-stable,1.1.0)
	$(call makemanmap,1.1.0)
	$(call makemanpages,$(CHECKOUTS)/openssl-1.0.2-stable,1.0.2)
	$(call makemanmap,1.0.2)

manmaster:
	$(call makemanpages,$(CHECKOUTS)/openssl,master)

mancross:
	./bin/mk-mancross

## $(SIMPLE) -- SIMPLE GENERATED FILES
.PHONY: sitemap community/committers.inc community/omc.inc community/omc-alumni.inc
newsflash.inc: news/newsflash.inc
	@rm -f $@
	head -7 $? >$@
sitemap sitemap.txt:
	@rm -f sitemap.txt
	./bin/mk-sitemap > sitemap.txt

community/committers.inc:
	@rm -f $@
	wget -q https://api.openssl.org/0/Group/commit/Members
	./bin/mk-committers <Members >$@
	@rm -f Members

community/omc.inc:
	./bin/mk-omc -n -e -l -p -t 'OMC Members' omc omc-inactive > $@
community/omc-alumni.inc:
	./bin/mk-omc -n -l -t 'OMC Alumni' omc-alumni omc-emeritus > $@

docs/faq.inc: $(wildcard docs/faq-[0-9]-*.txt) bin/mk-faq
	@rm -f $@
	./bin/mk-faq docs/faq-[0-9]-*txt >$@
docs/fips.inc: $(wildcard docs/fips/*) bin/mk-filelist
	@rm -f $@
	./bin/mk-filelist docs/fips fips/ '*' >$@

docs/OpenSSLStrategicArchitecture.html: docs/OpenSSLStrategicArchitecture.md
	@rm -f $@
	./bin/md-to-html5 $<
docs/OpenSSL300Design.html: docs/OpenSSL300Design.md
	@rm -f $@
	./bin/md-to-html5 $<

news/changelog.inc: news/changelog.txt bin/mk-changelog
	@rm -f $@
	./bin/mk-changelog <news/changelog.txt >$@
news/changelog.txt: $(SNAP)/CHANGES
	@rm -f $@
	cp $? $@
news/cl102.txt: $(CHECKOUTS)/openssl-1.0.2-stable/CHANGES
	@rm -f $@
	cp $? $@
news/cl110.txt: $(CHECKOUTS)/openssl-1.1.0-stable/CHANGES
	@rm -f $@
	cp $? $@
news/cl111.txt: $(CHECKOUTS)/openssl-1.1.1-stable/CHANGES
	@rm -f $@
	cp $? $@
news/openssl-1.0.2-notes.html: news/openssl-notes.html.in
	@rm -f $@
	sed -e 's|@VERSION@|1.0.2|g' < $< > $@
news/openssl-1.1.0-notes.html: news/openssl-notes.html.in
	@rm -f $@
	sed -e 's|@VERSION@|1.1.0|g' < $< > $@
news/openssl-1.1.1-notes.html: news/openssl-notes.html.in
	@rm -f $@
	sed -e 's|@VERSION@|1.1.1|g' < $< > $@
news/openssl-1.0.2-notes.inc: $(CHECKOUTS)/openssl-1.0.2-stable/NEWS news/openssl-1.0.2-notes.html bin/mk-notes
	@rm -f $@
	./bin/mk-notes 1.0.2 < $(CHECKOUTS)/openssl-1.0.2-stable/NEWS > $@
news/openssl-1.1.0-notes.inc: $(CHECKOUTS)/openssl-1.1.0-stable/NEWS news/openssl-1.1.0-notes.html bin/mk-notes
	@rm -f $@
	./bin/mk-notes 1.1.0 < $(CHECKOUTS)/openssl-1.1.0-stable/NEWS > $@
news/openssl-1.1.1-notes.inc: $(CHECKOUTS)/openssl-1.1.1-stable/NEWS news/openssl-1.1.1-notes.html bin/mk-notes
	@rm -f $@
	./bin/mk-notes 1.1.1 < $(CHECKOUTS)/openssl-1.1.1-stable/NEWS > $@
news/newsflash.inc: news/newsflash.txt
	sed <$? >$@ \
	    -e '/^#/d' \
	    -e 's@^@<tr><td class="d">@' \
	    -e 's@: @</td><td class="t">@' \
	    -e 's@$$@</td></tr>@'
news/vulnerabilities.inc: bin/mk-cvepage news/vulnerabilities.xml
	@rm -f $@
	./bin/mk-cvepage -i news/vulnerabilities.xml > $@
news/vulnerabilities-1.1.1.inc: bin/mk-cvepage news/vulnerabilities.xml
	@rm -f $@
	./bin/mk-cvepage -i news/vulnerabilities.xml -b 1.1.1 > $@
news/vulnerabilities-1.1.0.inc: bin/mk-cvepage news/vulnerabilities.xml
	@rm -f $@
	./bin/mk-cvepage -i news/vulnerabilities.xml -b 1.1.0 > $@
news/vulnerabilities-1.0.2.inc: bin/mk-cvepage news/vulnerabilities.xml
	@rm -f $@
	./bin/mk-cvepage -i news/vulnerabilities.xml -b 1.0.2 > $@
news/vulnerabilities-1.0.1.inc: bin/mk-cvepage news/vulnerabilities.xml
	@rm -f $@
	./bin/mk-cvepage -i news/vulnerabilities.xml -b 1.0.1 > $@
news/vulnerabilities-1.0.0.inc: bin/mk-cvepage news/vulnerabilities.xml
	@rm -f $@
	./bin/mk-cvepage -i news/vulnerabilities.xml -b 1.0.0 > $@
news/vulnerabilities-0.9.8.inc: bin/mk-cvepage news/vulnerabilities.xml
	@rm -f $@
	./bin/mk-cvepage -i news/vulnerabilities.xml -b 0.9.8 > $@
news/vulnerabilities-0.9.7.inc: bin/mk-cvepage news/vulnerabilities.xml
	@rm -f $@
	./bin/mk-cvepage -i news/vulnerabilities.xml -b 0.9.7 > $@
news/vulnerabilities-0.9.6.inc: bin/mk-cvepage news/vulnerabilities.xml
	@rm -f $@
	./bin/mk-cvepage -i news/vulnerabilities.xml -b 0.9.6 > $@
source/.htaccess: $(wildcard source/openssl-*.tar.gz) bin/mk-latest
	@rm -f @?
	./bin/mk-latest source >$@
source/index.inc: $(wildcard $(RELEASEDIR)/openssl-*.tar.gz) bin/mk-filelist
	@rm -f $@
	./bin/mk-filelist $(RELEASEDIR) '' 'openssl-*.tar.gz' >$@

## $(SRCLISTS) -- LISTS OF SOURCES
source/old/0.9.x/index.inc: $(wildcard source/old/0.9.x/*.gz) bin/mk-filelist
	@rm -f $@
	./bin/mk-filelist source/old/0.9.x '' '*.gz' >$@
source/old/1.0.0/index.inc: $(wildcard source/old/1.0.0/*.gz) bin/mk-filelist
	@rm -f $@
	./bin/mk-filelist source/old/1.0.0 '' '*.gz' >$@
source/old/1.0.1/index.inc: $(wildcard source/old/1.0.1/*.gz) bin/mk-filelist
	@rm -f $@
	./bin/mk-filelist source/old/1.0.1 '' '*.gz' >$@
source/old/1.0.2/index.inc: $(wildcard source/old/1.0.2/*.gz) bin/mk-filelist
	@rm -f $@
	./bin/mk-filelist source/old/1.0.2 '' '*.gz' >$@
source/old/1.1.0/index.inc: $(wildcard source/old/1.1.0/*.gz) bin/mk-filelist
	@rm -f $@
	./bin/mk-filelist source/old/1.1.0 '' '*.gz' >$@
source/old/1.1.1/index.inc: $(wildcard source/old/1.1.1/*.gz) bin/mk-filelist
	@rm -f $@
	./bin/mk-filelist source/old/1.1.1 '' '*.gz' >$@
source/old/fips/index.inc: $(wildcard source/old/fips/*.gz) bin/mk-filelist
	@rm -f $@
	./bin/mk-filelist source/old/fips '' '*.gz' >$@

# Because these the indexes of old tarballs will inevitably be newer
# than the tarballs that are moved into their respective directory,
# we must declare them phony, or they will not be regenerated when
# they should.
.PHONY : \
	 source/old/1.0.1/index.inc source/old/1.0.2/index.inc \
	 source/old/1.1.0/index.inc source/old/1.1.1/index.inc \
	 source/old/fips/index.inc
