#!/sw/bin/perl -s
#
# cvsweb - a CGI interface to CVS trees.
#
# Written by Bill Fenner  <fenner@parc.xerox.com> on his own time.
# ... extended by Henner Zeller <zeller@think.de> on his very own time.
#
# $Id: cvsweb.cgi,v 1.1 1999/01/29 16:08:31 openssl Exp $
#
# this is based on Bill Fenners cvsweb.cgi revision 1.14 you get at:
#   http://www.freebsd.org/cgi/cvsweb.cgi/www/data/cgi/cvsweb.cgi?rev=1.14
#
# This is really huge - anyone wants to write a java servlet
# which does this (using the pserver-protocol) ?
#
# Copyright (c) 1996-1998 Bill Fenner
#           (c) 1998      Henner Zeller (since freebsd rev 1.14)
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.
#
###

##### Start of Configuration Area ########
# == EDIT this == 
# User configuration is stored in
$config = 'cvsweb.conf';

##### End of Configuration Area   ########

use Time::Local;
use FileHandle;
use IPC::Open2;

$verbose = $v;
$checkoutMagic = "exp";
($where = $ENV{'PATH_INFO'}) =~ s|^/($checkoutMagic)?||;
$doCheckout = ($ENV{'PATH_INFO'} =~ /^\/$checkoutMagic/);
$where =~ s|/$||;
($scriptname = $ENV{'SCRIPT_NAME'}) =~ s|^/?|/|;
$scriptname =~ s|/$||;
$scriptname =~ s|cvsweb.cgi|cvs|;
$scriptwhere = $scriptname . '/' . urlencode($where);
$scriptwhere =~ s|/$||;

# in lynx, it it very annoying to have two links
# per file, so disable the link at the icon
# in this case:
($Browser = $ENV{'HTTP_USER_AGENT'}) =~ s|/.*$||;
$nofilelinks=($Browser eq 'Lynx');

# put here the variables we need in order
# to hold our state - they will be added (with
# their current value) to any link/query string 
# you construct
@usedvars=('cvsroot','hideattic','sortbydate');

if (-f $config) {
    do "$config";
}
else {
   &fatal("500 Internal Error",'Configuration not found. set the variable <code>$config</code> in cvsweb.cgi to your <b>cvsweb.conf</b> configuration file first.');
}

if ($where =~ m|openssl-core|) {
   &fatal("500 Internal Error", 'You are not allowed to walk into openssl-core');
}

if ($query = $ENV{'QUERY_STRING'}) {
    foreach (split(/&/, $query)) {
	s/%(..)/sprintf("%c", hex($1))/ge;	# unquote %-quoted
	if (/(\S+)=(.*)/) {
	    $input{$1} = $2;
	} else {
	    $input{$_}++;
	}
    }
}
    
# get actual parameters
$bydate=$input{"sortbydate"};

$barequery = "";
foreach (@usedvars) {
    if (defined $DEFAULTSWITCH{$_} && not defined $input{$_}) {
	if (not defined $input{"copt"}) {
	    # 'copt' isn't defined -> not the result of empty input checkbox -> set default
	    $input{$_} = $DEFAULTSWITCH{$_};
	} else {
	    $input{$_} = 0;
	}
    }
    
    if (defined $input{$_}) {
	if ($barequery) {
	    $barequery = $barequery . "&";
	}
	$thisval = urlencode($_) . "=" . urlencode($input{$_});
	$barequery = $barequery  . $thisval;
    }
}
$query = "?$barequery";
if ($barequery) {
    $barequery = "&" . $barequery;
}


## Default CVS-Tree
if (not defined $CVSROOT{$cvstreedefault}) {
   &fatal("500 Internal Error",'<code>$cvstreedefault</code> points to a repository not defined in <code>%CVSROOT</code> (edit cvsweb.conf)');
}
$cvstree = $cvstreedefault;
$cvsroot = $CVSROOT{"$cvstree"};

# alternate CVS-Tree, configured in cvsweb.conf
if ($input{'cvsroot'}) {
    if ($CVSROOT{$input{'cvsroot'}}) {
	$cvstree = $input{'cvsroot'};
	$cvsroot = $CVSROOT{"$cvstree"};
    }
}

# create icons out of description
foreach $k (keys %ICONS) {
    ($itxt,$ipath,$iwidth,$iheight)=@{$ICONS{$k}};
    if ($ipath) {
	$ {"${k}icon"} = "<IMG SRC=\"$ipath\" ALT=\"$itxt\" BORDER=\"0\" WIDTH=\"$iwidth\" HEIGHT=\"$iheight\">";
    } else {
	$ {"${k}icon"} = $itxt;
    }
}

# Do some special configuration for cvstrees
do "$config-$cvstree" if -f "$config-$cvstree";

$fullname = $cvsroot . '/' . $where;

if (!-d $cvsroot) {
    &fatal("500 Internal Error",'$CVSROOT not found!<P>The server on which the CVS tree lives is probably down.  Please try again in a few minutes.');
}


# 
# View a directory
#
if (-d $fullname) {
	opendir(DIR, $fullname) || &fatal("404 Not Found","$where: $!");
	@dir = readdir(DIR);
	closedir(DIR);
	if ($where eq '') {
	    print &html_header("$defaulttitle");
	    print $long_intro;
	} else {
	    print &html_header("/$where");
	    print $short_instruction;
	}

	getDirLogs($fullname);
	
	print "<a name=\"dirlist\">\n";
	# give direct access to dirs
	if ($where eq '') {
	    chooseCVSRoot();
	} else {
	    print "<p>Current directory: <b>", &clickablePath($where,0), "</b>\n";
	}
	 

	print "<P><HR NOSHADE SIZE=1>\n";
	# Using <MENU> in this manner violates the HTML2.0 spec but
	# provides the results that I want in most browsers.  Another
	# case of layout spooging up HTML.
	
	if ($dirtable) {
	    print "<table  width=\"100%\" border=0 cellspacing=1 cellpadding=$tablepadding>\n";
	    print "<tr><th align=left bgcolor=" . (($bydate) ? 
						   $columnHeaderColorDefault : 
						   $columnHeaderColorSorted) . ">";
	    print "<a href=\"${scriptwhere}?" . &toggleQuery ("sortbydate") .
		"#dirlist\">" if ($bydate);
	    print "File";
	    print "</a>" if ($bydate);
	    print "</th>";
	    # do not display the other column-headers, if we do not have any files
	    # with revision information:
	    if (scalar(%fileinfo)) {
		print "<th align=left bgcolor=$columnHeaderColorDefault>Rev.</th>";
		print "<th align=left bgcolor=" . (($bydate) ? 
						   $columnHeaderColorSorted : 
						   $columnHeaderColorDefault) . ">";
		print "<a href=\"${scriptwhere}?" . &toggleQuery ("sortbydate") .
		    "#dirlist\">" if (not $bydate);
		print "Age";
		print "</a>" if (not $bydate);
		print "</th>";
		print "<th align=left bgcolor=$columnHeaderColorDefault>last Logentry</th>";
	    }
		print "</tr>\n";
	} else {
	    print "<menu>\n";
	}
	$dirrow = 0;
	
	lookingforattic:
	for ($i = 0; $i <= $#dir; $i++) {
		if ($dir[$i] eq "Attic") {
		    last lookingforattic;
		}
	}
	if (!$input{'hideattic'} && ($i <= $#dir) &&
	    opendir(DIR, $fullname . "/Attic")) {
	    splice(@dir, $i, 1,
			grep((s|^|Attic/|,!m|/\.|), readdir(DIR)));
		closedir(DIR);
	}

	$hideAtticToggleLink = "<a href=\"${scriptwhere}?" . 
	        &toggleQuery ("hideattic") .
		"#dirlist\">[Hide]</a>" if (not $input{'hideattic'});

	# Sort without the Attic/ pathname.
	# place directories first
	foreach (sort { &fileSortCmp } @dir) {
	    if ($_ eq '.') {
		next;
	    }
	    if (s|^Attic/||) {
		$attic  = " (in the Attic)&nbsp;" . $hideAtticToggleLink;
	    } else {
		$attic = "";
	    }
	    
	    if ($_ eq '..' || -d $fullname . "/" . $_) {
		next if ($_ eq '..' && $where eq '');
		print "<tr bgcolor=\"" . @tabcolors[$dirrow%2] . "\"><td>" if ($dirtable);
		if ($_ eq '..') {
		    ($updir = $scriptwhere) =~ s|[^/]+$||;
		    $url = $updir . $query;
		    if ($nofilelinks) {
			print $backicon;
		    } else {
			print &link($backicon,$url);
		    }
		    print " ", &link("Previous Directory",$url);
		} else {
		    $url = $scriptwhere . '/' . urlencode($_) . '/' . $query;
		    print "<A NAME=\"$_\">";
		    if ($nofilelinks) {
			print $diricon;
		    } else {
			print &link($diricon,$url);
		    }
		    print " ", &link($_ . "/", $url), $attic;
		    if ($_ eq "Attic") {
			print "&nbsp; <a href=\"${scriptwhere}?" . 
			    &toggleQuery ("hideattic") .
				"#dirlist\">[Don't hide]</a>";
		    }
		}
		# close row; if we do not have any files in our table,
		# we just need one column
		if ($dirtable) {
		    if (scalar(%fileinfo)) {
			print "</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr>";
                    } else {
			print "</td></tr>";
                    }
		} else {
		    print "<br>\n";
		}
		$dirrow++;
	    } elsif (s/,v$//) {
		print "<tr bgcolor=\"" . @tabcolors[$dirrow%2] . "\"><td>" if ($dirtable);
		print "<A NAME=\"$_\">";
# TODO: add date/time?  How about sorting? .. done (hen)
		$fileurl = ($attic ? "Attic/" : "") . urlencode($_);
		$url = $scriptwhere . '/' . $fileurl . $query;
		$head='';$date='';$log='';
		($head,$date,$log)=@{$fileinfo{$_}};
		if ($nofilelinks) {
		    print $fileicon;
		} else {
		    print &link($fileicon,$url);
		}
		print " ", &link($_, $url), $attic;
		print "</td><td>&nbsp;" if ($dirtable);
		download_link(urlencode($where) . '/' . $fileurl,
			      $head, $head);
		print "</td><td>&nbsp;" if ($dirtable);
		if ($date) {
		    print " <i>" . readableTime(time() - $date,0) . "</i>";
		}
		print "</td><td>&nbsp;" if ($dirtable);
		if ($log) {
		    print " <font size=-1>" . &htmlify(substr($log,0,$shortLogLen));
		    if (length $log > 80) {
			print "...";
		    }
		    print "</font>";
		}
		print "</td>" if ($dirtable);
		print (($dirtable) ? "</tr>" : "<br>");
		$dirrow++;
	    }
	    print "\n";
	}
	print "". ($dirtable==1) ? "</table>" : "</menu>" . "\n";
	
	if ($input{"only_on_branch"}) {
	    print "<HR><FORM METHOD=\"GET\" ACTION=\"${scriptwhere}\">\n";
	    print "Currently showing only branch $input{'only_on_branch'}.\n";
	    $input{"only_on_branch"}="";
	    foreach $k (keys %input) {
		print "<INPUT TYPE=hidden NAME=$k VALUE=$input{$k}>\n" if $input{$k};
	    }
	    print "<INPUT TYPE=SUBMIT VALUE=\"Show all branches\">\n";
	    print "</FORM>\n";
	}
	$formwhere = $scriptwhere;
	$formwhere =~ s|Attic/?$|| if ($input{'hideattic'});

	if ($edit_option_form) {
	    print "<hr><FORM METHOD=\"GET\" ACTION=\"${formwhere}\">\n";
	    print "<table>";
	    print "<tr><td><input type=\"CHECKBOX\" value=\"1\" name=\"sortbydate\" ";
	    print ($input{"sortbydate"} ? "CHECKED>" : ">&nbsp;");
	    print "Sort by Age</td><td>";
	    print "<INPUT TYPE=HIDDEN NAME=\"copt\" VALUE=\"X\">\n";
	    print "<input type=\"CHECKBOX\" value=\"1\" name=\"hideattic\" ";
	    print ($input{'hideattic'} ? "CHECKED>" : ">&nbsp;");
	    print "Hide attic files</td><td>";
	    print "<input type=submit value=\"Change Options\"></td></tr>";
	    print "</table>";
	    print "<INPUT TYPE=HIDDEN NAME=\"cvsroot\" VALUE=\"$cvstree\">\n"
		if &cvsroot;
	    print "</FORM>\n";
	}
	print &html_footer;
	# print "</BODY></HTML>\n";
    } 
#
# View Files
#
    elsif (-f $fullname . ',v') {
	if ($input{'rev'} =~ /^[\d\.]+$/ || $doCheckout) {
	    &doCheckout($fullname, $input{'rev'});
	    exit;
	}
	if ($input{'annotate'} =~ /^[\d\.]+$/ && $allow_annotate) {
	    &doAnnotate($input{'annotate'});
	    exit;
	}
	if ($input{'r1'} && $input{'r2'}) {
	    &doDiff($fullname, $input{'r1'}, $input{'tr1'},
		    $input{'r2'}, $input{'tr2'}, $input{'f'});
	    exit;
	}
	print("going to dolog($fullname)\n") if ($verbose);
	&doLog($fullname);
    } elsif ($fullname =~ s/\.diff$// && -f $fullname . ",v" &&
	     $input{'r1'} && $input{'r2'}) {
	# Allow diffs using the ".diff" extension
	# so that browsers that default to the URL
	# for a save filename don't save diff's as
	# e.g. foo.c
	&doDiff($fullname, $input{'r1'}, $input{'tr1'},
		$input{'r2'}, $input{'tr2'}, $input{'f'});
	exit;
    } elsif (($newname = $fullname) =~ s|/([^/]+)$|/Attic/$1| &&
	     -f $newname . ",v") {
	# The file has been removed and is in the Attic.
	# Send a redirect pointing to the file in the Attic.
	($newplace = $scriptwhere) =~ s|/([^/]+)$|/Attic/$1|;
	&redirect($newplace);
	exit;
    } elsif (0 && (@files = &safeglob($fullname . ",v"))) {
	print "Content-type: text/plain\n\n";
	print "You matched the following files:\n";
	print join("\n", @files);
	# Find the tags from each file
	# Display a form offering diffs between said tags
    } else {
	# Assume it's a module name with a potential path following it.
	$xtra = $& if (($module = $where) =~ s|/.*||);
	# Is there an indexed version of modules?
	if (open(MODULES, "$cvsroot/CVSROOT/modules")) {
	    while (<MODULES>) {
		if (/^(\S+)\s+(\S+)/o && $module eq $1
		    && -d "${cvsroot}/$2" && $module ne $2) {
		    &redirect($scriptname . '/' . $2 . $xtra);
		}
	    }
	}
	&fatal("404 Not Found","$where: no such file or directory");
    }
## End MAIN

sub htmlify {
	local($string, $pr) = @_;

	$string =~ s/&/&amp;/g;
	$string =~ s/\"/&quot;/g; 
	$string =~ s/</&lt;/g;
	$string =~ s/>/&gt;/g;

	# get URL's as link ..
	$string =~ s§(http|ftp)(://[-a-zA-Z0-9%?=&.~:/]+)§<A HREF="$1$2">$1$2</A>§;
	# get e-mails as link
	$string =~ s§([-a-zA-Z0-9.]+@([-a-zA-Z0-9]+\.)+[A-Za-z]{2,4})§<A HREF="mailto:$1">$1</A>§;

	return $string;
}

sub link {
	local($name, $where) = @_;

	return "<A HREF=\"$where\">$name</A>\n";
}

sub revcmp {
	local($rev1, $rev2) = @_;
	local(@r1) = split(/\./, $rev1);
	local(@r2) = split(/\./, $rev2);
	local($a,$b);

	while (($a = shift(@r1)) && ($b = shift(@r2))) {
	    if ($a != $b) {
		return $a <=> $b;
	    }
	}
	if (@r1) { return 1; }
	if (@r2) { return -1; }
	return 0;
}

sub fatal {
	local($errcode, $errmsg) = @_;
	print "Status: $errcode\n";
	print &html_header("Error");
#	print "Content-type: text/html\n";
#	print "\n";
#	print "<HTML><HEAD><TITLE>Error</TITLE></HEAD>\n";
#	print "<BODY>Error: $errmsg</BODY></HTML>\n";
	print "Error: $errmsg\n";
	print &html_footer;
	exit(1);
}

sub redirect {
	local($url) = @_;
	print "Status: 301 Moved\n";
	print "Location: $url\n";
	print &html_header("Moved");
#	print "Content-type: text/html\n";
#	print "\n";
#	print "<HTML><HEAD><TITLE>Moved</TITLE></HEAD>\n";
#	print "<BODY>This document is located <A HREF=$url>here</A>.</BODY></HTML>\n";
	print "This document is located <A HREF=$url>here</A>.\n";
	print &html_footer;
	exit(1);
}

sub safeglob {
	local($filename) = @_;
	local($dirname);
	local(@results);

	($dirname = $filename) =~ s|/[^/]+$||;
	$filename =~ s|.*/||;

	if (opendir(DIR, $dirname)) {
		$glob = $filename;
	#	transform filename from glob to regex.  Deal with:
	#	[, {, ?, * as glob chars
	#	make sure to escape all other regex chars
		$glob =~ s/([\.\(\)\|\+])/\\$1/g;
		$glob =~ s/\*/.*/g;
		$glob =~ s/\?/./g;
		$glob =~ s/{([^}]+)}/($t = $1) =~ s-,-|-g; "($t)"/eg;
		foreach (readdir(DIR)) {
			if (/^${glob}$/) {
				push(@results, $dirname . "/" .$_);
			}
		}
	}

	@results;
}

sub getMimeTypeFromSuffix {
    my ($fullname) = @_;
    local ($mimetype, $suffix);

    ($suffix = $fullname) =~ s/^.*\.([^.]*)$/\1/;
    $mimetype=$MTYPES{$suffix};
    
    if (!$mimetype && -f $mime_types) {
	# okey, this is something special - search the
	# mime.types database
	open (MIMETYPES, "<$mime_types");
	while (<MIMETYPES>) {
	    if ($_ =~ /^\s*(\S+\/\S+).*\b$suffix\b/) {
		$mimetype=$1;
		last;
	    }
	}
	close (MIMETYPES);
    }
    
# okey, didn't find anything useful ..
    if (!($mimetype =~ /\S\/\S/)) {
	$mimetype="text/plain";
    }
    return $mimetype;
}

sub doAnnotate ($$) {
    my ($rev) = @_;
    local ($pid);

    ($pathname = $where) =~ s/(Attic\/)?[^\/]*$//;
    ($filename = $where) =~ s/^.*\///;
    $|=1;
    print "Content-type: text/html\n\n";
    navigateHeader ($scriptwhere,$pathname,$filename,$rev);
    print  "<h3 align=center>Annotation of $pathname$filename, Revision $rev</h3>\n";

    # this annotate version is based on the
    # cvs annotate-demo Perl script by Cyclic Software
    # It was written by Cyclic Software, http://www.cyclic.com/, and is in
    # the public domain.
    # we could abandon the use of rlog, rcsdiff and co using
    # the cvsserver in a similiar way one day (..after rewrite)
    $pid = open2( \*Reader, \*Writer, "cvs server" ) || fatal ("500 Internal Error", 
							       "Fatal Error - unable to open cvs for annotation");
    Writer->autoflush(); # default here, actually
    
    # OK, first send the request to the server.  A simplified example is:
    #     Root /home/kingdon/zwork/cvsroot
    #     Argument foo/xx
    #     Directory foo
    #     /home/kingdon/zwork/cvsroot/foo
    #     Directory .
    #     /home/kingdon/zwork/cvsroot
    #     annotate
    # although as you can see there are a few more details.
    
    print Writer "Root $cvsroot\n";
    print Writer "Valid-responses ok error Valid-requests Checked-in Updated Merged Removed M E\n";
    # Don't worry about sending valid-requests, the server just needs to
    # support "annotate" and if it doesn't, there isn't anything to be done.
    print Writer "UseUnchanged\n";
    print Writer "Argument -r\n";
    print Writer "Argument $rev\n";
    print Writer "Argument $where\n";

    # The protocol requires us to fully fake a working directory (at
    # least to the point of including the directories down to the one
    # containing the file in question).
    # So if $where is "dir/sdir/file", then @dirs will be ("dir","sdir","file")
    @dirs = split (/\//, $where);
    $path = "";
    foreach (@dirs) {
	if ($path eq "") {
	    # In our example, $_ is "dir".
	    $path = $_;
	} 
	else {
	    print Writer "Directory " . $path . "\n";
	    print Writer "$cvsroot/" . $path ."\n";
	    # In our example, $_ is "sdir" and $path becomes "dir/sdir"
	    # And the next time, "file" and "dir/sdir/file" (which then gets
	    # ignored, because we don't need to send Directory for the file).
            $path = $path . "/" . $_;
	}
    }
    # And the last "Directory" before "annotate" is the top level.
    print Writer "Directory .\n";
    print Writer "$cvsroot\n";
    
    print Writer "annotate\n";
    # OK, we've sent our command to the server.  Thing to do is to
    # close the writer side and get all the responses.  If "cvs server"
    # were nicer about buffering, then we could just leave it open, I think.
    close (Writer) || die "cannot close: $!";
    
    # Ready to get the responses from the server.
    # For example:
    #     E Annotations for foo/xx
    #     E ***************
    #     M 1.3          (kingdon  06-Sep-97): hello 
    #     ok
    my ($lineNr) = 0;
    if ($annTable) {
	print "<table border=0 cellspacing=0 cellpadding=0>\n";
    }
    else {
	print "<pre>";
    }
    while (<Reader>) {
	@words = split;
	# Adding one is for the (single) space which follows $words[0].
	$rest = substr ($_, length ($words[0]) + 1);
	if ($words[0] eq "E") {
	    next;
	} elsif ($words[0] eq "M") {
	    $lineNr++;
	    $lrev = substr ($_, 2, 13);
	    $lusr = substr ($_, 16,  9);
	    $line = substr ($_, 36);
	    # we should parse the date here ..
	    if ($lrev eq $oldLrev) {
		$revprint = "             ";
	    } else { $revprint = $lrev; $oldLusr = "";}
	    if ($lusr eq $oldLusr) {
		$usrprint = "         ";
	    } else { $usrprint = $lusr; }
	    $oldLrev = $lrev;
	    $oldLusr = $lusr;
	    # is there a less timeconsuming way to strip spaces ?
	    ($lrev = $lrev) =~ s/\s+//g;
	    $isCurrentRev = ("$rev" eq "$lrev");
	    
	    print "<b>" if ($isCurrentRev);
	    printf ("%8s%s%8s %4d:", $revprint, ($isCurrentRev ? "|" : " "), $usrprint, $lineNr);
	    print htmlify($line);
	    print "</b>" if ($isCurrentRev);
	    print "<br>";	   
	} elsif ($words[0] eq "ok") {
	    # We could complain about any text received after this, like the
	    # CVS command line client.  But for simplicity, we don't.
	} elsif ($words[0] eq "error") {
	    fatal ("500 Internal Error", "Error occured during annotate: <b>$_</b>");
	}
    }
    if ($annTable) {
	print "</table>";
    } else {
	print "</pre>";
    }
    close (Reader) || warn "cannot close: $!";
}

sub doCheckout {
    local($fullname, $rev) = @_;
    # this may not be quoted with single quotes
    # in windows .. but should in U*nx. there
    # is a function which allows for quoting `evil` 
    # characters, I know.
    open(RCS, "co -p$rev '$fullname' 2>&1 |") ||
	&fail("500 Internal Error", "Couldn't co: $!");
# /home/ncvs/src/sys/netinet/igmp.c,v  -->  standard output
# or
# /home/ncvs/src/sys/netinet/igmp.c,v  -->  stdout
# revision 1.1.1.2
    $_ = <RCS>;
    if (/^(.+),v\s+-->\s+st(andar)?d ?out(put)?\s*$/o && $1 eq $fullname) {
	# As expected
    } else {
	&fatal("500 Internal Error",
	       "Unexpected output from co: $_");
    }
    $_ = <RCS>; # discard line - no revision check
    $| = 1;

# get mimetype
    if (defined $input{"content-type"} && ($input{"content-type"} =~ /\S\/\S/)) {
	$mimetype=$input{"content-type"}
    }
    else {
	$mimetype = &getMimeTypeFromSuffix($fullname);
    }
    print "Content-type: $mimetype\n\n";
    print <RCS>;
    close(RCS);
}

sub doDiff {
	local($fullname, $r1, $tr1, $r2, $tr2, $f) = @_;

	if ($r1 =~ /([^:]+)(:(.+))?/) {
	    $rev1 = $1;
	    $sym1 = $3;
	}
	if ($rev1 eq 'text') {
	    $rev1 = $tr1;
	}
	if ($r2 =~ /([^:]+)(:(.+))?/) {
	    $rev2 = $1;
	    $sym2 = $3;
	}
	if ($rev2 eq 'text') {
	    $rev2 = $tr2;
	}
	# make sure the revisions a wellformed, for security
	# reasons ..
	if (!($rev1 =~ /^[\d\.]+$/) || !($rev2 =~ /^[\d\.]+$/)) {
	    &fatal("404 Not Found",
		    "Malformed query \"$ENV{'QUERY_STRING'}\"");
	}
#
# rev1 and rev2 are now both numeric revisions.
# Thus we do a DWIM here and swap them if rev1 is after rev2.
# XXX should we warn about the fact that we do this?
	if (&revcmp($rev1,$rev2) > 0) {
	    ($tmp1, $tmp2) = ($rev1, $sym1);
	    ($rev1, $sym1) = ($rev2, $sym2);
	    ($rev2, $sym2) = ($tmp1, $tmp2);
	}
#
#	XXX Putting '-p' here is a personal preference
	$human_readable = 0;
	if ($f eq 'c') {
	    $difftype = '-p -c';
	    $diffname = "Context diff";
	} elsif ($f eq 's') {
	    $difftype = '--side-by-side --width=164';
	    $diffname = "Side by Side";
	} elsif ($f eq 'h') {
	    $difftype = '-u';
	    $human_readable = 1;
	} elsif ($f eq 'u') {
	    $difftype = '-p -u';
	    $diffname = "Unidiff";
	} else {
	    $human_readable = $hr_default;
	    $difftype = '-u';
	    $diffname = "Unidiff";
	}

	# apply special options
	if ($human_readable) {
	    if ($hr_funout) {
		$difftype = $difftype . ' -p';
	    }
	    if ($hr_ignwhite) {
		$difftype = $difftype . ' -w';
	    }
	    if ($hr_ignkeysubst) {
		$difftype = $difftype . ' -kk';
	    }
	    $diffname = "Human readable";
	}
	
# XXX should this just be text/plain
# or should it have an HTML header and then a <pre>
	open(RCSDIFF, "rcsdiff $difftype -r$rev1 -r$rev2 '$fullname' 2>&1 |") 
	    || &fail("500 Internal Error", "Couldn't rcsdiff: $!");
	if ($human_readable) {
	    print "Content-type: text/html\n\n";
	    &human_readable_diff($rev2);
	    exit;
	} else {
	    print "Content-type: text/plain\n\n";
	}
#
#===================================================================
#RCS file: /home/ncvs/src/sys/netinet/tcp_output.c,v
#retrieving revision 1.16
#retrieving revision 1.17
#diff -c -r1.16 -r1.17
#*** /home/ncvs/src/sys/netinet/tcp_output.c     1995/11/03 22:08:08     1.16
#--- /home/ncvs/src/sys/netinet/tcp_output.c     1995/12/05 17:46:35     1.17
#
# Ideas:
# - nuke the stderr output if it's what we expect it to be
# - Add "no differences found" if the diff command supplied no output.
#
#*** src/sys/netinet/tcp_output.c     1995/11/03 22:08:08     1.16
#--- src/sys/netinet/tcp_output.c     1995/12/05 17:46:35     1.17 RELENG_2_1_0
# (bogus example, but...)
#
	if ($difftype eq '-u') {
	    $f1 = '---';
	    $f2 = '\+\+\+';
	} else {
	    $f1 = '\*\*\*';
	    $f2 = '---';
	}
	while (<RCSDIFF>) {
	    if (m|^$f1 $cvsroot|o) {
		s|$cvsroot/||o;
		if ($sym1) {
		    chop;
		    $_ .= " " . $sym1 . "\n";
		}
	    } elsif (m|^$f2 $cvsroot|o) {
		s|$cvsroot/||o;
		if ($sym2) {
		    chop;
		    $_ .= " " . $sym2 . "\n";
		}
	    }
	    print $_;
	}
	close(RCSDIFF);
}

sub getDirLogs {
    local  ($DirName) = @_;
    my ($state);

    open(RCS, "rlog -r $DirName/*,v 2>/dev/null |")  || &fatal("500 Internal Error",
				       			"Failed to spawn rlog");
    $state = 0;
    while (<RCS>) {
	if ($state==0 && /Working file: (.+)$/) {
	    $filename=$1;
	    $state=1;
	}
	if ($state==1 && /head: (.+)$/) {
	    $head=$1;
	    $state=2;
	}
	if ($state==2 && (m|^date:\s+(\d+)/(\d+)/(\d+)\s+(\d+):(\d+):(\d+);|)) {
	    $yr = $1;
            # damn 2-digit year routines :-)
            if ($yr > 100) {
                $yr -= 1900;
            }
	    $date = &Time::Local::timegm($6,$5,$4,$3,$2 - 1,$yr);
	    $state=3;
	    $log='';
	    next;
	}
	if ($state==3 && /^=============/) {
	    @finfo = ($head,$date,$log);
	    $fileinfo{$filename}=[ @finfo ];
	    $state=0;
	}
	if ($state==3) {
	    $log = $log . $_;
	}
    }
}

sub doLog {
	local($fullname) = @_;
	local($curbranch,$symnames);	#...

	print("Going to rlog '$fullname'\n") if ($verbose);
	open(RCS, "rlog '$fullname'|") || &fatal("500 Internal Error",
						"Failed to spawn rlog");

	while (<RCS>) {
	    print if ($verbose);
	    if (/^branch:\s+([\d\.]+)/) {
		$curbranch = $1;
	    }
	    if ($symnames) {
		if (/^\s+([^:]+):\s+([\d\.]+)/) {
		    $symrev{$1} = $2;
		    if ($revsym{$2}) {
			$revsym{$2} .= ", ";
		    }
		    $revsym{$2} .= $1;
		} else {
		    $symnames = 0;
		}
	    } elsif (/^symbolic names/) {
		$symnames = 1;
	    } elsif (/^-----/) {
		last;
	    }
	}

	if ($onlyonbranch = $input{'only_on_branch'}) {
	    ($onlyonbranch = $symrev{$onlyonbranch}) =~ s/\.0\././;
	    ($onlybranchpoint = $onlyonbranch) =~ s/\.\d+$//;
	}

# each log entry is of the form:
# ----------------------------
# revision 3.7.1.1
# date: 1995/11/29 22:15:52;  author: fenner;  state: Exp;  lines: +5 -3
# log info
# ----------------------------
	logentry:
	while (!/^=========/) {
	    $_ = <RCS>;
	    last logentry if (!defined($_));	# EOF
	    print "R:", $_ if ($verbose);
	    if (/^revision ([\d\.]+)/) {
		$rev = $1;
	    } elsif (/^========/ || /^----------------------------$/) {
		next logentry;
	    } else {
		# The rlog output is syntactically ambiguous.  We must
		# have guessed wrong about where the end of the last log
		# message was.
		# Since this is likely to happen when people put rlog output
		# in their commit messages, don't even bother keeping
		# these lines since we don't know what revision they go with
		# any more.
		next logentry;
#		&fatal("500 Internal Error","Error parsing RCS output: $_");
	    }
	    $_ = <RCS>;
	    print "D:", $_ if ($verbose);
	    if (m|^date:\s+(\d+)/(\d+)/(\d+)\s+(\d+):(\d+):(\d+);\s+author:\s+(\S+);\s+state:\s+(\S+);\s+(lines:\s+([0-9\s+-]+))?|) {
		$yr = $1;
                # damn 2-digit year routines :-)
                if ($yr > 100) {
                    $yr -= 1900;
                }
		$date{$rev} = &Time::Local::timegm($6,$5,$4,$3,$2 - 1,$yr);
		$author{$rev} = $7;
		$state{$rev} = $8;
		$difflines{$rev} = $10;
	    } else {
		&fatal("500 Internal Error", "Error parsing RCS output: $_");
	    }
	    line:
	    while (<RCS>) {
		print "L:", $_ if ($verbose);
		next line if (/^branches:\s/);
		last line if (/^----------------------------$/ || /^=========/);
		$log{$rev} .= $_;
	    }
	    print "E:", $_ if ($verbose);
	}
	close(RCS);
	print "Done reading RCS file\n" if ($verbose);
#
# Sort the revisions into commit-date order.
	@revorder = sort {$date{$b} <=> $date{$a}} keys %date;
	print "Done sorting revisions\n" if ($verbose);
#
# HEAD is an artificial tag which is simply the highest tag number on the main
# branch, unless there is a branch tag in the RCS file in which case it's the
# highest revision on that branch.  Find it by looking through @revorder; it
# is the first commit listed on the appropriate branch.
	$headrev = $curbranch || "1";
	revision:
	for ($i = 0; $i <= $#revorder; $i++) {
	    if ($revorder[$i] =~ /^(\S*)\.\d+$/ && $headrev eq $1) {
		if ($revsym{$revorder[$i]}) {
		    $revsym{$revorder[$i]} .= ", ";
		}
		$revsym{$revorder[$i]} .= "HEAD";
		$symrev{"HEAD"} = $revorder[$i];
		last revision;
	    }
	}
	print "Done finding HEAD\n" if ($verbose);
#
# Now that we know all of the revision numbers, we can associate
# absolute revision numbers with all of the symbolic names, and
# pass them to the form so that the same association doesn't have
# to be built then.
#
# should make this a case-insensitive sort
	foreach (sort keys %symrev) {
	    $rev = $symrev{$_};
	    if ($rev =~ /^(\d+(\.\d+)+)\.0\.(\d+)$/) {
		push(@branchnames, $_);
		#
		# A revision number of A.B.0.D really translates into
		# "the highest current revision on branch A.B.D".
		#
		# If there is no branch A.B.D, then it translates into
		# the head A.B .
		#
		$head = $1;
		$branch = $3;
		$regex = $head . "." . $branch;
		$regex =~ s/\./\./g;
		#             <
		#           \____/
		$rev = $head;

		revision:
		foreach $r (@revorder) {
		    if ($r =~ /^${regex}/) {
			$rev = $head . "." . $branch;
			last revision;
		    }
		}
		$revsym{$rev} .= ", " if ($revsym{$rev});
		$revsym{$rev} .= $_;
		if ($rev ne $head) {
		    $branchpoint{$head} .= ", " if ($branchpoint{$head});
		    $branchpoint{$head} .= $_;
		}
	    }
	    $sel .= "<OPTION VALUE=\"${rev}:${_}\">$_\n";
	}
	print "Done associating revisions with branches\n" if ($verbose);
        print &html_header("CVS log for $where");
	($upwhere = $where) =~ s|(Attic/)?[^/]+$||;
        ($filename = $where) =~ s|^.*/||;
        $backurl = $scriptname . "/" . urlencode($upwhere) . $query;
	print &link($backicon, "$backurl#$filename"),
              " <b>Up to ", &clickablePath($upwhere, 1), "</b><p>\n";
	print "<A HREF=\"#diff\">Request diff between arbitrary revisions</A>\n";
	print "<HR NOSHADE SIZE=1>\n";
	if ($curbranch) {
	    print "Default branch is ";
	    print ($revsym{$curbranch} || $curbranch);
	} else {
	    print "No default branch";
	}
	print "<BR>\n";
# The other possible U.I. I can see is to have each revision be hot
# and have the first one you click do ?r1=foo
# and since there's no r2 it keeps going & the next one you click
# adds ?r2=foo and performs the query.
# I suppose there's no reason we can't try both and see which one
# people prefer...

        $mimetype = &getMimeTypeFromSuffix ($fullname);
        $defaultTextPlain = ($mimetype eq "text/plain");
	for ($i = 0; $i <= $#revorder; $i++) {
	    $_ = $revorder[$i];
	    ($br = $_) =~ s/\.\d+$//;
	    next if ($onlyonbranch && $br ne $onlyonbranch &&
					    $_ ne $onlybranchpoint);
	    print "<a NAME=\"rev$_\"></a>";
	    print "<HR NOSHADE SIZE=1>";
	    foreach $sym (split(", ", $revsym{$_})) {
		print "<a NAME=\"$sym\"></a>";
	    }
	    if ($revsym{$br} && !$nameprinted{$br}) {
		foreach $sym (split(", ", $revsym{$br})) {
		    print "<a NAME=\"$sym\"></a>";
		}
		$nameprinted{$br}++;
	    }
	    print "\n";
	    &download_link(urlencode($where), $_, $_);
	    if (not $defaultTextPlain) {
		print " / ";
		&download_link(urlencode($where), $_, "(as text)", 
			       "text/plain");
	    }
	    if ($allow_annotate) {
		print " - <a href=\"" . $scriptname . "/" . urlencode($where) . "?annotate=$_$barequery\">";
		print "annotate</a>";
	    }
	    if (/^1\.1\.1\.\d+$/) {
		print " <i>(vendor branch)</i>";
	    }
	    print " <i>" . scalar gmtime($date{$_}) . " UTC</i>; ";
	    print readableTime(time() - $date{$_},1) . " ago";
	    print " by ";
	    print "<i>" . $author{$_} . "</i>\n";
	    if ($revsym{$_}) {
		print "<BR>CVS Tags: <b>$revsym{$_}</b>";
	    }
	    if ($revsym{$br})  {
		if ($revsym{$_}) {
		    print "; ";
		} else {
		    print "<BR>";
		}
		print "Branch: <b>$revsym{$br}</b>\n";
	    }
	    if ($branchpoint{$_}) {
		if ($revsym{$br} || $revsym{$_}) {
		    print "; ";
		} else {
		    print "<BR>";
		}
		print "Branch point for: <b>$branchpoint{$_}</b>\n";
	    }
	    # Find the previous revision on this branch.
	    @prevrev = split(/\./, $_);
	    if (--$prevrev[$#prevrev] == 0) {
		# If it was X.Y.Z.1, just make it X.Y
		if ($#prevrev > 1) {
		    pop(@prevrev);
		    pop(@prevrev);
		} else {
		    # It was rev 1.1 (XXX does CVS use revisions
		    # greater than 1.x?)
		    if ($prevrev[0] != 1) {
			print "<i>* I can't figure out the previous revision! *</i>\n";
		    }
		}
	    }
	    if ($prevrev[$#prevrev] != 0) {
		$prev = join(".", @prevrev);
		if (/^1\.2$/) {
		    $prev = '1.1.1';
		}
		if ($difflines{$_}) {
		    print "<BR>Changed since <b>$prev</b>: $difflines{$_} lines";
		}
		print "<BR><A HREF=\"${scriptwhere}.diff?r1=$prev";
		print "&r2=$_" . $barequery . "\">Diffs to $prev</A>\n";
		if (!$hr_default) { # offer a human readable version if not default
		    print "&nbsp;&nbsp;[<A HREF=\"${scriptwhere}.diff?r1=$prev";
		    print "&r2=$_" . $barequery . "&f=h\">human readable</A>]\n";
		}
		#
		# Plus, if it's on a branch, and it's not a vendor branch,
		# offer to diff with the immediately-preceding commit if it
		# is not the previous revision as calculated above
		# and if it is on the HEAD (or at least on a higher branch)
		# (e.g. change gets committed and then brought
		# over to -stable)
		if (!/^1\.1\.1\.\d+$/ && ($i != $#revorder) &&
					($prev ne $revorder[$i+1])) {
		    @tmp1 = split(/\./, $revorder[$i+1]);
		    @tmp2 = split(/\./, $_);
		    if ($#tmp1 < $#tmp2) {
			print "; <A HREF=\"${scriptwhere}.diff?r1=$revorder[$i+1]";
			print "&r2=$_" . $barequery .
                            "\">Diffs to $revorder[$i+1]</A>\n";
			if (!$hr_default) { # offer a human readable version if not default
			    print "&nbsp;&nbsp;[<A HREF=\"${scriptwhere}.diff?r1=$revorder[$i+1]";
			    print "&r2=$_" . $barequery .
				"&f=h\">human readable</A>]\n";

			}

		    }
		}
	    }
	    if ($state{$_} eq "dead") {
		print "<BR><B><I>FILE REMOVED</I></B>\n";
	    }
	    print "<PRE>\n";
	    print &htmlify($log{$_}, 1);
	    print "</PRE>\n";
	}
	print "<A NAME=diff>\n";
        print "<HR NOSHADE SIZE=1>";
	print "This form allows you to request diff's between any two\n";
	print "revisions of a file.  You may select a symbolic revision\n";
	print "name using the selection box or you may type in a numeric\n";
	print "name using the type-in text box.\n";
	print "</A><P>\n";
	print "<FORM METHOD=\"GET\" ACTION=\"${scriptwhere}.diff\">\n";
        foreach (@usedvars) {
	    if ($input{$_}) {
		print "<INPUT TYPE=HIDDEN NAME=\"$_\" VALUE=\"$input{$_}\">\n";
	    }
	}
	print "<table cellspacing=0 cellpadding=0 border=0>\n";
	print "<tr><td>Diffs between</td><td>\n";
	print "<SELECT NAME=\"r1\">\n";
	print "<OPTION VALUE=\"text\" SELECTED>Use Text Field\n";
	print $sel;
	print "</SELECT>\n";
	print "<INPUT TYPE=\"TEXT\" SIZE=\"$inputTextSize\" NAME=\"tr1\" VALUE=\"$revorder[$#revorder]\">\n";
	print "</td></tr><tr><td>and </td><td>\n";
	print "<SELECT NAME=\"r2\">\n";
	print "<OPTION VALUE=\"text\" SELECTED>Use Text Field\n";
	print $sel;
	print "</SELECT>\n";
	print "<INPUT TYPE=\"TEXT\" SIZE=\"$inputTextSize\" NAME=\"tr2\" VALUE=\"$revorder[0]\">\n";
	print "</td></tr></table>\n";
        print "<BR>Type of Diff should be a&nbsp;";
        print "<SELECT NAME=\"f\">";
        print "<option value=h selected>Colored Diff</option>";
        print "<option value=u>Unidiff</option>";
        print "<option value=c>Context Diff</option>";
        print "</SELECT>";
	print "<INPUT TYPE=SUBMIT VALUE=\"  Get Diffs  \">\n";
	print "</FORM>\n";
        if (@branchnames) {
	    print "<HR noshade size=1>\n";
	    print "<A name=branch>\n";
	    print "You may select to see revision information from only\n";
	    print "a single branch.\n";
	    print "</A><P>\n";
	    print "<FORM METHOD=\"GET\" ACTION=\"$scriptwhere\">\n";
	    foreach (@usedvars) {
		if ($input{$_}) {
		    print "<INPUT TYPE=HIDDEN NAME=\"$_\" VALUE=\"$input{$_}\">\n";
		}
	    }
	    print "Branch: \n";
	    print "<SELECT NAME=\"only_on_branch\">\n";
	    print "<OPTION VALUE=\"\"";
	    print " SELECTED" if ($input{"only_on_branch"} eq "");
	    print ">Show all branches\n";
	    foreach (sort @branchnames) {
		print "<OPTION";
		print " SELECTED" if ($input{"only_on_branch"} eq $_);
		print ">${_}\n";
	    }
	    print "</SELECT>\n";
	    print "<INPUT TYPE=SUBMIT VALUE=\"  View Branch  \">\n";
	    print "</FORM>\n";
	}
        print &html_footer;
	# print "</BODY></HTML>\n";
}

sub flush_diff_rows ($$$$)
{
    local $j;
    my ($leftColRef,$rightColRef,$leftRow,$rightRow) = @_;
    if ($state eq "PreChangeRemove") {          # we just got remove-lines before
      for ($j = 0 ; $j < $leftRow; $j++) {
          print  "<tr><td bgcolor=\"$diffcolorRemove\">@$leftColRef[$j]</td>";
          print  "<td bgcolor=\"$diffcolorEmpty\">&nbsp;</td></tr>\n";
      }
    }
    elsif ($state eq "PreChange") {             # state eq "PreChange"
      # we got removes with subsequent adds
      for ($j = 0; $j < $leftRow || $j < $rightRow ; $j++) {  # dump out both cols
          print  "<tr>";
          if ($j < $leftRow) { print  "<td bgcolor=\"$diffcolorChange\">@$leftColRef[$j]</td>"; }
          else { print  "<td bgcolor=\"$diffcolorDarkChange\">&nbsp;</td>"; }
          if ($j < $rightRow) { print  "<td bgcolor=\"$diffcolorChange\">@$rightColRef[$j]</td>"; }
          else { print  "<td bgcolor=\"$diffcolorDarkChange\">&nbsp;</td>"; }
          print  "</tr>\n";
      }
    }
}

##
# Function to generate Human readable diff-files
# human_readable_diff(String revision_to_return_to);
##
sub human_readable_diff($){
  local ($ii,$difftxt, $where_nd, $filename, $pathname);
  my ($rev) = @_;

  ($where_nd = $where) =~ s/.diff$//;
  ($filename = $where_nd) =~ s/^.*\///;
  ($pathname = $where_nd) =~ s/(Attic\/)?[^\/]*$//;
  ($scriptwhere_nd = $scriptwhere) =~ s/.diff$//;

  navigateHeader ($scriptwhere_nd, $pathname, $filename, $rev);

  print  "<center><font face=\"Arial,Helvetica\" size=+2><b>Human Readable Diff<br>for file /$where_nd<br>between revision $rev1 and $rev2</b></font></center>\n";
  print  "<p>\n";

  print  "<table border=0 cellspacing=0 cellpadding=0 width=100%>\n";
  print  "<tr bgcolor=#ffffff><th width=\"50%\">version $rev1</th><th witdh=\"50%\">version $rev2</th></tr>";

  $fs="<font face=\"$difffontface\" size=\"$difffontsize\">";
  $fe="</font>";

  $leftRow = 0;
  $rightRow = 0;
  
  while (<RCSDIFF>) {
      next unless $. > 7;

      $difftxt = $_;
      
      if ($difftxt =~ /^@@/) {
	  ($oldline,$newline,$funname) = $difftxt =~ /@@ \-([0-9]+).*\+([0-9]+).*@@(.*)/;
          print  "<tr bgcolor=\"$diffcolorHeading\"><td width=\"50%\">";
	  print  "<table width=100% border=2 cellpadding=1><tr><td><b>Line $oldline</b>";
	  print  "&nbsp;<font size=-1>$funname</font></td></tr></table>";
          print  "</td><td width=\"50%\">";
	  print  "<table width=100% border=2 cellpadding=1><tr><td><b>Line $newline</b>";
	  print  "&nbsp;<font size=-1>$funname</font></td></tr></table>";
	  print  "</td><tr>\n";
	  $state = "dump";
	  $leftRow = 0;
	  $rightRow = 0;
      }
      else {
	  ($diffcode,$rest) = $difftxt =~ /^([-+ ])(.*)/;
	  $_= spacedHtmlText ($rest);
	  
	  # Add fontface, size
	  $_ = "$fs&nbsp;$_$fe";
	  
	  #########
	  # little state machine to parse unified-diff output (Hen, zeller@think.de)
	  # in order to get some nice 'ediff'-mode output
	  # states:
	  #  "dump"             - just dump the value
	  #  "PreChangeRemove"  - we began with '-' .. so this could be the start of a 'change' area or just remove
	  #  "PreChange"        - okey, we got several '-' lines and moved to '+' lines -> this is a change block
	  ##########

	  if ($diffcode eq '+') {
	      if ($state eq "dump") {  # 'change' never begins with '+': just dump out value
		  print  "<tr><td bgcolor=\"$diffcolorEmpty\">&nbsp;</td><td bgcolor=\"$diffcolorAdd\">$_</td></tr>\n";
	      }
	      else {                   # we got minus before
		  $state = "PreChange";
		  $rightCol[$rightRow++] = $_;
	      }
	  } 
	  elsif ($diffcode eq '-') {
	      $state = "PreChangeRemove";
	      $leftCol[$leftRow++] = $_;
        }
        else {  # empty diffcode
            flush_diff_rows \@leftCol, \@rightCol, $leftRow, $rightRow;
	      print  "<tr><td>$_</td><td>$_</td></tr>\n";
	      $state = "dump";
	      $leftRow = 0;
	      $rightRow = 0;
	  }
      }
  }
  flush_diff_rows \@leftCol, \@rightCol, $leftRow, $rightRow;

  # state is empty if we didn't have any change
  if (!$state) {
      print "<tr><td colspan=2>&nbsp;</td></tr>";
      print "<tr bgcolor=\"$diffcolorEmpty\" >";
      print "<td colspan=2 align=center><b>- No viewable Change -</b></td></tr>";
  }
  print  "</table>";
  close(<RCSDIFF>);

  # print legend
  print  "<br><hr noshade size=1 width=100%><table border=1><tr><td>";
  print  "Legend:<br><table border=0 cellspacing=0 cellpadding=1>\n";
  print  "<tr><td align=center bgcolor=\"$diffcolorRemove\">Removed in v.$rev1</td><td bgcolor=\"$diffcolorEmpty\">&nbsp;</td></tr>";
  print  "<tr bgcolor=\"$diffcolorChange\"><td align=center colspan=2>changed lines</td></tr>";
  print  "<tr><td bgcolor=\"$diffcolorEmpty\">&nbsp;</td><td align=center bgcolor=\"$diffcolorAdd\">Added in v.$rev2</td></tr>";
  print  "</table></td></tr></table>\n";
  print  "</body>\n</html>\n";
}

sub spacedHtmlText ($) {
    my ($x) = @_;
    $_ = $x;
########
# quote special characters
# according to RFC 1866,Hypertext Markup Language 2.0,
# 9.7.1. Numeric and Special Graphic Entity Set
# (Hen)
#######
    s/&/&amp;/g;
    s/\"/&quot;/g; 
    s/</&lt;/g; 
    s/>/&gt;/g; 
    
    # replace <tab> and <space>
    if ($hr_breakable) {
	# make every other space 'breakable'
	      s/	/&nbsp; &nbsp; &nbsp; &nbsp; /g;    # <tab>
	      s/   /&nbsp; &nbsp;/g;                        # 3 * <space>
	      s/  /&nbsp; /g;                               # 2 * <space>
	      # leave single space as it is
	  }
    else {
	s/	/&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;/g; 
	s/ /&nbsp;/g;
    }
    return $_;
}

sub navigateHeader ($$$$) {
    my ($swhere,$path,$filename,$rev)=@_;
    print "<HTML>\n<HEAD>\n";
    print '<!-- $Revision: 1.1 $ -->';
    print "\n<TITLE>$path</TITLE></HEAD>\n";
    print  "<BODY BGCOLOR=\"$backcolor\">\n";
    #print "<table width=\"100%\" border=0 cellspacing=0 cellpadding=1 bgcolor=\"$navigationHeaderColor\">";
    #print "<tr valign=bottom><td>";
    print  "<a href=\"$swhere$query#rev$rev\">$backicon";
    print "</a> <b>Return to ", &link("$filename","$swhere$query#rev$rev")," CVS log";
    #print "</b> $fileicon</td>";
    
    #print "<td align=right>$diricon <b>Up to ", &clickablePath($path, 1), "</b></td>";
    #print "</tr></table>";
}

sub plural_write ($$)
{
    my ($num,$text) = @_;
    if ($num != 1) {
	$text = $text . "s";
    }
    if ($num > 0) {
	return $num . " " . $text;
    } else {
	return "";
    }
}

##
# print readable timestamp in terms of
# '..time ago'
# H. Zeller <zeller@think.de>
##
sub readableTime ($$)
{
    local ($i, $break, $retval);
    my ($secs,$long) = @_;

    # this function works correct for time >= 2 seconds
    if ($secs < 2) {
	return "very little time";
    }

    local %desc = (1 , 'second',
		   60, 'minute',
		   3600, 'hour',
		   86400, 'day',
		   604800, 'week',
		   2628000, 'month',
		   31536000, 'year');
    local @breaks = sort {$a <=> $b} keys %desc;
    $i = 0;
    while ($i <= $#breaks && $secs >= 2 * $breaks[$i]) { 
	$i++;
    }
    $i--;
    $break = $breaks[$i];
    $retval = plural_write(int ($secs / $break), $desc{"$break"});

    if ($long==1 && $i > 0) {
	local $rest = $secs % $break;
	$i--;
	$break = $breaks[$i];
	$resttime = plural_write(int ($rest / $break), 
				$desc{"$break"});
	if ($resttime) {
	    $retval = $retval . ", " . $resttime;
	}
    }

    return $retval;
}

##
# clickablePath(String pathname, boolean last_item_clickable)
#
# returns a html-ified path whereas each directory is a link for
# faster navigation. last_item_clickable controls whether the
# basename (last directory/file) is a link as well
##
sub clickablePath($$) {
    my ($pathname,$clickLast) = @_;    
    local $retval = '';
    
    if ($pathname eq '') {
	# this should never happen - chooseCVSRoot() is
	# intended to do this
	$retval = "[$cvstree]";
    } else {
	$retval = $retval . " <a href=\"${scriptname}${query}\">[$cvstree]</a>";
	$wherepath = '';
	foreach (split(/\//, $pathname)) {
	    $retval = $retval . " / ";
	    $wherepath = $wherepath . '/' . $_;
	    if ($clickLast || $wherepath ne "/$pathname") {
		$retval = $retval . "<a href=\"${scriptname}" . urlencode($wherepath) . "${query}\">$_</a>";
	    } else { # do not make a link to the current dir
		$retval = $retval .  $_;
	    }
	}
    }
    return $retval;
}

sub chooseCVSRoot() {
    print "<form method=\"GET\" action=\"${scriptwhere}\">\n";
    if ((keys %CVSROOT) > 1) {
	foreach $k (keys %input) {
	    print "<input type=hidden NAME=$k VALUE=$input{$k}>\n" 
		if ($input{$k}) && ($k ne "cvsroot");
	}
	# Form-Elements look wierd in Netscape if the background
	# isn't gray and the form elements are not placed
	# within a table ...
	print "<table><tr>";
	print "<td>CVS Root:</td>";
	print "<td>\n<select name=\"cvsroot\"";
	print " onchange=\"submit()\"" if $use_java_script;
	print ">\n";
	foreach $k (sort keys %CVSROOT) {
	    print "<option";
	    print " selected" if ("$k" eq "$cvstree");
	    print ">" . $k . "</option>\n";
	}
	print "</select>\n</td>";
	print "<td><input type=submit value=\"Go\"></td>";
	print "</tr></table></form>";
    }
    else {
	# no choice ..
	print "CVS Root: <b>[$cvstree]</b>";
    }
}

sub fileSortCmp {
    my ($comp)=0;
    my ($c,$d,$af,$bf);

    if ($bydate==1) {
	($af=$a) =~ s/,v$//;
	($bf=$b) =~ s/,v$//;
	my ($head1,$date1,$log1)=@{$fileinfo{$af}};
	my ($head2,$date2,$log2)=@{$fileinfo{$bf}};
	if ($date1  && $date2) {
	    $comp = ($date2 <=> $date1);
	}
    }
    if ($comp == 0) {
	$ad=((-d "$fullname/$a")?"D":"F");
	$bd=((-d "$fullname/$b")?"D":"F");
	($c=$a)=~s|.*/||;
	($d=$b)=~s|.*/||;
	$comp = ("$ad$c" cmp "$bd$d");
    }
    return $comp;
}

# Presents a link to download the 
# selected revision
sub download_link () {
    my ($url,$revision,$textlink,$mimetype) = @_;
    my ($fullurl) = "$scriptname/$checkoutMagic/" . $url;
    print "<A HREF=\"$fullurl";
    print "?rev=$revision";
    print "&content-type=$mimetype" if ($mimetype);
    print $barequery . "\"";
    if ($open_extern_window) {
	print " target=\"cvs_checkout\"";
	# we should have
	#   'if (document.cvswin==null) document.cvswin=window.open(...'
	# in order to allow the user to resize the window; otherwise
	# the user may resize the window, but on next checkout - zap -
	# it's original (configured s. cvsweb.conf) size is back again
	# .. annoying (if $extern_window_(width|height) is defined)
	# but this if (..) solution is far from perfect
	# what we need to do as well is
	# 1) save cvswin in an invisible frame that always exists
	#    (document.cvswin will be void on next load)
	# 2) on close of the cvs_checkout - window set the cvswin
	#    variable to 'null' again - so that it will be
	#    reopenend with the configured size
	# anyone a JavaScript programmer ?
	# .. so here without if (..):
	# currently, the best way is to comment out the size parameters
	# ($extern_window...) in cvsweb.conf.
	if ($use_java_script) {
	    print " onClick=\"window.open('$fullurl','cvs_checkout',";
	    print "'resizeable,toolbar,scrollbars";
	    print ",width=$extern_window_width" if (defined ($extern_window_width));
	    print ",height=$extern_window_height" if (defined ($extern_window_height));
	    print"');\"";
	}
    }
    print "><b>$textlink</b></A>";
}

# Returns a Query string with the
# specified parameter toggled
sub toggleQuery($) {
    my ($newquery,$namval,$value);
    foreach (@usedvars) {
	if (defined $input{$_}) {
	    if ($newquery) {
		$newquery = $newquery . "&";
	    }
	    $value = $input{$_};
	    if ("$_" eq "@_") {
		$value = ($value) ? 0 : 1;
	    }
	    $namval = urlencode($_) . "=" . urlencode($value);
	    $newquery = $newquery  . $namval;
	}
    }
    return $newquery;
}

sub urlencode {
    my ($in) = @_;
    my ($out);
    ($out=$in)=~s/([\000-+{-\377])/sprintf("%%%02x", ord($1))/ge;
    return $out;
}

sub cvsroot {
    return '' if $cvstree eq $cvstreedefault;
    return "&cvsroot=" . $cvstree;
}

sub html_header {
    local ($title) = @_;
	my ($p);
    $p = "Content-type: text/html\n\n";

    if (-f $page_head) {
		open(FP, "<$page_head");
		$p .= $_ while(<FP>);
		close(FP);
	}
	else {
		$p .=
		"<html>\n<title>$title</title>\n" .
		'<!-- henCVSweb $Revision: 1.1 $ -->' .
		"\n</head>\n$body_tag\n" .
		"$logo <h1 align=center>$title</h1>\n";
	}
    return $p;
}


sub html_footer {
	my ($p);

    $p = '';
    if (-f $page_foot) {
		open(FP, "<$page_foot");
		$p .= $_ while(<FP>);
		close(FP);
	}
	else {
        $p = "<hr><address>$address</address>\n" .
		     "</body></html>\n";
	}
	return $p;
}

