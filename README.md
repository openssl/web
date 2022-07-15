# OpenSSL web pages

OpenSSL web page sources are written in [Markdown], and possibly templated
further using [Template Toolkit].

Plain Markdown files must have the filename suffix `.md`.\
Templated Markdown files must have the filename suffix `.md.tt`.

For page breadcrumbs purposes, every Markdown file must start with the
following YAML section, where `{name}` is replaced with the name this file
shall have in its part of the breadcrumbs:

``` yaml
---
breadcrumb: {name}
---
```

In each directory where there are Markdown files, there must also be a file
`dirdata.yaml`, containing common data for that directory, which affects the
rendering of the sidebar and the common page breadcrumbs (the `breadcrumb`
value in each file will be appended to them).  For example, in the directory
`examples/`, one might imagine a `examples/dirdata.yaml` looking like this:

``` yaml
---
breadcrumbs: |
  [Home](..) : [Examples](.)
sidebar: |
  # Examples

  -   [One example](example1.html)
  -   [Another example](example2.html)
---
```

Please remember that all YAML *must* start and end with tripple dash lines
(`---`).

Recommendations
---------------

-   Let [Markdown guide] be your guide for writing Markdown files.
    The [Markdown guide extended syntax] adds a lot of useful
    possibilities.

    *If there's an alternative* that [Github Flavored Markdown]
    understands, use that, as that makes reviewing easier.

    If there's a need that isn't covered by the [Markdown guide],
    refer to the [Pandoc User's Guide], or use HTML, whichever is
    clearer.

-   Surround any table with `<p>` and `</p>`, to make it distinct from
    paragraphs around it.

Building
--------

The Markdown files are rendered into HTML using [Pandoc], see the
[Pandoc User's Guide] for information on the Markdown syntax it
understands and support.

Building the web pages is done through the `Makefile`, and requires
a number of programs to be installed:

-   [Template Toolkit].  The Debian package is `libtemplate-perl`
-   [Pandoc].  The Debian package is `pandoc`
-   git

It also requires a checkout of a number of repositories and branches.  Some
of the repositories may need specific access.  The `Makefile` requires that
they are all collected under one checkouts directory, with the following
layout:

-   `data` (checkout of the `omc/data` repository)
-   `general-policies`
    (checkout of <https://github.com/openssl/general-policies.git>)
-   `technical-policies`
    (checkout of <https://github.com/openssl/technical-policies.git>)
-   `openssl`
    (checkout of <https://github.com/openssl/openssl.git>,
    `master` branch)
-   `openssl-3.0`
    (checkout of <https://github.com/openssl/openssl.git>,
    `openssl-3.0` branch)
-   `openssl-1.1.1-stable`
    (checkout of <https://github.com/openssl/openssl.git>,
    `OpenSSL_1_1_1-stable` branch)

The checkouts directory can be given to `make` with the `CHECKOUTS`
variable:

``` console
$ make CHECKOUTS=/PATH/TO/checkouts
```

[Template Toolkit]: http://www.template-toolkit.org/
[Pandoc]: https://pandoc.org/
[Pandoc User's Guide]: https://pandoc.org/MANUAL.html#pandocs-markdown
[Markdown guide]: https://www.markdownguide.org
[Markdown guide extended syntax]: https://www.markdownguide.org/extended-syntax/
[Github Flavored Markdown]: https://github.github.com/gfm/
