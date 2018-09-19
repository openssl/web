# -*- Apache -*-
Redirect permanent / https://www.openssl.org/community/contacts.html
Redirect permanent /verifycd.html https://www.openssl.org/docs/fips/verifycd.html
RedirectMatch permanent "^(.*)$" "https://www.openssl.org$1"
