# -*- Apache -*-
Redirect permanent /verifycd.html https://www.openssl.org/docs/fips/verifycd.html

RedirectMatch permanent "^/$" https://www.openssl.org/community/contacts.html
RedirectMatch permanent "^(.*)$" "https://www.openssl.org$1"
