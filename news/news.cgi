#!/sw/bin/perl
##
##  news.cgi -- Read NEWS file and pretty-print it as HTML
##

$|++;
print "Content-type: text/html\r\n";
print "\r\n";

$file = "/e/openssl/exp/openssl/NEWS";
open(FP, "<$file");
$page = '';
$page .= $_ while (<FP>);
close(FP);

$page =~ s|^.+?(Major changes.+?\n+)|$1|s;
$page =~ s|&|&amp\;|sg; # escape with useless backslash
$page =~ s|<|&lt\;|sg;
$page =~ s|>|&gt\;|sg;
$page =~ s|(Major changes between.+?)\n|<b>$1</b>\n|sg;

print "<pre>$page</pre>";

exit(0);

