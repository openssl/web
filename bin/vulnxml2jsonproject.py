#! /usr/bin/python

# project specific details
config = dict()
config['project'] = "openssl"
config['vendor_name'] = "OpenSSL"
config['product_name'] = "OpenSSL"
config['cve_meta_assigner'] = "openssl-security@openssl.org"
# Versions of OpenSSL we never released, to allow us to display ranges
config['neverreleased'] = "1.0.0h,"
config['security_policy_url'] = "https://www.openssl.org/policies/secpolicy.html#"
config['git_prefix'] = "https://git.openssl.org/gitweb/?p=openssl.git;a=commitdiff;h="
config['default_reference_prefix'] = "https://www.openssl.org"

def merge_affects(issue,base):
    # let's merge the affects into a nice list which is better for Mitre text but we have to take into account our stange lettering scheme
    prev = ""
    anext = ""
    alist = list()
    vlist = list()
    for affects in issue.getElementsByTagName('affects'): # so we can sort them
       version = affects.getAttribute("version")
       if (not base or base in version):
           vlist.append(version)
    for ver in sorted(vlist):
       # print(f'version {ver} (last was {prev}, next was {anext})')
       if (ver != anext):
          alist.append([ver])
       elif len(alist[-1]) > 1:
          alist[-1][-1] = ver
       else:
          alist[-1].append(ver)
       prev = ver
       parts = ver.split('.')
       # Deal with 3.0 version scheme
<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> a39a5e1 (There's a single vulnerability where we use fips as the version, don't)
       try:
           if int(parts[0])>=3:
               anext = '.'.join(parts[:-1])+'.'+str(int(parts[-1])+1)
               continue
       except:
           pass
<<<<<<< HEAD
=======
       if int(parts[0])>=3:
           anext = '.'.join(parts[:-1])+'.'+str(int(parts[-1])+1)
           continue
>>>>>>> 030e5ac (in vulnerabilities.html, Fixed in OpenSSL 3.0.3 (git commit) (Affected 3.0.0,3.0.1,3.0.2))
=======
>>>>>>> a39a5e1 (There's a single vulnerability where we use fips as the version, don't)
       # Deal with pre 3.0 version scheme
       if (str.isdigit(ver[-1])):   # First version after 1.0.1 is 1.0.1a
           anext = ver + "a"
       elif (ver[-1] == "y"):
           anext = ver[:-1] + "za"    # We ran out of letters once so y->za->zb....
       else:
           anext = ver[:-1]+chr(ord(ver[-1])+1) # otherwise after 1.0.1a is 1.0.1b
       while (anext in config['neverreleased']): # skip unreleased versions
          anext = anext[:-1]+chr(ord(anext[-1])+1)

    return ",".join(['-'.join(map(str,aff)) for aff in alist])
