#!/sw/bin/perl
##
##  majordomo.cgi -- Send a mail to Majordomo
##

#   switch to unbuffered I/O
$|++;

#   generate a webpage
sub send_page {
    my ($text) = @_;

    $O = '';
    $O .= "Content-type: text/html\n" .
          "Connection: close\n" .
          "\n";
    open(FP, "<majordomo.head.html");
    $O .= $_ while (<FP>); 
    close(FP);
    $O .= $text;
    open(FP, "<majordomo.foot.html");
    $O .= $_ while (<FP>); 
    close(FP);
    print $O;
}

#   let us catch runtime errors...
eval {

#   PATH_INFO
$path_info = $ENV{'PATH_INFO'};

#   QUERY_STRING
$query_string = $ENV{'QUERY_STRING'};
if ($ENV{'REQUEST_METHOD'} eq 'POST') {
    $query_string = '';
    while (<STDIN>) { $query_string .= $_; }
}
%qs = ();
@pairs = split(/&/, $query_string);
foreach $pair (@pairs) {
    my ($name, $value) = split(/=/, $pair);
    $value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack('C', hex($1))/eg;
    if ($qs{$name} ne '') {
        $qs{$name} .= ",$value";
    }
    else {
        $qs{$name} = $value;
    }
}

#   check for parameter consistency
die "You supplied to Email address." 
    if ($qs{email} eq '');
die "Hmmm... <tt>your\@address.dom</tt> is certainly not correct, friend." 
    if ($qs{email} eq 'your@address.dom');
die "Hmmm... <tt>$qs{email}</tt> doesn't look like a valid RFC822 mail address."
    if ($qs{email} !~ m|.+@.+|);
die "At least one list has to be selected."
    if ($qs{list} eq '');
die "At least one action has to be selected."
    if ($qs{action} eq '');
die "Bogus action!"
    if ($qs{action} ne 'subscribe' and $qs{action} ne 'unsubscribe');

#   generate mail
$mail = '';
$mail .= "From: nobody@openssl.org\n";
$mail .= "Reply-To: $qs{email}\n";
$mail .= "Subject: Subscription to OpenSSL mailing list(s)\n";
$mail .= "To: majordomo\@openssl.org\n";
$mail .= "\n";
foreach $list (split(/,/, $qs{list})) { 
    die "Bogus listname!"
        if ($list ne 'announce' and $list ne 'users' and $list ne 'dev' and $list ne 'cvs');
    $mail .= "$qs{action} openssl-$list $qs{email}\n";
}

#  send out mail
open(MAIL, "|/sw/bin/sendmail -oi -oee majordomo\@openssl.org");
print MAIL $mail;
close(MAIL);

#  generate result page
&send_page(
    "Ok, the ingredients of the form were successfully parsed " .
    "and forwarded to Majordomo via Email in the following format:" .
    "<p>" .
    "<table cellpadding=5 bgcolor=\"#f0f0f0\"><tr><td>" .
    "<pre>$mail</pre>\n" .
    "</td></tr></table>" .
    "<p>" .
    "Expect a reply in your $qs{email} Email folder the next minutes.\n"
);

#   die gracefully
exit(0);

#   ...the runtime error handler:
};
if ($@) {
    my $text = $@;
    $text =~ s|at /.*||;
    &send_page(
        "A fatal error occured while processing the ingredients of your" .
        "Majordomo-request.  Please check the error message below, go back to" .
        "the form and fix the problem." .
        "<p>\n" .
        "<font color=\"#cc3333\"><b>$text</b></font>\n"
    );
}

##EOF##
