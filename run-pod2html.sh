#! /bin/sh
SRC=$1
DEST=docs
HERE=`/bin/pwd`

for SUB in apps crypto ssl; do
    DIR=$DEST/$SUB
    rm -rf $DIR
    mkdir -p $DIR
    for IN in $SRC/$SUB/*.pod; do
	FN=`basename $IN .pod`
	cat $IN \
	| sed -r 's/L<([^)]*)(\([0-9]\))?\|([^)]*)(\([0-9]\))?>/L<\1|\3>/g' \
	| pod2html --podroot=$SRC --htmlroot=/docs --podpath=$SUB:apps:crypto:ssl \
	| sed -r 's/<!DOCTYPE.*//g' > $DIR/$FN.html
	for L in `perl $HERE/getnames.pl $IN` ; do
	    ln $DIR/$FN.html $DIR/$L.html || echo FAIL $DIR/$FN.html $DIR/$L.html
	done
    done
done
