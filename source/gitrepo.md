---
breadcrumb: Git Repository
---
# Git Repository

The OpenSSL software is developed using a Git repository. Read-only access
to the repository is available at git.openssl.org. We also maintain a
downstream clone on GitHub, at <https://github.com/openssl/openssl> on
GitHub. This repository is updated with every commit and is accessible
through a number of protocols.

On the OpenSSL repository we only support the *git* protocol. Use the
following command to clone the git repository including all available
branches and tags:

``` console
$ git clone git://git.openssl.org/openssl.git
```

Access to specific branches is possible via the standard branch and
checkout commands. See the discussion of branch naming below for more
information.

On Windows, once the repository is cloned, you should ensure that line
endings are set correctly:

``` console
$ cd openssl
$ git config core.autocrlf false
$ git config core.eol lf
$ git checkout .
```

## Git branch names and tagging

The *master* branch, also known as the development branch, contains the
latest bleeding edge code. There are also several *stable* branches
where stable releases come from. These take the form
*OpenSSL\_x\_y\_z-stable* so, for example, the 1.1.0 stable branch is
*OpenSSL\_1\_1\_0-stable*. When an actual release is made it is tagged
in the form *OpenSSL\_x\_y\_zp* or a beta *OpenSSL\_x\_y\_xp-betan*,
though you should normally just download the release tarball. Tags and
branches are occasionally used for other purposes such as testing
experimental or unstable code before it is merged into another branch.
