---
breadcrumb: Getting Started
---
# Getting Started as a contributor

We're always looking for people who want to help out. Here are some 
tips to getting started. First, get familiar with the information on
this page, and the links to the side. In particular, you should look at
the [Mailing Lists](mailinglists.html) page and join the
*openssl-project* or *openssl-users* list, or both. After that, here are
some ideas:

-   *Review and comment on the pull requests on GitHub.*\
    You can find pull requests \-- patches that people have suggested
    \-- at <https://github.com/openssl/openssl/pulls>. Reviewing and
    commenting on these is helpful and can be a good way to learn your way
    around the code.
-   *Look through the OpenSSL issues on GitHub.*\
    You can find issues that people have opened at
    <https://github.com/openssl/openssl/issues>. Sometimes there are
    open tickets that can be related, it would be good to
    cross-reference them (so somebody working on one, sees the other).
    Commentary on the issues is also good. Even just commenting that you
    think an issue is important is very useful!
-   *Help update the documentation.*\
    The documentation has gotten better, but there are still many API\'s
    that are not documented. Write a POD page, or report bugs in
    existing pages. It's probably better to do a whole bunch of minor
    edits in one submission.
-   *Write some test cases.*\
    Simple stand-alone test programs that exercise various APIs are
    very useful, and can usually be added to our perl-based test
    framework pretty easily. Tests of the command-line program are also
    important, and can be handled by the same framework but might
    require a bit more digging. We welcome all new test efforts!

Once you've got something ready to contribute, please see the file
CONTRIBUTING in the source. (TL;DR: Just make a GitHub pull request :)
