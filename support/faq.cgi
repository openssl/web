#!/usr/bin/perl
##
##  faq.cgi -- Read FAQ file and pretty-print it as HTML
##

$|++;
print "Content-type: text/html\r\n";
print "\r\n";

$file = "/v/openssl/checkouts/openssl/FAQ";
#$file = "/home/um/openssl/FAQ";
open(FP, "<$file");

# TOC
$i=0; $l=""; $n=0;
print "<ul>\n";
print "<ol>\n";
while (<FP>) {
    escape($_);
    last if /^=+$/;
    next if /^\w*$/;
    if (/^\[([^\[]+)\] (.*)/) {
	$l=$1;
	$n=0;
	print "</ol>\n";
	print "<li><a href=\"#$l\">$1</a> $2\n";
	print "<ol>\n";
    } elsif (/^\* (.*)/) {
	$n++;
	print "<li><a href=\"#$l$n\">$1</a>\n";
    }
}
print "</ol>\n";
print "</ul>\n\n";

# Contents
$l=""; $n=0; $pre=0; $snip=0;
while (<FP>) {
    next if /^=+$/;
    if (/^----- snip:start -----/) {
	print "<pre><listing>" unless $snip;
	$snip=1;
    }
    if ($snip) {
	escape($_);
	print;
    }
    if ($snip && /^----- snip:end -----/) {
	print "</listing></pre>";
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
    s/<URL: *(.*?)>/\@\@\@$1\@\@\@/;
    escape($_);
    s/\@\@\@(.*?)\@\@\@/<a href=\"$1\">$1<\/a>/;
    if (s/\((.?)\)/XX$1XX/g) {
	while (/([A-Za-z_\.]*)XX(.?)XX/) {
	    foreach $section ("apps", "ssl", "crypto") {
		if (-f "../docs/$section/$1.html") {
		    s|([A-Za-z_\.]*)XX(.?)XX|<a href=\"../docs/$section/$1.html\">$1($2)</a>|;
		    goto found;
		}
	    }
	    s/XX(.?)XX/($1)/;
	  found:
	}
    }
    if (/^\[([^\[]+)\] =+/) {
	$l=$1;
	$n=0;
	print "<hr>\n";
	print "<h2>[<a name=\"$l\">$1</a>]</h2>\n";
    } elsif (/^\* (.*)/) {
	$n++;
	print "\n<h2><i><a name=\"$l$n\">$n. $1</a></i></h2>\n";
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
