##
## Build procedure for www.openssl.org

##  Checkouts.
CHECKOUTS = /var/cache/openssl/checkouts
##  Snapshot directory
SNAP = $(CHECKOUTS)/openssl
##  OMC data directory
OMCDATA = $(CHECKOUTS)/data
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

# The H_ variables hold renderings of .md files present in the local
# repository.  This does not include .md files taken from other repositories,
# they have their own special handling.
H_TOP = $(addsuffix .html,$(basename $(shell git ls-files -- *.md)))
H_COMMUNITY = $(addsuffix .html,\
                $(basename $(shell git ls-files -- community/*.md)))
# We filter out any file starting with 'sub-'...  they get special treatment
H_DOCS = $(addsuffix .html,\
           $(basename $(shell git ls-files -- docs/*.md \
                                              docs/*.md.tt \
                              | grep -v '/sub-')))
H_NEWS = $(addsuffix .html,$(basename $(shell git ls-files -- news/*.md)))
H_POLICIES = $(addsuffix .html,\
               $(basename $(shell git ls-files -- policies/*.md \
                                                  policies/general/*.md \
                                                  policies/technical/*.md)))
H_SUPPORT = $(addsuffix .html,$(basename $(shell git ls-files -- support/*.md)))

SIMPLE = $(H_TOP) \
	 newsflash.inc \
	 $(H_COMMUNITY) \
	 community/committers.inc community/otc.inc \
	 community/omc.inc community/omc-alumni.inc \
	 $(H_DOCS) \
         news/changelog.html \
	 $(foreach S,$(SERIES),news/openssl-$(S)-notes.inc) \
	 $(foreach S,$(SERIES),news/openssl-$(S)-notes.html) \
	 $(H_NEWS) \
	 news/newsflash.inc \
	 news/secadv \
	 news/vulnerabilities.inc \
	 news/vulnerabilities.html \
	 $(foreach S,$(SERIES) $(OLDSERIES),news/vulnerabilities-$(S).inc) \
	 $(foreach S,$(SERIES) $(OLDSERIES),news/vulnerabilities-$(S).html) \
	 $(H_POLICIES) \
	 policies/glossary.html \
	 source/.htaccess \
	 source/index.inc \
	 source/old/index.html \
	 $(H_SUPPORT)
SRCLISTS = $(foreach S,$(FUTURESERIES) $(SERIES) $(OLDSERIES2) fips,source/old/$(S)/index.inc source/old/$(S)/index.html)

SIMPLEDOCS = docs/faq.inc docs/fips.inc \
	     docs/OpenSSLStrategicArchitecture.html \
	     docs/OpenSSL300Design.html \
	     docs/manpages.html

GLOSSARY=$(CHECKOUTS)/general-policies/policies/glossary.md
all_GENERAL_POLICIES=$(wildcard $(CHECKOUTS)/general-policies/policies/*.md)
all_TECHNICAL_POLICIES=$(wildcard $(CHECKOUTS)/technical-policies/policies/*.md)
GENERAL_POLICIES=$(filter-out $(CHECKOUTS)/general-policies/policies/README.md $(GLOSSARY),$(all_GENERAL_POLICIES))
TECHNICAL_POLICIES=$(filter-out $(CHECKOUTS)/technical-policies/policies/README.md,$(all_TECHNICAL_POLICIES))

.SUFFIXES: .md .html

.md.html:
	@rm -f $@
	./bin/md-to-html5 $<

all: suball subdocs manmaster mancross sitemap akamai-purge

suball: $(SIMPLE) $(SRCLISTS)

relupd: suball docs sitemap akamai-purge

docs: subdocs manpages mancross

subdocs: $(SIMPLEDOCS)

clean:
	rm -f $(SIMPLE) $(SIMPLEDOCS) $(SRCLISTS)

akamai-purge:

# Legacy targets
hack-source_htaccess: all
simple: all
generated: all
rebuild: all

# For our use of pandoc for full documents, we create a template suitable
# for us.
inc/pandoc-template.html5: inc/pandoc-header.html5 inc/pandoc-body-prologue.html5 inc/pandoc-body-epilogue.html5 bin/mk-pandoc-template Makefile
	pandoc --print-default-template=html5 \
		| ./bin/mk-pandoc-template html5 > $@
# Make bin/md-to-html5 depend on inc/pandoc-template.html5
bin/md-to-html5: inc/pandoc-template.html5

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
docs/man$(2)/man1/index.inc: bin/mk-apropos Makefile
	./bin/mk-apropos docs/man$(2)/man1 > $$@
docs/man$(2)/man3/index.inc: bin/mk-apropos Makefile
	./bin/mk-apropos docs/man$(2)/man3 > $$@
docs/man$(2)/man5/index.inc: bin/mk-apropos Makefile
	./bin/mk-apropos docs/man$(2)/man5 > $$@
docs/man$(2)/man7/index.inc: bin/mk-apropos Makefile
	./bin/mk-apropos docs/man$(2)/man7 > $$@
endef
define makemanindexes
docs/man$(2)/man1/index.md: docs/sub-man1-index.md.tt bin/from-tt Makefile
	./bin/from-tt -d docs/man$(2)/man1 \
                      releases='$(MANSERIES)' release='$(2)' \
		      < $$< > $$@
docs/man$(2)/man3/index.md: docs/sub-man3-index.md.tt bin/from-tt Makefile
	./bin/from-tt -d docs/man$(2)/man3 \
                      releases='$(MANSERIES)' release='$(2)' \
		      < $$< > $$@
docs/man$(2)/man5/index.md: docs/sub-man5-index.md.tt bin/from-tt Makefile
	./bin/from-tt -d docs/man$(2)/man5 \
                      releases='$(MANSERIES)' release='$(2)' \
		      < $$< > $$@
docs/man$(2)/man7/index.md: docs/sub-man7-index.md.tt bin/from-tt Makefile
	./bin/from-tt -d docs/man$(2)/man7 \
                      releases='$(MANSERIES)' release='$(2)' \
		      < $$< > $$@
docs/man$(2)/index.md: docs/sub-index.md.tt bin/from-tt Makefile
	./bin/from-tt -d docs/man$(2) \
                      releases='$(MANSERIES)' release='$(2)' \
		      < $$< > $$@
endef
define makemandirdata
docs/man$(2)/man1/dirdata.yaml: docs/sub-dirdata.yaml.tt bin/from-tt Makefile
	./bin/from-tt -d docs/man$(2)/man1 \
		      releases='$(MANSERIES)' release='$(2)' \
		      < $$< > $$@
docs/man$(2)/man3/dirdata.yaml: docs/sub-dirdata.yaml.tt bin/from-tt Makefile
	./bin/from-tt -d docs/man$(2)/man3 \
		      releases='$(MANSERIES)' release='$(2)' \
		      < $$< > $$@
docs/man$(2)/man5/dirdata.yaml: docs/sub-dirdata.yaml.tt bin/from-tt Makefile
	./bin/from-tt -d docs/man$(2)/man5 \
		      releases='$(MANSERIES)' release='$(2)' \
		      < $$< > $$@
docs/man$(2)/man7/dirdata.yaml: docs/sub-dirdata.yaml.tt bin/from-tt Makefile
	./bin/from-tt -d docs/man$(2)/man7 \
		      releases='$(MANSERIES)' release='$(2)' \
		      < $$< > $$@
docs/man$(2)/dirdata.yaml: docs/sub-dirdata.yaml.tt bin/from-tt Makefile
	./bin/from-tt -d docs/man$(2) \
                      releases='$(MANSERIES)' release='$(2)' \
		      < $$< > $$@
endef
define makemanuals1
$(eval $(call makemanpages1,$(1),$(2)))
$(eval $(call makemanapropos,$(1),$(2)))
$(eval $(call makemanindexes,$(1),$(2)))
$(eval $(call makemandirdata,$(1),$(2)))
endef
define makemanuals3
$(eval $(call makemanpages3,$(1),$(2)))
$(eval $(call makemanapropos,$(1),$(2)))
$(eval $(call makemanindexes,$(1),$(2)))
$(eval $(call makemandirdata,$(1),$(2)))
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

MANMASTER_TARGETS = \
        man-pages-master docs/manmaster/index.html \
        $(foreach SEC,1 3 5 7, docs/manmaster/man$(SEC)/index.inc \
                               docs/manmaster/man$(SEC)/index.html)
manmaster: $(MANMASTER_TARGETS)
MANPAGES_TARGETS = \
        $(foreach S,$(MANSERIES), \
          man-pages-$(S) docs/man$(S)/index.html \
          $(foreach SEC,1 3 5 7, docs/man$(S)/man$(SEC)/index.inc \
                                 docs/man$(S)/man$(SEC)/index.html))
manpages: manmaster $(MANPAGES_TARGETS)

mancross:
	./bin/mk-mancross master $(MANSERIES)

docs/manpages.md: docs/manpages.md.tt Makefile bin/from-tt
	@rm -f $@
	./bin/from-tt releases='master $(MANSERIES)' $<

docs/mansidebar.html: docs/mansidebar.html.tt Makefile bin/from-tt
	@rm -f $@
	./bin/from-tt releases='master $(MANSERIES)' $<

docs/faq.inc: $(wildcard docs/faq-[0-9]-*.txt) Makefile bin/mk-faq
	@rm -f $@
	./bin/mk-faq docs/faq-[0-9]-*txt >$@

# We don't want to include our web source files in the list of FIPS files
# to be downloaded, so we filter them out.  ./bin/mk-filelist can handle
# multiple file arguments.  Trust git ls-files over $(wildcard ...)
FIPS_FILES = $(filter-out %.yaml %.md %.tt,$(shell git ls-files -- docs/fips))
docs/fips.inc: $(FIPS_FILES) Makefile bin/mk-filelist
	@rm -f $@
	./bin/mk-filelist docs/fips fips/ $(notdir $(FIPS_FILES)) >$@

######################################################################
##
##  Policy page building section
##

.PHONY: technical-policies
technical-policies: $(TECHNICAL_POLICIES) bin/md-to-html5
	for x in $(TECHNICAL_POLICIES); do \
		d=$$(dirname $$x); \
		f=$$(basename $$x .md); \
		cat "$$x" \
			| sed -E -e 's!https?://github\.com/openssl/(general|technical)-policies/blob/master/policies/(.*)\.md!../\1/\2.html!' \
			| sed -E -e 's!\.\./general/glossary\.html!../glossary.html!' \
			| ./bin/md-to-html5 -o policies/technical/"$$f".html; \
	done
policies/technical/index.inc: technical-policies bin/mk-md-titlelist Makefile
	./bin/mk-md-titlelist '' $(TECHNICAL_POLICIES) > $@
policies/technical/index.html: \
	policies/technical/index.md policies/technical/index.inc \
	policies/technical/dirdata.yaml

.PHONY: general-policies
general-policies: $(GENERAL_POLICIES) bin/md-to-html5
	for x in $(GENERAL_POLICIES); do \
		d=$$(dirname "$$x"); \
		f=$$(basename "$$x" .md); \
		cat "$$x" \
			| sed -E -e 's!https?://github\.com/openssl/(general|technical)-policies/blob/master/policies/(.*)\.md!../\1/\2.html!' \
			| sed -E -e 's!\.\./general/glossary\.html!../glossary.html!' \
			| ./bin/md-to-html5 -o policies/general/"$$f".html; \
	done
policies/general/index.inc: general-policies bin/mk-md-titlelist Makefile
	./bin/mk-md-titlelist '' $(GENERAL_POLICIES) > $@
policies/general/index.html: \
	policies/general/index.md policies/general/index.inc \
	policies/general/dirdata.yaml

policies/glossary.html: $(GLOSSARY) bin/md-to-html5 policies/dirdata.yaml
	cat "$(GLOSSARY)" \
		| sed -E -e 's!https?://github\.com/openssl/(general|technical)-policies/blob/master/policies/(.*)\.md!\1/\2.html!' \
		| sed -E -e 's!general/glossary\.html!glossary.html!' \
		| ./bin/md-to-html5 -o policies/glossary.html

######################################################################
##
##  $(SIMPLE) -- SIMPLE GENERATED FILES
##
.PHONY: sitemap
newsflash.inc: news/newsflash.inc
	@rm -f $@
	head -7 $< >$@
sitemap sitemap.txt: bin/mk-sitemap Makefile
	@rm -f sitemap.txt
	./bin/mk-sitemap master $(SERIES) > sitemap.txt

community/committers.inc: $(PERSONDB) bin/mk-committers Makefile
	@rm -f $@
	wget -q https://api.openssl.org/0/Group/commit/Members
	./bin/mk-committers <Members >$@
	@rm -f Members

community/otc.inc: $(PERSONDB) bin/mk-omc Makefile
	./bin/mk-omc -n -p -t 'OTC Members' otc otc-inactive > $@
community/omc.inc: $(PERSONDB) bin/mk-omc Makefile
	./bin/mk-omc -n -e -l -p -t 'OMC Members' omc omc-inactive > $@
community/omc-alumni.inc: $(PERSONDB) bin/mk-omc Makefile
	./bin/mk-omc -n -l -t 'OMC Alumni' omc-alumni omc-emeritus > $@

news/changelog.inc: news/changelog.txt bin/post-process-html5 Makefile
	@rm -f $@
	(echo 'Table of contents'; sed -e '1,/^OpenSSL Releases$$/d' < $<) \
		| pandoc -t html5 -f commonmark | ./bin/post-process-html5 >$@
news/changelog.md: news/changelog.md.tt news/changelog.inc Makefile bin/from-tt
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
	cp $$< $$@
endef

# Create the target 'news/changelog.txt', taking the source from
# $(CHECKOUTS)/openssl/CHANGES.md
# We use the .txt extension for multiple purposes:
# 1. So the web server maps to the MIME type text/plain
# 2. To ensure there's no need to publish any .md file (since they're all
#    supposed to be used to generate .html files)
# 3. Because it was changelog.txt before, a well known target.  Why change it?
$(eval $(call mknews_changelogtxt,changelog.txt,openssl/CHANGES.md))

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
news/openssl-$(1)-notes.md: news/openssl-notes.md.tt bin/from-tt Makefile
	@rm -f $$@
	./bin/from-tt -d news -i $$< -o $$@ release='$(1)'
news/openssl-$(1)-notes.inc: $(CHECKOUTS)/$(2) bin/mk-notes Makefile
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

news/newsflash.inc: $(OMCDATA)/newsflash.txt Makefile
	sed <$< >$@ \
	    -e '/^#/d' \
	    -e 's@^@<tr><td class="d">@' \
	    -e 's@: @</td><td class="t">@' \
	    -e 's@$$@</td></tr>@'

# Make sure we have a copy of vulnerabilities.xml among our public web files
news/vulnerabilities.xml: $(OMCDATA)/vulnerabilities.xml
	cp $< $@

# mknews_vulnerability creates two targets and rulesets for creating
# vulnerability lists for each release.  One target is to create a wrapping
# HTML file from a template, the other is to create the inclusion file with
# the actual text.
#
# $(1) = output file mod, $(2) = release version switch, $(3) = release version
define mknews_vulnerability
news/vulnerabilities$(1).inc: bin/mk-cvepage news/vulnerabilities.xml Makefile
	@rm -f $$@
	./bin/mk-cvepage -i news/vulnerabilities.xml $(2) > $$@
news/vulnerabilities$(1).md: news/vulnerabilities.md.tt bin/from-tt Makefile
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

source/.htaccess: $(wildcard source/openssl-*.tar.gz) bin/mk-latest Makefile
	@rm -f @?
	./bin/mk-latest $(RELEASEDIR) >$@
source/index.inc: $(wildcard $(RELEASEDIR)/openssl-*.tar.gz) bin/mk-filelist Makefile
	@rm -f $@
	./bin/mk-filelist $(RELEASEDIR) '' 'openssl-*.tar.gz' >$@

# mknews_secadv creates a target to copy a secadv file from $(OMCDATA)/secadv
# to news/secadv/.
# $(1) = file name
define mknews_secadv
news/secadv/$(1): $(OMCDATA)/secadv/$(1)
	cp $$< $$@
endef

# Get the set of files in $(OMCDATA)/secadv/
SECADV_FILES = $(shell cd $(OMCDATA)/secadv/; git ls-files)
$(foreach F,$(SECADV_FILES),$(eval $(call mknews_secadv,$(F))))

mkdirnews_secadv: FORCE
	mkdir -p news/secadv
news/secadv: mkdirnews_secadv $(addprefix news/secadv/,$(SECADV_FILES))
.PHONY: news/secadv mkdirnews_secadv

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
source/old/$(1)/index.inc: $(wildcard $(RELEASEDIR)/old/$(1)/*.gz) bin/mk-filelist Makefile
	@mkdir -p `dirname $$@`
	@rm -f $$@
	./bin/mk-filelist $(RELEASEDIR)/old/$(1) '' '*.gz' > $$@
source/old/$(1)/index.html: source/old/sub-index.html.tt bin/from-tt Makefile
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

source/old/index.html: source/old/index.html.tt Makefile bin/from-tt Makefile
	@mkdir -p `dirname $@`
	@rm -f $@
	./bin/from-tt releases='$(SERIES) $(OLDSERIES2) fips' $<

# Because these the indexes of old tarballs will inevitably be newer
# than the tarballs that are moved into their respective directory,
# we must declare them phony, or they will not be regenerated when
# they should.
.PHONY : $(SRCLISTS) FORCE

# Extra HTML dependencies (apart from the markdown file it comes from)

# makehtmldepend creates a standard dependency for HTML files rendered from
# markdown files
# $(1) = HTML file
define makehtmldepend
$(1): bin/md-to-html5 $(dir $(1))dirdata.yaml
endef

# Generate standard dependencies for our known HTML outputs.
$(foreach H, \
  $(H_TOP) \
  $(H_COMMUNITY) \
  $(H_DOCS) \
  $(filter %.html,$(MANMASTER_TARGETS)) \
  $(filter %.html,$(MANPAGES_TARGETS)) \
  $(H_NEWS) \
  $(H_POLICIES) \
  $(H_SUPPORT) \
,$(eval $(call makehtmldepend,$(H))))
