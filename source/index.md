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

*Note:* The latest stable version is the 3.1 series supported until 14th March
2025. Also available is the 3.0 series which is a Long Term Support (LTS)
version and is supported until 7th September 2026. The previous LTS version (the
1.1.1 series) is also available and is supported until 11th September 2023. All
older versions (including 1.1.0, 1.0.2, 1.0.0 and 0.9.8) are now out of support
and should not be used. Users of these older versions are encouraged to upgrade
to 3.1 or 3.0 as soon as possible. Extended support for 1.0.2 to gain access to
security fixes for that version is [available](/support/contracts.html).


The following OpenSSL version(s) are FIPS validated:

&nbsp;OpenSSL Version&nbsp; | &nbsp;Certificate&nbsp; | &nbsp;Security Policy&nbsp;
:-: | :-: | :-:
3.0.0 | [certificate][cert 3.0.0] | [security policy][secpol 3.0.0]

[cert 3.0.0]: https://csrc.nist.gov/projects/cryptographic-module-validation-program/certificate/4282
[secpol 3.0.0]: https://csrc.nist.gov/CSRC/media/projects/cryptographic-module-validation-program/documents/security-policies/140sp4282.pdf

<br>
For a list of CVEs and their impact on validated FIPS providers, visit the
[CVEs and FIPS](/news/fips-cve.html) page.

Please follow the Security Policy instructions to download, build and
install a validated OpenSSL FIPS provider.
Other OpenSSL Releases MAY use the validated FIPS provider, but
MUST NOT build and use their own FIPS provider. For example you can build
OpenSSL 3.1 and use the OpenSSL 3.0.0 FIPS provider with it.

Information about how to configure and use the FIPS provider in your
applications is available on the FIPS module man page.
You must also read the module security policy and follow the specific
build and installation instructions included in it.


For an overview of some of the key concepts in OpenSSL 3.1 and 3.0 see the
libcrypto [manual
page](https://www.openssl.org/docs/man3.1/man7/crypto.html). Information
and notes about migrating existing applications to OpenSSL 3.1 (and 3.0) are
available in the [OpenSSL 3.1 Migration
Guide](https://www.openssl.org/docs/man3.1/man7/migration_guide.html)

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
