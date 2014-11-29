#! /bin/sh
x=$1
for subdir in apps crypto ssl ; do
    mkdir -p docs/$subdir
    for I in $x/$subdir/*.pod ; do
	OUT=`basename $I .pod`
	sed -r 's/L<([^)]*)(\([0-9]\))?\|([^)]*)(\([0-9]\))?>/L<\1|\3>/g' <$I |
	pod2html > docs/$subdir/$OUT.html \
	    --podroot=$x "--htmlroot=/docs" \
	    "--podpath=apps:crypto:ssl"
    done
done
