#! /usr/bin/env perl

$PODSHOME=$ENV{"PODSHOME"}; #"/e/openssl/exp/openssl/doc";
$HTMLGOAL=$ENV{"HTMLGOAL"}; #"docs";

$DEBUG=$ENV{"DEBUG"};
$AT=$DEBUG ? "" : "\@";

%subs=();
%wmls=();
%goals=();
%dirs=();

$HTML_pm = $HTMLGOAL . "/Pod/Html.pm";

#Get and massage info on what files will be processed
#
while(<STDIN>) {
    chop;
    my $file = $_;
    s+$PODSHOME/++;
    s+\.pod++;
    $wmls{$file} = $HTMLGOAL . '/' . $_ . '.wml';
    s+/[^/]*$++;
    my $dir = $_;
    $dirs{$dir} = 1;
}

$PODSDIRS=join(':',keys %dirs);
$PODSDIRS_SPC=join(' ',keys %dirs);
$PODSDIRS_COMMA=join(',',keys %dirs);

#Since pod2html builds a cache of lesser value, let's build one of greater
#value for it.  This includes section numbers, thus avoiding conflicts between
#pages with the same name in different sections
#
foreach $f (keys %wmls) {
    if ($DEBUG) { print STDERR "Processing file: $f\n"; }

    $fs = $f; $fs =~ s,$PODSHOME/,,;
    $d = $fs; $d =~ s,/[^/]*$,,;
    $pag = $fs; $pag =~ s,.*/,,g; $pag =~ s,\.pod$,,;

    $s = "(3)";
    if ($d eq "apps") {
	$s="(1)";
    } else {
    	$s = "(3)";
    }

    open(PODFILE,"<$f") || die "Couldn't open $f: $!\n";
    while(<PODFILE>) {
	if (/=for\s+comment\s+openssl_manual_section:(\S+)/)
		{
		$s="($1)";
		last;
		}
    }

    seek(PODFILE, 0, 0);

    $page{$pag . $s} = $fs;
    $dependencies{$f} = $pag . $s;

    $/ = "";
    $name = 0;
    while(<PODFILE>) {
	chop;
	s/\n/ /gm;
	if (/^=head1 /) {
	    $name = 0;
	} elsif ($name) {
	    if (/ - /) {
		s/ - .*//;
		s/[ \t,]+/ /g;
		@words = split ' ';
		foreach $w (@words) {
		    $page{$w . $s} = $fs;
		    if ($w !~ /_/) {
			$W = $w;
			$W =~ tr/A-Z/a-z/;
			if ($w ne $W && $page{$W . $s} eq "") {
			    $page{$W . $s} = $fs;
			}
		    }
		}
	    }
	} else {
	    $save = $_;
	    while((s,L<([^|/>]+\|)?([^/>]+)(/[^>]+)?>,,), $_ ne $save) {
		if ($DEBUG) { print STDERR "Adding to dep for $f: ",$2,"\n"; }
		$word = $2;
		$rword = $word;
		$rword =~ s/\(/\\(/g;
		$rword =~ s/\)/\\)/g;
		if ($DEBUG) { print STDERR "Looking for \"$rword\" in \"",$dependencies{$f},"\" -> ",($dependencies{$f} =~ m/$rword/),"\n"; }
		if (! ($dependencies{$f} =~ m/$rword/)) {
		    $dependencies{$f} .= ":" . $word;
		}
		$save = $_;
	    }
	}
	if (/^=head1 *NAME *$/) {
	    $name = 1;
	}
    }
    close(PODFILE);
}

open(PODCACHE,">pod2html-dircache") || die "Couldn't open the dir cache: $!\n";
print PODCACHE $PODSDIRS,"\n",$PODSHOME,"\n";
foreach $l (keys %page) {
    print PODCACHE $l," ",$page{$l},":\n";
}

#Build a Makefile and send it on stdout.
#
$DOCS="\t" . join(" \\\n\t",sort(values %wmls));

print <<END_OF_SECTION1;
PODSHOME=$PODSHOME
HTMLGOAL=$HTMLGOAL

PODSDIRS=$PODSDIRS
PODSDIRS_SPC=$PODSDIRS_SPC
PODSDIRS_COMMA=$PODSDIRS_COMMA
DOCS=$DOCS

docs : dirs \$(DOCS)

END_OF_SECTION1

#Theoretically, all this work wouldn't be needed, all we would really
#use is the WML construct <import src="...foo.pod">.  The problem is
#that there's currently no way to give the underlying pod2html the
#--htmlroot, --podroot and --podpath parameters.  Those are crucial
#to get links torking right.  Also, there seems to be no practical way
#to just include a HTML file into a WML file with hitting something else.
#So, instead we build the WML file from a template, and fill in with the
#result of pod2html somewhere in the middle.  That's why the whole thing
#looks so complicated.
#
print <<END_OF_SECTION2;
\$(DOCS) : make-docs-makefile.template
	${AT}pod="`echo \$\@ | sed -e 's,^\$(HTMLGOAL)/\\(.*\\)\\.wml\$\$,\$(PODSHOME)/\\1.pod,'`"; \\
	pag=\"`basename \$\@ .wml`\"; \\
	d="`echo \$\@ | sed -e 's,/[^/]*\$\$,,' -e 's,^\$(HTMLGOAL)/,,'`"; \\
	s='(3)'; \\
	if [ "\$\$d" = "apps" ]; then s='(1)'; if [ "\$\$pag" = "config" ]; then s='(5)'; fi; else if [ "\$\$d" = "crypto" -a "\$\$pag" = "des_modes" ]; then s='(7)'; fi; fi; \\
	echo '  \$\@'; \\
	sed -e '/^FILE\$\$/,\$\$d' < make-docs-makefile.template | sed -e 's,PAGE,'\$\$pag',' -e 's,SECTION,'\$\$s',' > \$\@; \\
	cat < \$\$pod | \\
	PERL5LIB=docs pod2html --htmlroot=.. --podroot=\$(PODSHOME) --podpath=\$(PODSDIRS) | sed -e '1,/<BODY>/d' -e '/<\\/BODY>/,\$\$d' -e 's/^\\(  *\\)#/\\1\\\\#/' -e 's/\\\\ *\$\$/\\\\\\\\/g' >> \$\@; \\
	sed -e '1,/^FILE\$\$/d' < make-docs-makefile.template | sed -e 's,PAGE,'\$\$pag',' -e 's,SECTION,'\$\$s',' >> \$\@

END_OF_SECTION2

#We wanna make sure the directories are there...
#
print <<END_OF_SECTION3;
dirs : 
	-${AT}for d in \$(PODSDIRS_SPC); do \\
		mkdir docs/\$\$d 2>/dev/null; \\
	done

END_OF_SECTION3

#Finally, build the dependency table...
#
foreach $file (keys %wmls) {
    if ($DEBUG) {
        print STDERR "Dependencies for $file: ",$dependencies{$file},"\n";
    }
    print $wmls{$file},' : ',$HTML_pm," \\\n\tmake-docs-makefile.pl \\\n\t",join(" \\\n\t",map { ($_ ne "" && $page{$_} ne "") ? $PODSHOME . '/' . $page{$_} : () } split(':',$dependencies{$file})),"\n";
}
