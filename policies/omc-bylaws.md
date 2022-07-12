---
breadcrumb: Bylaws
---
# OpenSSL Bylaws

#### First issued 13th February 2017 Last modified 10th December 2019

This document defines the bylaws under which the OpenSSL Project
operates. It defines the different project roles, how they contribute to
the project, and how project decisions are made.

# Roles and Responsibilities

## Users

Users include any individual or organisation that downloads, installs,
compiles, or uses the OpenSSL command line applications or the OpenSSL
libraries or the OpenSSL documentation. This includes OpenSSL-based
derivatives such as patched versions of OpenSSL provided through OS
distributions, often known as "downstream" versions.

Users may request help and assistance from the project through any
appropriate forum as designated by the OpenSSL Management Committee
(OMC). Users may also report bugs, issues, or feature requests; or make
pull requests through any OMC designated channel.

## Committers

Committers have the ability to make new commits to the main OpenSSL
Project repository. Collectively, they have the responsibility for
maintaining the contents of that repository. They must ensure that any
committed contributions are consistent with all appropriate OpenSSL
policies and procedures as defined by the OMC.

Committers also have a responsibility to review code submissions in
accordance with OpenSSL project policies and procedures.

Commit access is granted by invitation from the OTC and requires a prior
OMC vote of acceptance. It may be withdrawn at any time by a vote of the
OMC.

A condition of commit access is that the committer has signed an
Individual Contributor Licence Agreement (ICLA). If contributions may
also be from the employer of an individual with commit access then a
Corporate Contributor Licence Agreement (CCLA) must also be signed and
include the name of the committer.

In order to retain commit access a committer must have authored or
reviewed at least one commit within the previous two calendar quarters.
This will be checked at the beginning of each calendar quarter. This
rule does not apply if the committer first received their commit access
during the previous calendar quarter.

## [OpenSSL Management Committee (OMC)]{#OMC}

The OMC represents the official voice of the project. All official OMC
decisions are taken on the basis of a vote.

The OMC:

-   makes all decisions regarding management and strategic direction of
    the project; including:
    -   business requirements;
    -   feature requirements;
    -   platform requirements;
    -   roadmap requirements and priority;
    -   end-of-life decisions;
    -   release timing and requirement decisions;
-   maintains the project infrastructure;
-   maintains the project website;
-   maintains the project code of conduct;
-   sets and maintains all project Bylaws;
-   sets and maintains all non-technical policies and non-technical
    procedures;
-   nominates and elects OMC members as required;
-   approves or rejects OTC nominations for committers and OTC members;
-   adds or removes OMC, OTC, or committers as required;
-   adjudicates any objections to OTC decisions;
-   adjudicates any objections to any commits to project repositories;
-   ensures security issues are dealt with in an appropriate manner;
-   schedules releases and determines future release plans and the
    development roadmap and priorities;
-   maintains all other repositories according to the policies and
    procedures they define.

Membership of the OMC is by invitation only from the existing OMC
following a passing vote. OMC members may or may not be committers as
well. If an OMC member is also a committer then all rules that apply to
committers still apply.

The OMC makes decisions on behalf of the project. In order to have a
valid voice on the OMC, members must be actively contributing to the
project. Note that there are many ways to contribute to the project but
the ones that count in order to participate in the OMC decision-making
process are the ones listed below.

In general, the OMC will leave technical decisions to the OpenSSL
Technical Committee (OTC, see below) and not participate in discussions
related to development and documention of the OpenSSL Toolkit. In
exceptional cases however an OTC vote can be overruled by an OMC vote.
Such an exceptional case would be for example if an OTC decision stands
contrary to OMC policies or decisions.

OMC members may become inactive. In order to remain active a member
must, in any calendar quarter, contribute by:

-   a) Having authored, or been recorded as a reviewer of, at least
    one commit made to any OpenSSL repository (including non-code
    based ones) and
-   b) vote in at least two-thirds of the OMC votes closed in the
    first two months of the quarter and the last month of the preceding
    quarter.

The above rules will be applied at the beginning of each calender
quarter. It does not apply if the OMC member was first appointed, or
became active again during the previous calendar quarter. The voting
requirement only includes those votes after the time the member joined
or was made active again.

If an OMC member remains inactive for one calendar quarter then they
will no longer be considered an OMC member, but will be listed as an OMC
Alumni. OMC Alumni have no access to OMC internal resources (including
email lists) but may request a vote at any time to reinstate their
membership in the OMC.

Any OMC member can propose a vote to declare another member inactive or
remove them from OMC membership entirely.

An OMC member can declare themselves inactive, leave the OMC, or leave
the project entirely. This does not require a vote.

An inactive OMC member can propose a vote that the OMC declare them
active again. Inactive OMC members cannot vote but can propose issues to
vote on and participate in discussions. They retain access to OMC
internal resources.

### [OMC Voting Procedures]{#omc-voting}

A vote to change these bylaws will pass if it obtains an in favour vote
by more than two thirds of the active OMC members and less than one
quarter votes against by the active OMC members. A vote that does not
change these bylaws will pass if it has had a vote registered from a
majority of active OMC members and has had more votes registered in
favour than votes registered against.

Only active OMC members may vote. A registered vote is a vote in favour,
a vote against, or an abstention.

Any OMC member (active or inactive) can propose a vote. OMC Alumni may
only propose a vote to reinstate themselves to the OMC. Each vote must
include a closing date which must be between seven and fourteen calendar
days after the start of the vote. Votes to change these bylaws must be
fourteen calendar days in duration.

In exceptional cases, the closing date for non-bylaw changing votes
could be less than seven calendar days; for example, a critical issue
that needs rapid action. A critical issue is hard to define precisely
but would include cases where a security fix is needed and the details
will soon be made public. At least one other active OMC member besides
the proposer needs to agree to the shorter timescale.

A vote closes on its specified date. In addition, any active OMC member
can declare a vote closed once the number of uncast votes could not
affect the outcome. Any active OMC member may change their vote up until
the vote is closed. No vote already cast can be changed after the vote
is closed. Votes may continue to be cast and recorded after a vote is
closed up until fourteen days after the start of the vote. These votes
will count for the purposes of determining OMC member activity, but will
otherwise not affect the outcome of the vote.

All votes and their outcomes should be recorded and available to all OMC
members.

## [OpenSSL Technical Committee (OTC)]{#OTC}

The OTC represents the official technical voice of the project. All OTC
decisions are taken on the basis of a vote.

The OTC:

-   makes all technical decisions of the code and documentation for
    OpenSSL including:
    -   design;
    -   architecture;
    -   implementation;
    -   testing;
    -   documentation;
    -   code review;
    -   quality assurance;
    -   classification of security issues in accordance with the
        security policy;
-   produces releases according to OMC requirements;
-   establishes and maintains technical policies and technical
    procedures such as:
    -   GitHub labels and milestone usage;
    -   coding style;
-   nominates to the OMC, addition or removal of OTC members and
    committers;
-   ensures technical aspects of security issues are dealt with in an
    appropriate manner;

Membership of the OTC is by invitation from the OTC and requires a prior
OMC vote of acceptance. OTC members must be committers and hence all
rules that apply to committers also apply. OTC members may be OMC
members and in which case all rules that apply to OMC members also
apply.

The OTC makes technical decisions on behalf of the project based on
requirements specified by the OMC. In order to have a valid voice on the
OTC, members must be actively contributing to the technical aspects of
the project. Note that there are many ways to contribute to the project
but the ones that count in order to participate in the OTC
decision-making process are the ones listed below.

OTC members may become inactive. In order to remain active a member
must, in any calendar quarter, contribute by:

-   a) Having authored, or been recorded as a reviewer of, at least one
    commit made to any OpenSSL repository (including non-code based
    ones) and
-   b) vote in at least two-thirds of the OTC votes closed in the first
    two months of the quarter and the last month of the preceding
    quarter and
-   c) maintain committer status.

The above rules will be applied at the beginning of each calender
quarter. It does not apply if the OTC member was first appointed, or
became active again during the previous calendar quarter. The voting
requirement only includes those votes after the time the member joined
or was made active again.

If an OTC member remains inactive for one calendar quarter then they
will no longer be considered an OTC member.

An OTC member can declare themselves inactive, leave the OTC, or leave
the project entirely. This does not require a vote.

An inactive OTC member can propose a vote that the OTC declare them
active again. Inactive OTC members cannot vote but can propose issues to
vote on and participate in discussions. They retain access to OTC
internal resources.

### [OTC Voting Procedures]{#otc-voting}

A vote will pass if it has had a vote registered from a majority of
active OTC members and has had more votes registered in favour than
votes registered against.

Only active OTC members may vote. A registered vote is a vote in favour,
a vote against, or an abstention.

Any OTC member (active or inactive) can propose a vote. Each vote must
include a closing date which must be between seven and fourteen calendar
days after the start of the vote.

In exceptional cases, the closing date could be less than seven calendar
days; for example, a critical issue that needs rapid action. A critical
issue is hard to define precisely but would include cases where a
security fix is needed and the details will soon be made public. At
least one other active OTC member besides the proposer needs to agree to
the shorter timescale.

A vote closes on its specified date. In addition, any active OTC member
can declare a vote closed once the number of uncast votes could not
affect the outcome. Any active OTC member may change their vote up until
the vote is closed. No vote already cast can be changed after the vote
is closed. Votes may continue to be cast and recorded after a vote is
closed up until fourteen days after the start of the vote. These votes
will count for the purposes of determining OTC member activity, but will
otherwise not affect the outcome of the vote.

All votes and their outcomes should be recorded and available to all OTC
and OMC members.

### [OTC Transparency]{#otc-transparency}

The majority of the activity of the OTC will take place in public.
Non-public discussions or votes shall only occur for issues such as:

-   pre-disclosure security problems
-   pre-agreement discussions with third parties that require
    confidentiality
-   nominees for OTC or committer roles
-   personal conflicts among project personnel

Full details (topic, dates, voting members, specific votes cast, vote
result) of all public votes shall be made available in a public
repository.

## OpenSSL Software Foundation (OSF)

The OpenSSL Software Foundation represents the OpenSSL project in legal
and most official formal capacities in relation to external entities and
individuals. This includes, but is not limited to, managing contributor
license agreements, managing donations, registering and holding
trademarks, registering and holding domain names, obtaining external
legal advice, and so on.

Any OMC member may serve as a director of OSF if they wish. To do so
they should send a request to any existing OSF director.

## OpenSSL Software Services (OSS)

OpenSSL Software Services represents the OpenSSL project for most
commercial and quasi-commercial contexts, such as providing formal
support contracts and brokering consulting contracts for OpenSSL
committers.

Any OMC member may serve as a director of OSS if they wish, subject to
certain contractual requirements. To do so they should send a request to
any existing OSS director.

# [Leave of absence]{#leave}

An active OMC member, OTC member, or committer may request a leave of
absence from the project. A leave of absence from the OMC, OTC or
committer shall suspend inactivity determination for the specified role.
All access to OMC, OTC or committer resources shall be suspended
(disabled) and the OMC or OTC member shall be excluded from voting and
the committer shall be excluded from reviewing or approving source
changes. On return from a leave of absence, the OMC or OTC member or
committer will be deemed to have become active as of the date of return.

All of the following criteria must be met in order to qualify as a leave
of absence:

-   a) the member must request via email to the OMC a leave of absence
    at least one week in advance of the requested period of leave;
-   b) only one leave of absence is permitted per calendar year;
-   c) the leave of absence must specify the date of return from the
    leave of absence;
-   d) the length of the leave of absence shall be a minimum of one
    calendar month and shall not exceed three calendar months (one
    quarter); and
-   e) the leave of absence applies to all the roles within the project
    (i.e. OMC, OTC and committer if all three roles apply).

# [Bylaws Update History]{#update}

The following changes have been made since the bylaws were first issued
13-February-2017.

-   21-November-2019. Added *OTC*. and other related changes.
-   20-December-2017. Added *Leave of absence* section.
