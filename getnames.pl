#!/usr/bin/perl

my $func = $ARGV[0];
$func =~ s/\.pod//;
$func =~ s@.*/@@;

open(FH, $ARGV[0]) || die "Can't open $ARGV[1], $!";
$/ = "";			# Eat a paragraph at once.
while (<FH>) {
    chop;
    s/\n/ /gm;
    if (/^=head1 /) {
	$name = 0;
    } elsif ($name) {
	if (/ - /) {
	    s/ - .*//;
	    s/,\s+/,/g;
	    s/\s+,/,/g;
	    s/^\s+//g;
	    s/\s+$//g;
	    s/\s/_/g;
	    push @words, split ',';
	}
    }
    if (/^=head1 *NAME *$/) {
	$name = 1;
    }
}

print join("\n", grep { $_ ne $func } @words),"\n";
