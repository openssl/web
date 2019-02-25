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
OLDSERIES2=1.0.1 1.0.0 0.9.x
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
	 docs/manpages.html \
         news/changelog.html \
	 $(foreach S,$(SERIES),news/openssl-$(S)-notes.inc) \
	 $(foreach S,$(SERIES),news/openssl-$(S)-notes.html) \
	 news/newsflash.inc \
	 news/vulnerabilities.inc \
	 news/vulnerabilities.html \
	 $(foreach S,$(SERIES) $(OLDSERIES),news/vulnerabilities-$(S).inc) \
	 $(foreach S,$(SERIES) $(OLDSERIES),news/vulnerabilities-$(S).html) \
	 source/.htaccess \
	 source/index.inc \
	 source/old/index.html
SRCLISTS = $(foreach S,$(SERIES) $(OLDSERIES2) fips,source/old/$(S)/index.inc source/old/$(S)/index.html)


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
	@rm -rf docs/man$(2)
	@mkdir -p docs/man$(2) \
		  docs/man$(2)/man1 \
		  docs/man$(2)/man3 \
		  docs/man$(2)/man5 \
		  docs/man$(2)/man7
	./bin/mk-manpages $(CHECKOUTS)/$(1)/doc $(2) docs/man$(2)
	./bin/mk-apropos docs/man$(2)/man1 > docs/man$(2)/man1/index.inc
	./bin/mk-apropos docs/man$(2)/man3 > docs/man$(2)/man3/index.inc
	./bin/mk-apropos docs/man$(2)/man5 > docs/man$(2)/man5/index.inc
	./bin/mk-apropos docs/man$(2)/man7 > docs/man$(2)/man7/index.inc
	./bin/from-tt -d docs/man$(2)/man1 releases='$(SERIES)' release='$(2)' \
		      < docs/sub-man1-index.html.tt > docs/man$(2)/man1/index.html
	./bin/from-tt -d docs/man$(2)/man1 releases='$(SERIES)' release='$(2)' \
		      < docs/sub-man3-index.html.tt > docs/man$(2)/man3/index.html
	./bin/from-tt -d docs/man$(2)/man1 releases='$(SERIES)' release='$(2)' \
		      < docs/sub-man5-index.html.tt > docs/man$(2)/man5/index.html
	./bin/from-tt -d docs/man$(2)/man1 releases='$(SERIES)' release='$(2)' \
		      < docs/sub-man7-index.html.tt > docs/man$(2)/man7/index.html
	./bin/from-tt -d docs/man$(2) releases='$(SERIES)' release='$(2)' \
		      < docs/sub-index.html.tt > docs/man$(2)/index.html
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

docs/manpages.html: docs/manpages.html.tt
	@rm -f $@
	./bin/from-tt releases='master $(SERIES)' docs/manpages.html.tt

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
news/changelog.html: news/changelog.html.tt news/changelog.inc
	@rm -f $@
	./bin/from-tt 'releases=$(SERIES)' $<
news/changelog.html: $(foreach S,$(SERIES),news/cl$(subst .,,$(S)).txt)

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
news/openssl-$(1)-notes.html: news/openssl-notes.html.tt
	@rm -f $$@
	./bin/from-tt -d news release='$(1)' < $$< > $$@
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
news/vulnerabilities$(1).html: news/vulnerabilities.html.tt bin/from-tt
	@rm -f $$@
	./bin/from-tt -d news vulnerabilitiesinc='vulnerabilities$(1).inc' < $$< > $$@
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
# $(1) = release, $(2) = release title
define mkoldsourceindex
source/old/$(1)/index.inc: $(wildcard $(RELEASEDIR)/old/$(1)/*.gz) bin/mk-filelist
	@rm -f $$@
	./bin/mk-filelist $(RELEASEDIR)/old/$(1) '' '*.gz' > $$@
source/old/$(1)/index.html: source/old/sub-index.html.tt bin/from-tt
	@rm -f $$@
	./bin/from-tt -d source/old/$(1) \
		      release='$(1)' releasetitle='Old $(2) Releases' \
		      < $$< > $$@
endef
$(foreach S,fips $(SERIES) $(OLDSERIES2),$(eval $(call mkoldsourceindex,$(S),$(patsubst fips,FIPS,$(S)))))
source/old/index.html: source/old/index.html.tt bin/from-tt
	@rm -f $@
	./bin/from-tt releases='fips $(SERIES) $(OLDSERIES2)' $<

# Because these the indexes of old tarballs will inevitably be newer
# than the tarballs that are moved into their respective directory,
# we must declare them phony, or they will not be regenerated when
# they should.
.PHONY : $(SRCLISTS)
