#!/usr/local/bin/perl

$PODSHOME=$ENV{"PODSHOME"}; #"/e/openssl/exp/openssl/doc";
$HTMLGOAL=$ENV{"HTMLGOAL"}; #"docs";

$DEBUG=$ENV{"DEBUG"};
$AT=$DEBUG ? "" : "\@";

%subs=();
%wmls=();
%goals=();
%dirs=();

#Get and massage info on what files will be processed
#
while(<STDIN>) {
    chop;
    my $file = $_;
    s+$PODSHOME/++;
    s+\.pod++;
    $subs{$file} = $HTMLGOAL . '/' . $_ . '.sub-html';
    $wmls{$file} = $HTMLGOAL . '/' . $_ . '.wml';
    $goals{$file} = $HTMLGOAL . '/' . $_ . '.html';
    s+/[^/]*$++;
    my $dir = $_;
    $dirs{$dir} = 1;
}

#Build a Makefile and send it on stdout.
#
print 'PODSHOME=',$PODSHOME,"\n";
print 'HTMLGOAL=',$HTMLGOAL,"\n";
print "\n";
print "PODSDIRS=",join(':',keys %dirs),"\n";
print "PODSDIRS_SPC=",join(' ',keys %dirs),"\n";
print "PODSDIRS_COMMA=",join(',',keys %dirs),"\n";
print "DOCS=\t",join(" \\\n\t",values %wmls),"\n";
print "\n";
print "docs : dirs caches \$(DOCS)\n";
print "\n";

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
print "\$(DOCS) :\n";
print "	",$AT,"pod=\"`echo \$\@ | sed -e 's,^\$(HTMLGOAL)/\\(.*\\)\\.wml\$\$,\$(PODSHOME)/\\1.pod,'`\"; \\\n";
print "	pag=\"`basename \$\@ .wml`\"; \\\n";
print "	d=\"`echo \$\@ | sed -e 's,/[^/]*\$\$,,' -e 's,^\$(HTMLGOAL)/,,'`\"; \\\n";
print "	if [ \"\$\$d\" = \"apps\" ]; then if [ \"\$\$pag\" = \"config\" ]; then s='(5)'; else s='(1)'; fi; else s='(3)'; fi; \\\n";
print "	echo '  \$\@'; \\\n";
print "	sed -e '/^FILE\$\$/,\$\$d' < make-docs-makefile.template | sed -e 's,PAGE,'\$\$pag',' -e 's,SECTION,'\$\$s',' > \$\@; \\\n";
print "	cat < \$\$pod | \\\n";
print "	PERL5LIB=docs pod2html --htmlroot=.. --podroot=\$(PODSHOME) --podpath=\$(PODSDIRS) | sed -e '1,/<BODY>/d' -e '/<\\/BODY>/,\$\$d' >> \$\@; \\\n";
print "	sed -e '1,/^FILE\$\$/d' < make-docs-makefile.template | sed -e 's,PAGE,'\$\$pag',' -e 's,SECTION,'\$\$s',' >> \$\@\n";
print "\n";

#We wanna make sure the directories are there...
#
print "dirs : \n";
print "	-",$AT,"for d in \$(PODSDIRS_SPC); do \\\n";
print "		mkdir docs/\$\$d 2>/dev/null; sed -e 's,url=\",url=\"../,' < \$(HTMLGOAL)/.wmlsnb > \$(HTMLGOAL)/\$\$d/.wmlsnb; \\\n";
print "	done\n";
print "\n";

#Since pod2html builds a cache of lesser value, let's build one of greater
#value for it.  This includes section numbers, thus avoiding conflicts between
#pages with the same name in different sections
#
print "caches : \n";
print "	",$AT,"echo '\$(PODSDIRS)' > pod2html-dircache\n";
print "	",$AT,"echo '\$(PODSHOME)' >> pod2html-dircache\n";
print "	",$AT,"for d in \$(PODSDIRS_SPC); do \\\n";
print "		for f in \$(PODSHOME)/\$\$d/*.pod; do \\\n";
print "			fs=\"`echo \$\$f | sed -e 's,^\$(PODSHOME)/,,'`\"; \\\n";
print "			pag=\"`basename \$\$f .pod`\"; \\\n";
print "			if [ \"\$\$d\" = \"apps\" ]; then if [ \"\$\$pag\" = \"config\" ]; then s='(5)'; else s='(1)'; fi; else s='(3)'; fi; \\\n";
print "			for i in `sed -e '1,/^=head1 *NAME *\$\$/d' -e '/^=head1 *DESCRIPTION *\$\$/,\$\$d' -e '/^=head1 *SYNOPSIS *\$\$/,\$\$d' -e '/^\$\$/d' < \$\$f | awk 'BEGIN { FOO=1; } /^- / { FOO=0; } { if (FOO == 1) print \$\$0; } / -/ { FOO=0; }' | sed -e 's/ -.*\$\$//' -e 's/,/ /g'`; do \\\n";
print "				echo \"\$\$i\$\$s \$\${fs}:\" >> pod2html-dircache; \\\n";
print "			done; \\\n";
print "			echo \"\$\$pag\$\$s \$\${fs}:\" >> pod2html-dircache; \\\n";
print "		done; \\\n";
print "	done\n";
print "\n";

#Finally, build the dependency table...
#
foreach $file (keys %goals) {
    print $wmls{$file},' : ',$file,"\n";
}
