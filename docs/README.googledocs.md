Converting word processing files from Google Docs to Markdown
=============================================================

Converting documents from Google Docs to anything other than what you
get with 'Files'->'Download as' or using an add-on is a bit of an
adventure.  All of them come with quirks.

Downloading and converting with pandoc
--------------------------------------

For simple documents, [pandoc](https://pandoc.org/) turns out to be
versatile enough to do a decent job that only requires small amounts
of post processing.

Experiments have shown that to convert a Google Docs wordprocessing
document to Markdown with pandoc, a download in ODT format gives the
cleanest results.  It still requires a little bit of editing, of which
some can be automated, using this script:

``` shell
#! /bin/sh

for f in "$@"; do
    b=`basename "$f" .odt`
    if [ "$f" != "$b" ]; then
        bns=`echo "$b" | sed -e 's|  *||g'`
        pandoc -t markdown --atx-headers --extract-media=media "$f" | perl -p -e '
BEGIN { $/ = ""; }
s|^\[\]\{#anchor-\d+\}|#!# |;
s|(\n\s*)> |$1|g;
' > "$bns.md"
        echo "'$bns.md' produced, make sure to edit the title page and the headings"
    fi
done
```

When an Markdown file has been produced, a litte bit of editing is
required.  A required thing is to look for all lines starting with
`#!#` and replace them with an appropriate number of `#` characters,
depending on the original heading's level.  ATX format headings are
used, since they allow more than 2 heading levels.

Try rendering the Markdown file using bin/md-to-html5, have a look at
the result.  If you're satisfied, commit the Markdown file and images,
and make appropiate changes in the top Makefile.  If not, make changes
in the Markdown file and try again.

Using an add-on in Google Docs and using the result
---------------------------------------------------

Unfortunately, it seems that there are things where Pandoc loses track
of what it's doing.  I have not analyzed if it's a pandoc bug or if
the ODT input was bad.  Also, pandoc isn't very good at recognising
code sections.

The other option is to use an add-on in Google Docs.  I've played with
[gd2md](https://github.com/evbacher/gd2md-html/wiki) with fairly
satisfactory results.

Things to be wary of with gd2md are:

-   It doesn't make a difference between ordered lists with numbers
    and ordered lists with letters, it makes them all numbered items.
-   It sometimes doesn't convert simple things, like headings, and
    leaves them as HTML
-   It sometimes leaves code as explicit HTML wrapped with \<code\>
-   It leaves tables in HTML form
-   You have to provide the images yourself
-   Internal links to bookmarks and headings are sometimes left with
    no corresponding anchor

All these things need to be looked after and edited into markdown.

Try rendering the Markdown file using bin/md-to-html5, have a look at
the result.  If you're satisfied, commit the Markdown file and images,
and make appropiate changes in the top Makefile.  If not, make changes
in the Markdown file and try again.
