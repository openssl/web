#!/sw/bin/perl
##
##  faq.cgi -- Read FAQ file and pretty-print it as HTML
##

$|++;
print "Content-type: text/html\r\n";
print "\r\n";

$file = "/e/openssl/exp/openssl/FAQ";
#$file = "/home/um/openssl/FAQ";
open(FP, "<$file");

# TOC
$i=0; $n=0;
print "<ul>\n";
while (<FP>) {
    escape($_);
    $i++ if /^$/;
    last if $i > 1;
    if (/^\* (.*)/) {
	$n++;
	print "<li><a href=\"#$n\">$1</a>\n";
    }
}
print "</ul>\n\n";

# Contents
$n=0; $pre=0; $snip=0;
while (<FP>) {
    if (/^----- snip:start -----/) {
	print "<pre>" unless $snip;
	$snip=1;
    }
    if ($snip) {
	escape($_);
	print;
    }
    if ($snip && /^----- snip:end -----/) {
	print "</pre>";
	$snip=0;
	goto cont;
    }
    if ($snip) {
	goto cont;
    }
    if (/<URL:/ and not /<URL:.*>/) {
	chomp;
	$_ .= <FP>;
    }
    escape($_);
    s/&lt;URL: *(.*?)&gt;/<a href=\"$1\">$1<\/a>/;
    if (s/\((.?)\)/XX$1XX/g) {
	while (/([A-Za-z_\.]*)XX(.?)XX/) {
	    foreach $section ("apps", "ssl", "crypto") {
		if (-f "../docs/$section/$1.html") {
		    s|([A-Za-z_]*)XX(.?)XX|<a href=\"../docs/$section/$1.html\">$1($2)</a>|;
		    goto found;
		}
	    }
	    s/XX(.?)XX/($1)/;
	  found:
	}
    }
    if (/^\* (.*)/) {
	$n++;
	print "\n<h2><a name=\"$n\"></a>$1</h2>\n";
    } elsif (/^$/) {
	print "<p>";
    } elsif (/^ /) {
	print "<pre>" unless $pre;
	$pre=1;
	print;
    } else {
	print "</pre>\n" if $pre;
	$pre=0;
	print;
    }
  cont:
}

close(FP);

exit(0);

sub escape
{
    s/\&/\&amp;/g;
    s/\</\&lt;/g;
    s/\>/\&gt;/g;
}
