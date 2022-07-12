---
breadcrumb: Downloads
---
# Downloads

The master sources are maintained in our [git repository](gitrepo.html),
which is accessible over the network and cloned on GitHub, at
<https://github.com/openssl/openssl>. Bugs and pull patches (issues and
pull requests) should be filed on the GitHub repo. Please familiarize
yourself with the [license](license.html).

The table below lists the latest releases for every branch. (For an explanation
of the numbering, see our [release strategy](/policies/releasestrat.html).)
All releases can be found at [/source/old](old). A list of mirror sites can be
found [here](mirror.html).

*Note:* The latest stable version is the 3.0 series supported until 7th
September 2026. This is also a Long Term Support (LTS) version. The
previous LTS version (the 1.1.1 series) is also available and is
supported until 11th September 2023. All older versions (including
1.1.0, 1.0.2, 1.0.0 and 0.9.8) are now out of support and should not be
used. Users of these older versions are encouraged to upgrade to 3.0 as
soon as possible. Extended support for 1.0.2 to gain access to security
fixes for that version is [available](/support/contracts.html).

OpenSSL 3.0 is the latest major version of OpenSSL. The OpenSSL FIPS
Object Module (FOM) 3.0 is an integrated part of the OpenSSL 3.0
download. You do not need to download the 3.0 FOM separately. Refer to
the installation instructions inside the download, and use the
"enable-fips" compile time configuration option to build it.

For an overview of some of the key concepts in OpenSSL 3.0 see the
libcrypto [manual
page](https://www.openssl.org/docs/man3.0/man7/crypto.html). Information
and notes about migrating existing applications to OpenSSL 3.0 are
available in the [OpenSSL 3.0 Migration
Guide](https://www.openssl.org/docs/man3.0/man7/migration_guide.html)

<p>
<table>
  <tr>
    <td>KBytes&nbsp;</td>
    <td>Date&nbsp;&nbsp;</td>
    <td>File&nbsp;</td>
  </tr>
  <!--#include virtual="index.inc" -->
</table>
</p>

When building a release for the first time, please make sure to look at
the INSTALL file in the distribution along with any NOTES file
applicable to your platform. If you have problems, look at the FAQ,
which can be found [online](/docs/faq.html). If you still need more
help, then join the [openssl-users](/community/mailinglists.html) email
list and post a question there.

PGP keys for the signatures are available from the
[OTC page](https://www.openssl.org/community/otc.html). Current members that
sign releases include Richard Levitte, Matt Caswell, Paul Dale, and Tomas Mraz.

Each day we make a snapshot of each development branch. They can be
found at <https://www.openssl.org/source/snapshot/>. These daily
snapshots of the source tree are provided for convenience only and not
even guaranteed to compile. Note that keeping a git local repository and
updating it every 24 hours is equivalent and will often be faster and
more efficient.

<!--#include virtual="/inc/legalities.shtml" -->
