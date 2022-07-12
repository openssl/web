---
title: Roadmap
---
# OpenSSL project roadmap

### Last modified 23 March 2022

This document is the OpenSSL project roadmap. It is a living document
and is expected to change over time. Objectives and dates should be
considered aspirational.

## Objectives

Some of these objectives can be achieved more easily and quickly
than others.

#### QUIC

OpenSSL is taking a multi-staged approach to the implementation of the
[QUIC] transport protocol:

- For OpenSSL 3.1, the focus is on providing a client side single stream
QUIC implementation.

- OpenSSL 3.2 will follow approximately six months later implementing more
of the protocol.

- OpenSSL 3.3 aims to complete the implementation a further six months later.

[QUIC]: https://datatracker.ietf.org/doc/html/rfc9000

#### FIPS

The OpenSSL FIPS provider for 3.x is still progressing through the validation.

#### Post-quantum cryptography

A cryptographic algorithm needs to be defined by a national or
international standard before it will be considered for inclusion into
OpenSSL.  Although, there is work in progress to select
[post-quantum algorithms] for standardisation, currently none have been.
OpenSSL will not be including any of the candidate algorithms until the
selection process is complete.

For those interested in using the proposed algorithms now, the
[Open Quantum Safe] project has written a [provider] for OpenSSL 3.x
which includes the candidates.

[post-quantum algorithms]: https://csrc.nist.gov/Projects/post-quantum-cryptography
[Open Quantum Safe]: https://openquantumsafe.org/
[provider]: https://github.com/open-quantum-safe/oqs-provider

#### Substantial features

There are a number of pull requests which represent substantial
features.  Each will require a significant time investment by the
project's contractors to review before they can be included in OpenSSL.
These features should be included gradually over upcoming releases.

1. Argon2 KDFs ([RFC 9106]; openssl/openssl#12255 & openssl/openssl#12256)
2. Attribute Certificates ([RFC 5755]; openssl/openssl#15857)
3. Hybrid Public Key Encryption ([RFC 9180]; openssl/openssl#17172)
4. Raw Public Keys ([RFC 7250]; openssl/openssl#16620)

[RFC 5755]: https://datatracker.ietf.org/doc/html/rfc5755
[RFC 7250]: https://datatracker.ietf.org/doc/html/rfc7250
[RFC 9106]: https://datatracker.ietf.org/doc/html/rfc9106
[RFC 9180]: https://datatracker.ietf.org/doc/html/rfc9180
