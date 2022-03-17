##
## Build procedure for www.openssl.org

##  Checkouts.
CHECKOUTS = /var/cache/openssl/checkouts
##  Snapshot directory
SNAP = $(CHECKOUTS)/openssl
## Where releases are found.
RELEASEDIR = /srv/ftp/source

## The OMC repository checkout can be used for dependencies.
## By default, we don't assume it, as not everyone has access to it.
## If you have it, do 'make PERSONDB=PATH/TO/omc/persondb.yaml' where
## PATH/TO/omc is the checked out OMC repository.
## We let it be FORCE by default...  This forces the production of files
## that depend on this database, instead of just conditionally.
PERSONDB=FORCE

######################################################################
##
##  Release series.  These represent our release branches, and are
##  our foundation for what should be built and how (often generated)
##
##  The numbers given here RULE
##

##  Current series.  Variable names are numbered to indicate:
##
##  SERIES1	OpenSSL pre-3.0
##  SERIES3	OpenSSL 3.0 and on
##  SERIES	The concatenation of the above, for ease of use
##
##  We mostly use $(SERIES) further down, but there are places where we
##  need to make the distinction, because certain files are produced
##  differently.
SERIES1=1.1.1
SERIES3=3.0
SERIES=$(SERIES3) $(SERIES1)
##  Older series.  The second type is for source listings
OLDSERIES=1.1.0 1.0.2 1.0.1 1.0.0 0.9.8 0.9.7 0.9.6
OLDSERIES2=1.1.0 1.0.2 1.0.1 1.0.0 0.9.x
##  Series for manual layouts, named similar to SERIES1, SERIES3, SERIES
MANSERIES1=1.1.1 1.0.2
MANSERIES3=3.0
MANSERIES=$(MANSERIES3) $(MANSERIES1)

##  Future series, i.e. a series that hasn't had any final release yet.
##  This would typically be a major or minor version that's still only
##  on the master branch, but that has come far enough for us to start
##  to make alpha and beta releases.
##  We distinguish them to avoid having to produce notes, vulnerability
##  documents, ... but still being able to present tarballs.
FUTURESERIES=

# All simple generated files.
SIMPLE = newsflash.inc \
	 community/committers.inc community/otc.inc \
	 community/omc.inc community/omc-alumni.inc \
	 roadmap.html \
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
SRCLISTS = $(foreach S,$(FUTURESERIES) $(SERIES) $(OLDSERIES2) fips,source/old/$(S)/index.inc source/old/$(S)/index.html)

SIMPLEDOCS = docs/faq.inc docs/fips.inc \
	     docs/OpenSSLStrategicArchitecture.html \
	     docs/OpenSSL300Design.html \
	     docs/manpages.html \
	     docs/mansidebar.html

.SUFFIXES: .md .html

.md.html:
	@rm -f $@
	./bin/md-to-html5 $<

all: suball docs sitemap akamai-purge

suball: $(SIMPLE) $(SRCLISTS)

relupd: suball docs sitemap akamai-purge

docs: subdocs manpages mancross

subdocs: $(SIMPLEDOCS)

clean:
	rm -f $(SIMPLE) $(SIMPLEDOCS) $(SRCLISTS)

akamai-purge:
	./bin/purge-one-hour

# Legacy targets
hack-source_htaccess: all
simple: all
generated: all
rebuild: all

######################################################################
##
##  Man-page building section
##
##  This is quite a complex set of rules, because there are many
##  things that need to be built:
##
##  -   The man-pages themselves
##  -   Apropos-like listings
##  -   Cross-references between man-pages in different OpenSSL
##      versions
##
##  A lot of the work is made with generated rules.

# makemanpages1 and makemanpages3 creates rules for targets like man-pages-1.1.1,
# to build the set of man-pages.  makemanpages1 is used for pre-3.0 OpenSSL,
# while makemanpages3 is used for OpenSSL 3.0 and on.
# makemanapropos creates rules for targets like man-apropos-1.1.1, to build
# 'apropos' like indexes for all the manpages.
# makemanindexes creates rules for targets like man-index-1.1.1, to build the
# main HTML index for a set of man-pages.
#
# $(1) = input directory in CHECKOUTS, $(2) = release version

# This variant is for pre-3.0 documentation
define makemanpages1
man-pages-$(2):
	@rm -rf docs/man$(2)
	@mkdir -p docs/man$(2) \
		  docs/man$(2)/man1 \
		  docs/man$(2)/man3 \
		  docs/man$(2)/man5 \
		  docs/man$(2)/man7
	./bin/mk-manpages $(CHECKOUTS)/$(1)/doc $(2) docs/man$(2)
endef
# This variant is for 3.0 documentation
define makemanpages3
man-pages-$(2):
	@rm -rf docs/man$(2)
	@mkdir -p docs/man$(2) \
		  docs/man$(2)/man1 \
		  docs/man$(2)/man3 \
		  docs/man$(2)/man5 \
		  docs/man$(2)/man7
	./bin/mk-manpages3 $(CHECKOUTS)/$(1) $(2) docs/man$(2)
endef
define makemanapropos
man-apropos-$(2): man-pages-$(2)
	./bin/mk-apropos docs/man$(2)/man1 > docs/man$(2)/man1/index.inc
	./bin/mk-apropos docs/man$(2)/man3 > docs/man$(2)/man3/index.inc
	./bin/mk-apropos docs/man$(2)/man5 > docs/man$(2)/man5/index.inc
	./bin/mk-apropos docs/man$(2)/man7 > docs/man$(2)/man7/index.inc
endef
define makemanindexes
man-index-$(2):
	./bin/from-tt -d docs/man$(2)/man1 releases='$(MANSERIES)' release='$(2)' \
		      < docs/sub-man1-index.html.tt > docs/man$(2)/man1/index.html
	./bin/from-tt -d docs/man$(2)/man3 releases='$(MANSERIES)' release='$(2)' \
		      < docs/sub-man3-index.html.tt > docs/man$(2)/man3/index.html
	./bin/from-tt -d docs/man$(2)/man5 releases='$(MANSERIES)' release='$(2)' \
		      < docs/sub-man5-index.html.tt > docs/man$(2)/man5/index.html
	./bin/from-tt -d docs/man$(2)/man7 releases='$(MANSERIES)' release='$(2)' \
		      < docs/sub-man7-index.html.tt > docs/man$(2)/man7/index.html
	./bin/from-tt -d docs/man$(2) releases='$(MANSERIES)' release='$(2)' \
		      < docs/sub-index.html.tt > docs/man$(2)/index.html
endef
define makemanuals1
$(eval $(call makemanpages1,$(1),$(2)))
$(eval $(call makemanapropos,$(1),$(2)))
$(eval $(call makemanindexes,$(1),$(2)))
endef
define makemanuals3
$(eval $(call makemanpages3,$(1),$(2)))
$(eval $(call makemanapropos,$(1),$(2)))
$(eval $(call makemanindexes,$(1),$(2)))
endef

# Now that we have the generating macros in place, let's use them!
#
# Start off with creating the 'manpages-master' target, taking the
# source from $(CHECKOUTS)/openssl/doc
$(eval $(call makemanuals3,openssl,master))

# Next, create 'manpages-x.y' for all current releases from 3.0 and on,
# taking the source from $(CHECKOUTS)/openssl-x.y/doc
$(foreach S,$(MANSERIES3),$(eval $(call makemanuals3,openssl-$(S),$(S))))

# Next, create 'manpages-x.y.z' for all current pre-3.0 releases, taking the
# source from $(CHECKOUTS)/openssl-x.y.z-stable/doc
$(foreach S,$(MANSERIES1),$(eval $(call makemanuals1,openssl-$(S)-stable,$(S))))

manmaster: man-apropos-master man-index-master
manpages: $(foreach S,$(MANSERIES),man-apropos-$(S) man-index-$(S))

mancross:
	./bin/mk-mancross master $(MANSERIES)

docs/manpages.html: docs/manpages.html.tt Makefile bin/from-tt
	@rm -f $@
	./bin/from-tt releases='master $(MANSERIES)' $<

docs/mansidebar.html: docs/mansidebar.html.tt Makefile bin/from-tt
	@rm -f $@
	./bin/from-tt releases='master $(MANSERIES)' $<

docs/faq.inc: $(wildcard docs/faq-[0-9]-*.txt) bin/mk-faq
	@rm -f $@
	./bin/mk-faq docs/faq-[0-9]-*txt >$@
docs/fips.inc: $(wildcard docs/fips/*) bin/mk-filelist
	@rm -f $@
	./bin/mk-filelist docs/fips fips/ '*' >$@

######################################################################
##
##  $(SIMPLE) -- SIMPLE GENERATED FILES
##
.PHONY: sitemap
newsflash.inc: news/newsflash.inc
	@rm -f $@
	head -7 $? >$@
sitemap sitemap.txt:
	@rm -f sitemap.txt
	./bin/mk-sitemap master $(SERIES) > sitemap.txt

community/committers.inc: $(PERSONDB)
	@rm -f $@
	wget -q https://api.openssl.org/0/Group/commit/Members
	./bin/mk-committers <Members >$@
	@rm -f Members

community/otc.inc: $(PERSONDB)
	./bin/mk-omc -n -t 'OTC Members' otc otc-inactive > $@
community/omc.inc: $(PERSONDB)
	./bin/mk-omc -n -e -l -p -t 'OMC Members' omc omc-inactive > $@
community/omc-alumni.inc: $(PERSONDB)
	./bin/mk-omc -n -l -t 'OMC Alumni' omc-alumni omc-emeritus > $@

news/changelog.inc: news/changelog.md bin/mk-changelog
	@rm -f $@
	(echo 'Table of contents'; sed -e '1,/^OpenSSL Releases$$/d' < $<) \
		| pandoc -t html5 -f commonmark | ./bin/post-process-html5 >$@
news/changelog.html: news/changelog.html.tt news/changelog.inc Makefile bin/from-tt
	@rm -f $@
	./bin/from-tt 'releases=$(SERIES)' $<
# Additionally, make news/changelog.html depend on clxy[z].txt, where xy[z]
# comes from the release number x.y[.z].  This permits it to be automatically
# recreated whenever there's a new major release.
news/changelog.html: $(foreach S,$(SERIES),news/cl$(subst .,,$(S)).txt)

# mknews_changelogtxt creates a target and ruleset for any changelog text
# file depending on the CHANGES file from the target release.
#
# $(1) = output file, $(2) = CHANGES files, relative to CHECKOUTS
define mknews_changelogtxt
news/$(1): $(CHECKOUTS)/$(2)
	@rm -f $$@
	cp $$? $$@
endef

# Create the target 'news/changelog.md', taking the source from
# $(CHECKOUTS)/openssl/CHANGES.md
$(eval $(call mknews_changelogtxt,changelog.md,openssl/CHANGES.md))

# Create the target 'news/clxy.md' for all releases from 3.0 and on, taking
# the source from $(CHECKOUTS)/openssl-x.y/CHANGES.md
$(foreach S,$(SERIES3),\
$(eval $(call mknews_changelogtxt,cl$(subst .,,$(S)).txt,openssl-$(S)/CHANGES.md)))

# Create the targets 'news/clxyz.txt' for all current pre-3.0 releases,
# taking the source from $(CHECKOUTS)/openssl-x.y.z-stable/CHANGES
$(foreach S,$(SERIES1),\
$(eval $(call mknews_changelogtxt,cl$(subst .,,$(S)).txt,openssl-$(S)-stable/CHANGES)))

# mknews_noteshtml creates two targets and rulesets for creating notes from
# the NEWS file for each release.  One target is to create a wrapping HTML
# file from a template, the other is to create the inclusion file with the
# actual text.
#
# $(1) = release version, $(2) = NEWS file, relative to CHECKOUTS
define mknews_noteshtml
news/openssl-$(1)-notes.html: news/openssl-notes.html.tt
	@rm -f $$@
	./bin/from-tt -d news -i $$< -o $$@ release='$(1)'
news/openssl-$(1)-notes.inc: $(CHECKOUTS)/$(2) bin/mk-notes
	@rm -f $$@
	./bin/mk-notes $(1) < $(CHECKOUTS)/$(2) > $$@
endef

# Create the targets 'news/openssl-x.y-notes.html' and
# 'news/openssl-x.y-notes.inc' for each release number x.y starting with 3.0,
# taking the source from the news file given as second argument.
$(foreach S,$(SERIES3),\
$(eval $(call mknews_noteshtml,$(S),openssl-$(S)/NEWS.md)))

# Create the targets 'news/openssl-x.y.z-notes.html' and
# 'news/openssl-x.y.z-notes.inc' for each pre-3.0 release number x.y.z,
# taking the source from the news file given as second argument.
$(foreach S,$(SERIES1),\
$(eval $(call mknews_noteshtml,$(S),openssl-$(S)-stable/NEWS)))

news/newsflash.inc: news/newsflash.txt
	sed <$? >$@ \
	    -e '/^#/d' \
	    -e 's@^@<tr><td class="d">@' \
	    -e 's@: @</td><td class="t">@' \
	    -e 's@$$@</td></tr>@'

# mknews_vulnerability creates two targets and rulesets for creating
# vulnerability lists for each release.  One target is to create a wrapping
# HTML file from a template, the other is to create the inclusion file with
# the actual text.
#
# $(1) = output file mod, $(2) = release version switch, $(3) = release version
define mknews_vulnerability
news/vulnerabilities$(1).inc: bin/mk-cvepage news/vulnerabilities.xml
	@rm -f $$@
	./bin/mk-cvepage -i news/vulnerabilities.xml $(2) > $$@
news/vulnerabilities$(1).html: news/vulnerabilities.html.tt bin/from-tt
	@rm -f $$@
	./bin/from-tt -d news vulnerabilitiesinc='vulnerabilities$(1).inc' < $$< > $$@
endef

# Create the main vulnerability index 'news/vulnerabilities.html' and
# 'news/vulnerabilities.inc'
$(eval $(call mknews_vulnerability,,))

# Create the vulnerability index 'news/vulnerabilities-x.y[.z].html' and
# 'news/vulnerabilities-x.y[.z].inc' for each release x.y[.z]
$(foreach S,$(SERIES) $(OLDSERIES),\
$(eval $(call mknews_vulnerability,-$(S),-b $(S))))

source/.htaccess: $(wildcard source/openssl-*.tar.gz) bin/mk-latest
	@rm -f @?
	./bin/mk-latest $(RELEASEDIR) >$@
source/index.inc: $(wildcard $(RELEASEDIR)/openssl-*.tar.gz) bin/mk-filelist
	@rm -f $@
	./bin/mk-filelist $(RELEASEDIR) '' 'openssl-*.tar.gz' >$@

######################################################################
##
##  $(SRCLISTS) -- LISTS OF SOURCES
##

# mkoldsourceindex creates two targets and rulesets for creating the
# list of update tarballs for each release.  One target is to create a
# wrapping HTML file from a template, the other is to create the
# inclusion file with the actual text.
#
# $(1) = release, $(2) = release title
define mkoldsourceindex
source/old/$(1)/index.inc: $(wildcard $(RELEASEDIR)/old/$(1)/*.gz) bin/mk-filelist
	@mkdir -p `dirname $$@`
	@rm -f $$@
	./bin/mk-filelist $(RELEASEDIR)/old/$(1) '' '*.gz' > $$@
source/old/$(1)/index.html: source/old/sub-index.html.tt bin/from-tt
	@mkdir -p `dirname $$@`
	@rm -f $$@
	./bin/from-tt -d source/old/$(1) \
		      release='$(1)' releasetitle='Old $(2) Releases' \
		      < $$< > $$@
endef

# Create the update tarball index 'source/old/x.y.z/index.html' and
# 'source/old/x.y.z/index.inc' for each release x.y.z.
# We also create a list specifically for the old FIPS module, carefully
# crafting an HTML title with an uppercase 'FIPS' while the subdirectory
# remains named 'fips'
$(foreach S,fips $(SERIES) $(OLDSERIES2),$(eval $(call mkoldsourceindex,$(S),$(patsubst fips,FIPS,$(S)))))

source/old/index.html: source/old/index.html.tt Makefile bin/from-tt
	@mkdir -p `dirname $@`
	@rm -f $@
	./bin/from-tt releases='$(SERIES) $(OLDSERIES2) fips' $<

# Because these the indexes of old tarballs will inevitably be newer
# than the tarballs that are moved into their respective directory,
# we must declare them phony, or they will not be regenerated when
# they should.
.PHONY : $(SRCLISTS) FORCE
