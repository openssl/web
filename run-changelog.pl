#!/usr/bin/perl

$|++;
$page = '';
$page .= $_ while (<STDIN>);

$page =~ s|^.+?(Changes.+?\n+)|$1|s;
$page =~ s|&|&amp\;|sg; # escape with useless backslash
$page =~ s|<|&lt\;|sg;
$page =~ s|>|&gt\;|sg;
$page =~ s|(Changes between.+?)\n|<b>$1</b>\n|sg;

print "<pre>$page</pre>";

exit(0);
