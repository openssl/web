#!/sw/bin/perl
##
##  changelog.cgi -- Read CHANGES file and pretty-print it as HTML
##

$|++;
print "Content-type: text/html\r\n";
print "\r\n";

$file = glob("../source/openssl-[0-9].[0-9].[0-9a-z]*/CHANGES");
open(FP, "<$file");
$page = '';
$page .= $_ while (<FP>);
close(FP);

$page =~ s|^.+?(Changes.+?\n+)|$1|s;
$page =~ s|&|&amp\;|sg; # escape with useless backslash
$page =~ s|<|&lt\;|sg;
$page =~ s|>|&gt\;|sg;
$page =~ s|(Changes between.+?)\n|<b>$1</b>\n|sg;

print "<pre>$page</pre>";

exit(0);

