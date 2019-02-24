##
## Build procedure for www.openssl.org

##  Checkouts.
CHECKOUTS = /var/cache/openssl/checkouts
##  Snapshot directory
SNAP = $(CHECKOUTS)/openssl
## Where releases are found.
RELEASEDIR = /var/www/openssl/source

##  Current series
SERIES=1.1.1 1.1.0 1.0.2
##  Older series
OLDSERIES=1.0.1 1.0.0 0.9.8 0.9.7 0.9.6
##  Current series with newer and older manpage layout
##  (when the number of old man layout releases drop to none, this goes away)
NEWMANSERIES=1.1.1
OLDMANSERIES=1.1.0 1.0.2

# All simple generated files.
SIMPLE = newsflash.inc sitemap.txt \
	 community/committers.inc \
	 community/omc.inc community/omc-alumni.inc \
	 docs/faq.inc docs/fips.inc \
	 docs/OpenSSLStrategicArchitecture.html \
	 docs/OpenSSL300Design.html \
         news/changelog.inc news/changelog.txt \
	 $(foreach S,$(SERIES),news/cl$(subst .,,$(S)).txt) \
	 $(foreach S,$(SERIES),news/openssl-$(S)-notes.inc) \
	 $(foreach S,$(SERIES),news/openssl-$(S)-notes.html) \
	 news/newsflash.inc \
	 news/vulnerabilities.inc \
	 $(foreach S,$(SERIES) $(OLDSERIES),news/vulnerabilities-$(S).inc) \
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


.SUFFIXES: .md .html

.md.html:
	@rm -f $@
	./bin/md-to-html5 $<

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

# $(1) = input directory in CHECKOUTS, $(2) = release version
define makemanpages
manpages-$(2):
	./bin/mk-manpages $(CHECKOUTS)/$(1)/doc $(2) docs/man$(2)
	./bin/mk-apropos docs/man$(2)/man1 > docs/man$(2)/man1/index.inc
	./bin/mk-apropos docs/man$(2)/man3 > docs/man$(2)/man3/index.inc
	./bin/mk-apropos docs/man$(2)/man5 > docs/man$(2)/man5/index.inc
	./bin/mk-apropos docs/man$(2)/man7 > docs/man$(2)/man7/index.inc
endef
# $(1) = release version
define makeoldmanmap
manmap-$(1):
	./bin/mk-manmap docs/man$(1) > docs/man$(1)/.htaccess
endef

$(eval $(call makemanpages,openssl,master))
$(foreach S,$(SERIES),$(eval $(call makemanpages,openssl-$(S)-stable,$(S))))
$(foreach S,$(OLDMANSERIES),$(eval $(call makeoldmanmap,$(S))))

manmaster: manpages-master
manpages: $(foreach S,$(NEWMANSERIES),manpages-$(S)) \
	  $(foreach S,$(OLDMANSERIES),manpages-$(S) manmap-$(S))

mancross:
	./bin/mk-mancross master $(SERIES)


## $(SIMPLE) -- SIMPLE GENERATED FILES
.PHONY: sitemap community/committers.inc community/omc.inc community/omc-alumni.inc
newsflash.inc: news/newsflash.inc
	@rm -f $@
	head -7 $? >$@
sitemap sitemap.txt:
	@rm -f sitemap.txt
	./bin/mk-sitemap master $(SERIES) > sitemap.txt

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

news/changelog.inc: news/changelog.txt bin/mk-changelog
	@rm -f $@
	./bin/mk-changelog <news/changelog.txt >$@

# $(1) = output file, $(2) = source directory in CHECKOUTS
define mknews_changelogtxt
news/$(1): $(CHECKOUTS)/$(2)/CHANGES
	@rm -f $$@
	cp $$? $$@
endef
$(eval $(call mknews_changelogtxt,changelog.txt,openssl))
$(foreach S,$(SERIES),\
$(eval $(call mknews_changelogtxt,cl$(subst .,,$(S)).txt,openssl-$(S)-stable)))

# $(1) = release version
define mknews_noteshtml
news/openssl-$(1)-notes.html: news/openssl-notes.html.in
	@rm -f $$@
	sed -e 's|@VERSION@|$(1)|g' < $$< > $$@
news/openssl-$(1)-notes.inc: $(CHECKOUTS)/openssl-$(1)-stable/NEWS bin/mk-notes
	@rm -f $$@
	./bin/mk-notes $(1) < $(CHECKOUTS)/openssl-$(1)-stable/NEWS > $$@
endef
$(foreach S,$(SERIES),$(eval $(call mknews_noteshtml,$(S))))

news/newsflash.inc: news/newsflash.txt
	sed <$? >$@ \
	    -e '/^#/d' \
	    -e 's@^@<tr><td class="d">@' \
	    -e 's@: @</td><td class="t">@' \
	    -e 's@$$@</td></tr>@'

# $(1) = output file mod, $(2) = release version switch, $(3) = release version
define mknews_vulnerability
news/vulnerabilities$(1).inc: bin/mk-cvepage news/vulnerabilities.xml
	@rm -f $$@
	./bin/mk-cvepage -i news/vulnerabilities.xml $(2) > $$@
endef
$(eval $(call mknews_vulnerability,,))
$(foreach S,$(SERIES) $(OLDSERIES),$(eval $(call mknews_vulnerability,-$(S),-b $(S))))

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
