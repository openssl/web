---
breadcrumb: FIPS-140
---
# FIPS-140

Note that this page contains historic information about our legacy
OpenSSL FIPS Object Module (FOM) 2.0. For information about the
OpenSSL FOM 3.0 refer to
[the FIPS module manual page](https://www.openssl.org/docs/man3.0/man7/fips_module.html)

The most recent validation of a cryptographic module (Module) compatible
with OpenSSL 1.0.2 is v2.0.16, FIPS 140-2 certificate
[\#1747](https://csrc.nist.gov/projects/cryptographic-module-validation-program/Certificate/1747).
This Module is documented in the [2.0 User Guide](fips/UserGuide-2.0.pdf);
the [source code](/source/openssl-fips-2.0.16.tar.gz), and
[Security Policy](fips/SecurityPolicy-2.0.16.pdf) are also available.

For various bureaucratic reasons, the same module is also available as
validation
[\#2398](https://csrc.nist.gov/projects/cryptographic-module-validation-program/Certificate/2398)
(revision 2.0.16).

Neither validation will work with any release other than 1.0.2. The
OpenSSL project is no longer maintaining either the 1747 or the 2398
module. This includes adding platforms to those validations. The OpenSSL
project is no longer involved in private label validations nor adding
platforms to the existing certificates.

Here is the complete set of files. Note that if you are interested in
the "1747" validation, you only need the three files mentioned above.

<p>
<table>
  <tr>
    <td>KBytes&nbsp;</td>
    <td>Date&nbsp;&nbsp;</td>
    <td>File&nbsp;</td>
  </tr>
  <!--#include virtual="fips.inc" -->
</table>
</p>

## Background

Please please read the [User Guide](fips/UserGuide.pdf).

-   OpenSSL itself is not validated. Instead a special carefully defined
    software component called the OpenSSL FIPS Object Module has been
    created. This Module was designed for compatibility with OpenSSL so
    that products using the OpenSSL API can be converted to use
    validated cryptography with minimal effort.
-   The OpenSSL FIPS Object Module 2.0 validation is "delivered" in
    source code form, meaning that if you can use it exactly as is and
    can build it (according to the very specific documented
    instructions) for your platform, then you can use it as validated
    cryptography on a "vendor affirmed" basis.
-   If even a single line of the source code or build process has to be
    changed for your intended application, you cannot use the open
    source based validated module directly. You must obtain your own
    validation.
