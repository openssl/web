#! /bin/sh
SRC=$1
DEST=docs
HERE=`/bin/pwd`

# Somewhere between perl version 5.15 and 5.18, pod2html stopped extracting the
# title from the pod file's NAME section.  When that's the case, we need to do
# that work ourselves and give pod2html the extracted title with --title.  --title
# isn't available in earlier perl verions, so we need to test the behaviour to
# decide how to act.
#
extract_title=false
pod2html_testtext="=cut

=head1 NAME

foo - bar

=head1 SYNOPSIS
"
if echo "$pod2html_testtext" | pod2html | grep -q '^<title></title>$'; then
    extract_title=true
fi
#
# Test done.

for SUB in apps crypto ssl; do
    DIR=$DEST/$SUB
    rm -rf $DIR
    mkdir -p $DIR
    for IN in $SRC/$SUB/*.pod; do
	FN=`basename $IN .pod`
	title_arg=''
	if $extract_title; then
	    title_arg="--title=`cat $IN | sed -e '1,/^=head1 NAME/d' -e '/^=/,$d' -e '/^\s*$/d'`"
	fi
	cat $IN \
	| sed -r 's/L<([^)]*)(\([0-9]\))?\|([^)]*)(\([0-9]\))?>/L<\1|\3>/g' \
	| pod2html --podroot=$SRC --css=/manpage.css --htmlroot=/docs --podpath=$SUB:apps:crypto:ssl "$title_arg" \
	| sed -r 's/<!DOCTYPE.*//g' > $DIR/$FN.html
	for L in `perl $HERE/getnames.pl $IN` ; do
	    ln $DIR/$FN.html $DIR/$L.html || echo FAIL $DIR/$FN.html $DIR/$L.html
	done
    done
done
