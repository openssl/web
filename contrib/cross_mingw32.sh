#!/bin/sh

# Copyright (c) 2002 Michal Trojnara.  All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above
#    copyright notice, this list of conditions and the following
#    disclaimer in the documentation and/or other materials provided
#    with the distribution.
# 3. The name of the author may not be used to endorse or promote
#    products derived from this software without specific prior
#    written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS
# OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
# GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

PERL=perl
MAKE=make
OPT=no-idea
PREFIX=/usr/cross-tools/bin/i386-mingw32msvc-

echo "Generating x86 for GNU assember"

echo -n "Bignum"
cd crypto/bn/asm
${PERL} x86.pl gaswin > bn-win32.s
cd ../../..

echo -n " DES"
cd crypto/des/asm
${PERL} des-586.pl gaswin > d-win32.s
cd ../../..

echo -n " crypt"
cd crypto/des/asm
${PERL} crypt586.pl gaswin > y-win32.s
cd ../../..

echo -n " Blowfish"
cd crypto/bf/asm
${PERL} bf-586.pl gaswin > b-win32.s
cd ../../..

echo -n " CAST5"
cd crypto/cast/asm
${PERL} cast-586.pl gaswin > c-win32.s
cd ../../..

echo -n " RC4"
cd crypto/rc4/asm
${PERL} rc4-586.pl gaswin > r4-win32.s
cd ../../..

echo -n " MD5"
cd crypto/md5/asm
${PERL} md5-586.pl gaswin > m5-win32.s
cd ../../..

echo -n " SHA1"
cd crypto/sha/asm
${PERL} sha1-586.pl gaswin > s1-win32.s
cd ../../..

echo -n " RIPEMD160"
cd crypto/ripemd/asm
${PERL} rmd-586.pl gaswin > rm-win32.s
cd ../../..

echo " RC5/32"
cd crypto/rc5/asm
${PERL} rc5-586.pl gaswin > r5-win32.s
cd ../../..

echo "Creating ms/mingw32.mak"
${PERL} util/mkfiles.pl > MINFO || exit 1
${PERL} util/mk1mf.pl ${OPT} gaswin Mingw32 > ms/mingw32.mak \
    || exit 1

# echo "Building OpenSSL"
${MAKE} -f ms/mingw32.mak MKDIR=mkdir RM='rm -f' CC=${PREFIX}gcc \
    ASM=${PREFIX}as AR=${PREFIX}ar RANLIB=${PREFIX}ranlib || exit 1

echo "Generating DLL definition files"
${PERL} util/mkdef.pl 32 libeay ${OPT} > ms/libeay32.def || exit 1
${PERL} util/mkdef.pl 32 ssleay ${OPT} > ms/ssleay32.def || exit 1

echo "Building DLLs"
${PREFIX}dllwrap --dllname libeay32.dll --output-lib out/libeay32.a \
    --def ms/libeay32.def out/libcrypto.a -lwsock32 -lgdi32 || exit 1
${PREFIX}dllwrap --dllname libssl32.dll --output-lib out/libssl32.a \
    --def ms/ssleay32.def out/libssl.a out/libeay32.a || exit 1

echo "Done"

