---
breadcrumb: Release Strategy
---
# Release Strategy

#### First issued 23rd December 2014 Last modified 7th January 2020

As of release 3.0.0, the OpenSSL versioning scheme is changing to a more
contemporary format: MAJOR.MINOR.PATCH

With this format, API/ABI compatibility will be guaranteed for the same
MAJOR version number. Previously we guaranteed API/ABI compatibility
across the same MAJOR.MINOR combination.

-   MAJOR: API/ABI incompatible changes will increase this number
-   MINOR: API/ABI compatible feature releases will change this
-   PATCH: Bug fix releases will increment this number. We also allow
    backporting of accessor functions in these releases.

This more closely aligns with the expectations of users who are familiar
with semantic versioning. However, we have not adopted semantic
versioning in the strict sense of its rules, because it would mean
changing our current LTS policies and practices.

The current 1.1.1 versioning scheme remains unchanged:

> *As of release 1.0.0 the OpenSSL versioning scheme was improved to
> better meet developers' and vendors' expectations. Letter releases,
> such as 1.0.2a, exclusively contain bug and security fixes and no new
> features. Releases that change the last digit, e.g. 1.1.0 vs. 1.1.1,
> can and are likely to contain new features, but in a way that does not
> break binary compatibility. This means that an application compiled
> and dynamically linked with 1.1.0 does not need to be recompiled when
> the shared library is updated to 1.1.1. It should be noted that some
> features are transparent to the application such as the maximum
> negotiated TLS version and cipher suites, performance improvements and
> so on. There is no need to recompile applications to benefit from
> these features.*

------------------------------------------------------------------------

With regards to current and future releases the OpenSSL project has
adopted the following policy:

-   Version 3.0 will be supported until 2026-09-07 (LTS).
-   Version 1.1.1 will be supported until 2023-09-11 (LTS).
-   Version 1.0.2 is no longer supported. Extended support for 1.0.2 to
    gain access to security fixes for that version is
    [available](/support/contracts.html).
-   Versions 1.1.0, 1.0.1, 1.0.0 and 0.9.8 are no longer supported.

We may designate a release as a Long Term Support (LTS) release. LTS
releases will be supported for at least five years and we will specify
one at least every four years. Non-LTS releases will be supported for at
least two years.

During the final year of support, we do not commit to anything other
than security fixes. Before that, bug and security fixes will be applied
as appropriate.

The addition of new platforms to LTS branches is acceptable so long as
the required changes consist solely of additions to configuration.

------------------------------------------------------------------------

Before a major release, we make a number of pre-releases, labeled
*alpha* and *beta*.

An *alpha* release means:

-   Not (necessarily) feature complete
-   Not necessarily all new APIs in place yet

A *beta* release means:

-   Feature complete/Feature freeze
-   Bug fixes only

For any major or minor release, we have defined the following release
criteria:

-   All open github issues/PRs older than 2 weeks at the time of release
    need to be assessed for relevance to the version being released. Any
    flagged with the a milestone for the version to be released must be
    closed (see below).
-   Clean builds in Travis and Appveyor for two days.
-   run-checker.sh succeeds on 2 consecutive days before release.
-   No open Coverity issues (not flagged as "False Positive" or
    "Ignore").

Valid reasons for closing an issue/PR with a milestone for the version
might be:

-   We have just now or sometime in the past fixed the issue
-   Unable to reproduce (following discussion with original reporter if
    possible)
-   Working as intended
-   Deliberate decision not to fix this issue until a later release
    (this wouldn't actually close the issue/PR but change the milestone
    instead)
-   Not enough information and unable to contact reporter

------------------------------------------------------------------------

No API or ABI breaking changes are allowed in a minor or patch release.
The following stability rules apply to all changes made to code targeted
for a major release from version 3.0.0 or later:

-   No existing public interface can be modified except where changes
    are unlikely to break source compatibility or where structures are
    made opaque.
-   No existing public interface can be removed until its replacement
    has been in place in an LTS stable release. The original interface
    must also have been documented as deprecated for at least 5 years. A
    public interface is any function, structure or macro declared in a
    public header file.
-   When structures are made opaque, any newly required accessor macros
    or functions are added in a feature release of the extant LTS
    release and all supported intermediate successor releases.
