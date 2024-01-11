---
breadcrumb: Roadmap
---
# OpenSSL project roadmap

Updated: 11 January 2024

Please note that the current project roadmap represents a plan and vision and is
not set in stone. As with any dynamic project, our roadmap is subject to change
based on ongoing development insights, user feedback, and evolving priorities.
We encourage our community to follow the project's progress and participate in
its evolution. Stay updated and engage with us through our [project board],
where you can track real-time updates, milestones, and changes.

### OpenSSL 3.3

From OpenSSL 3.3 onwards, the [Release Steering Committee] oversees the release
cycle. We have adopted a [time-based release policy], with scheduled releases
every April and October. Therefore, our goal is to release version 3.3 this
April.

We plan to introduce multi-stream QUIC server support in OpenSSL 3.3,
complementing the [client-side support] included in OpenSSL 3.2.

Furthermore, we aspire to advance in various areas, including performance
enhancements. However, we are not committing to delivering these improvements in
OpenSSL 3.3.

As with any OpenSSL feature release, OpenSSL 3.3 may also include additional
features based on contributions from our community.

### FIPS

On December 29, 2023, we submitted our FIPS 140-3 validation report to NIST's
[Cryptographic Module Validation Program] (CMVP) and are actively working
towards achieving FIPS 140-3 validation. This endeavour is a continuous process
that runs alongside our regular release schedule. We do not have a confirmed
date or release for FIPS 140-3 certification.

### How do I track the progress?

For the latest updates, please visit our project board:
- [QUIC server support](https://github.com/orgs/openssl/projects/2/views/31?pane=issue&itemId=31713456)


[project board]:https://github.com/orgs/openssl/projects/2/views/28
[Release Steering Committee]:https://www.openssl.org/policies/general/release-policy.html#fn2
[time-based release policy]:https://www.openssl.org/policies/general/release-policy.html
[client-side support]:https://github.com/openssl/openssl/blob/openssl-3.2/README-QUIC.md
[Cryptographic Module Validation Program]:https://csrc.nist.gov/projects/cryptographic-module-validation-program