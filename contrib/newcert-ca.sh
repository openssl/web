#! /bin/sh
#
# This script starts the ZENEZ_CA,
# generates a 1024 bit CA key with a passphrase you enter,
# and creates SSL server certs (without a passphrase on the private key)
#
# (C)Copyright 1997 Clifford Heath, Open Software Associates Limited.
# Commercial or private use allowed, provided this notice is not removed.
# No warrantees. User is responsible to ensure correct operation.
# Under no circumstances will either Clifford Heath or OSA Ltd be
# liable for damages, however caused, relating to the operation of
# this program.
#
# This was heavily modifed by Boyd Gerber, ZENEZ.
# Commercial or private use allowed, provided this notice is not removed.
# No warrantees. User is responsible to ensure correct operation.
# Under no circumstances will either Boyd Gerber or ZENEZ be
# liable for damages, however caused, relating to the operation of
# this program.

PATH=/usr/local/ssl/bin:/usr/local/bin:/bin:/usr/bin:;export PATH
OPENSSLDIR=/usr/local/ssl
CA_NAME=
echo This will generate a new CA if one does not exist
echo what is or what do you want to call your CA
read CA_NAME

export CA_NAME
CALOC=/usr/local/ssl/$CA_NAME;export CALOC
mkdir -p $CALOC

openssl rand -out $CALOC/random-bits -rand /var/run/egd-pool:/var/adm/syslog 1024

echo ========================================
echo Creating $CALOC CA:
# Generate a new CA key and certificate: 
echo ========================================

#echo Generating a new CA key and certificate:
# Create the master CA key. This should be done once.
if [ ! -f $CALOC/ca.key ]; then
	echo "No Root CA key round. Generating one"
	openssl genrsa -des3 -out $CALOC/ca.key 1024 -rand random-bits
	echo ""
fi
echo ========================================
echo ""
echo "Self-sign the root CA..."
if [ ! -f $CALOC/cacert.pem ]; then
	echo "No Root CA Cert found."

# Self-sign it.
CONFIG="root-ca.conf"
cat >$CONFIG <<EOT
[ req ]
default_bits			= 1024
default_keyfile			= ca.key
distinguished_name		= req_distinguished_name
x509_extensions			= v3_ca
string_mask			= nombstr
req_extensions			= v3_req
[ req_distinguished_name ]
countryName			= Country Name (2 letter code)
countryName_default		= US
countryName_min			= 2
countryName_max			= 2
stateOrProvinceName		= State or Province Name (full name)
stateOrProvinceName_default	= Utah
localityName			= Locality Name (eg, city)
localityName_default		= Magna
0.organizationName		= Organization Name (eg, company)
0.organizationName_default	= ZENEZ
organizationalUnitName		= Organizational Unit Name (eg, section)
organizationalUnitName_default	= Certification Services Division
commonName			= Common Name (eg, ZENEZ Root CA)
commonName_max			= 64
emailAddress			= Email Address
emailAddress_max		= 40
[ v3_ca ]
basicConstraints		= critical,CA:true
subjectKeyIdentifier		= hash
[ v3_req ]
nsCertType			= objsign,email,server
EOT

openssl req -new -x509 -days 3650 -config $CONFIG -key $CALOC/ca.key -out $CALOC/cacert.pem
	echo ""
fi

rm -f $CONFIG
echo Certificate is in $CALOC/cacert.pem
mkdir -p $CALOC/certs/request
mkdir -p $CALOC/certs/ssl
mkdir -p $CALOC/certs/request/processed
mkdir -p $CALOC/private
if [ -f $CALOC/ca.key ]; then
cp -p $CALOC/ca.key $CALOC/private/ca.key
cp -p $CALOC/ca.key $CALOC/private/cakey.pem
cp -p $CALOC/cacert.pem $CALOC/private/cacert.pem
chmod u-w $CALOC/private/*
  if [ ! -f $CALOC/serial ]; then
    echo "01" > $CALOC/serial
    cp /dev/null $CALOC/index.txt 
  fi
  echo ""
fi

# Generate new server cert req:
echo ========================================
echo "Generate cert for <www.domain.com>"
echo What do you want to call this cert?
read cert_name
CERT=$cert_name;export CERT

# Create the key. This should be done once per cert.
if [ ! -f $CALOC/certs/request/$CERT.key ]; then
	echo "No $CERT.key round. Generating one"
	openssl genrsa -out $CALOC/certs/request/$CERT.key 1024
	echo ""
fi

# Fill the necessary certificate data
CONFIG="server-cert.conf"
cat >$CONFIG <<EOT1
[ req ]
default_bits			= 1024
default_keyfile			= server.key
distinguished_name		= req_distinguished_name
string_mask			= nombstr
req_extensions			= v3_req
[ req_distinguished_name ]
countryName			= Country Name (2 letter code)
countryName_default		= US
countryName_min			= 2
countryName_max			= 2
stateOrProvinceName		= State or Province Name (full name)
stateOrProvinceName_default	= Utah
localityName			= Locality Name (eg, city)
localityName_default		= Magna
0.organizationName		= Organization Name (eg, company)
0.organizationName_default	= ZENEZ
organizationalUnitName		= Organizational Unit Name (eg, section)
organizationalUnitName_default	= Secure Web Server
commonName			= Common Name (eg, www.domain.com)
commonName_max			= 64
emailAddress			= Email Address
emailAddress_max		= 40
[ v3_req ]
nsCertType			= server
basicConstraints		= critical,CA:false
EOT1

echo "Fill in certificate data"
openssl req -new -config $CONFIG -key $CALOC/certs/request/$CERT.key -out $CALOC/certs/request/$CERT.pem

rm -f $CONFIG

echo ""
#echo ========================================
#echo Signing and installing server cert:
if [ ! -f $CALOC/certs/request/$CERT.pem ]; then
        echo "No $CERT.pem round. You must create that first."
	exit 1
fi
# Check for root CA key
if [ ! -f $CALOC/private/ca.key -o ! -f $CALOC/private/cacert.pem ]; then
	echo "You must have root CA key generated first."
	exit 1
fi

# Sign it with our CA key #

#   make sure environment exists
#  create the CA requirement to sign the cert
dir		= $OPENSSLDIR/$CA_NAME;export dir		# Where everything is kept
cat >ca.config <<EOT2
[ ca ]
default_ca	= CA_default		# The default ca section
[ ca ]
[ CA_default ]

dir		= $OPENSSLDIR/$CA_NAME		# Where everything is kept
certs		= $OPENSSLDIR/$CA_NAME/certs/request		# Where the issued certs are kept
crl_dir		= $OPENSSLDIR/$CA_NAME/certs/request/processed		# Where the issued crl are kept
database	= $OPENSSLDIR/$CA_NAME/index.txt	# database index file.
new_certs_dir	= $OPENSSLDIR/$CA_NAME/certs/request		# default place for new certs.

certificate	= $OPENSSLDIR/$CA_NAME/private/cacert.pem 	# The CA certificate
serial		= $OPENSSLDIR/$CA_NAME/serial 		# The current serial number
crl		= $OPENSSLDIR/$CA_NAME/crl.pem 		# The current CRL
private_key	= $OPENSSLDIR/$CA_NAME/private/cakey.pem	# The private key
RANDFILE        = $CALOC/random-bits
default_days            = 365
default_crl_days        = 30
default_md              = md5
preserve                = no
x509_extensions		= server_cert
policy                  = policy_anything
[ policy_anything ]
countryName             = optional
stateOrProvinceName     = optional
localityName            = optional
organizationName        = optional
organizationalUnitName  = optional
commonName              = supplied
emailAddress            = optional
[ server_cert ]
#subjectKeyIdentifier	= hash
authorityKeyIdentifier	= keyid:always
extendedKeyUsage	= serverAuth,clientAuth,msSGC,nsSGC
basicConstraints	= critical,CA:false
EOT2

#  sign the certificate
echo "CA signing: $CALOC/certs/request/$CERT.pem -> $CALOC/certs/request/processed/$CERT.pem:"

openssl ca -config ca.config -out $CALOC/certs/request/processed/$CERT.pem -infiles $CALOC/certs/request/$CERT.pem

echo "CA verifying: $CALOC/certs/request/$CERT.pem <-> $CALOC/certs/request/processed/$CERT.pem:"

openssl verify -CAfile $CALOC/private/cacert.pem $CALOC/certs/request/processed/$CERT.pem

echo ========================================
#  cleanup after SSLeay 
rm -f ca.config

cp -p $CALOC"/certs/request/processed/"$CERT.pem $CALOC"/certs/ssl/"$CERT"_httpsd.pem"
cp -p $CALOC"/certs/request/"$CERT.key $CALOC"/certs/ssl/"$CERT"_httpsdkey.pem"


#chmod 400 $CALOC"/certs/ssl/"*key.pem
sed -n '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/p' \
	< $CALOC"/certs/ssl/"$CERT"_httpsd.pem" \
	> $CALOC"/certs/ssl/"$CERT"_httpsd.cert"

sed -n '/-----BEGIN RSA PRIVATE KEY-----/,/-----END RSA PRIVATE KEY-----/p' \
	< $CALOC"/certs/ssl/"$CERT"_httpsdkey.pem" \
	> $CALOC"/certs/ssl/"$CERT"_httpsd.key" 

chmod 400 $CALOC"/certs/ssl/"$CERT"_httpsd.key"

echo ========================================
echo ""
echo Please Use the $CALOC"/certs/ssl/"$CERT"_httpsd.key"
echo Please Use the $CALOC"/certs/ssl/"$CERT"_httpsd.cert"
echo ""
echo "Finished Processing your Certificate"
echo ""
echo ========================================
