#! /usr/bin/python
#
# Convert our XML file to a JSON file as accepted by Mitre for CNA purposes
# as per https://github.com/CVEProject/automation-working-group/blob/master/cve_json_schema/DRAFT-JSON-file-format-v4.md
#

from xml.dom import minidom
import simplejson as json
import codecs
import re
from optparse import OptionParser

# for validation
import json
import jsonschema
from jsonschema import validate
from jsonschema import Draft4Validator
import urllib

# Versions of OpenSSL we never released, to allow us to display ranges
neverreleased = "1.0.0h,";

# Location of CVE JSON schema (default, can use local file etc)
default_cve_schema = "https://raw.githubusercontent.com/CVEProject/automation-working-group/master/cve_json_schema/CVE_JSON_4.0_min_public.schema"

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
       # print "version %s (last was %s, next was %s)" %(ver,prev,anext)
       if (ver != anext):
          alist.append([ver])
       elif len(alist[-1]) > 1:
          alist[-1][-1] = ver
       else:
          alist[-1].append(ver)
       prev = ver
       if (unicode.isdigit(ver[-1])):   # First version after 1.0.1 is 1.0.1a
           anext = ver + "a"
       elif (ver[-1] == "y"):
           anext = ver[:-1] + "za"    # We ran out of letters once so y->za->zb....
       else:
           anext = ver[:-1]+chr(ord(ver[-1])+1) # otherwise after 1.0.1a is 1.0.1b
       while (anext in neverreleased): # skip unreleased versions
          anext = anext[:-1]+chr(ord(anext[-1])+1)

    return ",".join(['-'.join(map(str,aff)) for aff in alist])
        
parser = OptionParser()
parser.add_option("-s", "--schema", help="location of schema to check (default "+default_cve_schema+")", default=default_cve_schema,dest="schema")
parser.add_option("-i", "--input", help="input vulnerability file live openssl-web/news/vulnerabilities.xml", dest="input")
parser.add_option("-c", "--cve", help="comma separated list of cve names to generate a json file for (or all)", dest="cves")
parser.add_option("-o", "--outputdir", help="output directory for json file (default ./)", default=".", dest="outputdir")
(options, args) = parser.parse_args()

if not options.input:
   print "needs input file"
   parser.print_help()
   exit();

if options.schema:
   response = urllib.urlopen(options.schema)
   schema_doc = json.loads(response.read())

cvej = list()
    
with codecs.open(options.input,"r","utf-8") as vulnfile:
    vulns = vulnfile.read()
dom = minidom.parseString(vulns.encode("utf-8"))
issues = dom.getElementsByTagName('issue')
for issue in issues:
    cve = issue.getElementsByTagName('cve')[0].getAttribute('name')
    if (cve == ""):
       continue
    if (options.cves):
       if (not cve in options.cves):
          continue
    cve = dict()
    cve['data_type']="CVE"
    cve['data_format']="MITRE"
    cve['data_version']="4.0"
    cve['CVE_data_meta']= { "ID": "CVE-"+issue.getElementsByTagName('cve')[0].getAttribute('name'), "ASSIGNER": "openssl-security@openssl.org", "STATE":"PUBLIC" }
    datepublic = issue.getAttribute("public")
    cve['CVE_data_meta']['DATE_PUBLIC'] = datepublic[:4]+'-'+datepublic[4:6]+'-'+datepublic[6:8]
    if issue.getElementsByTagName('title'):
        cve['CVE_data_meta']['TITLE'] = issue.getElementsByTagName('title')[0].childNodes[0].nodeValue.strip()            
    desc = issue.getElementsByTagName('description')[0].childNodes[0].nodeValue.strip()
    problemtype = "(undefined)"
    if issue.getElementsByTagName('problemtype'):
        problemtype = issue.getElementsByTagName('problemtype')[0].childNodes[0].nodeValue.strip()    
    cve['problemtype'] = { "problemtype_data": [ { "description" : [ { "lang":"eng", "value": problemtype} ] } ] }
    impact = issue.getElementsByTagName('impact')
    if impact:
        cve['impact'] = [ { "lang":"eng", "value":impact[0].getAttribute('severity'), "url":"https://www.openssl.org/policies/secpolicy.html#"+impact[0].getAttribute('severity') } ]
    for reported in issue.getElementsByTagName('reported'):
        cve['credit'] = [ { "lang":"eng", "value":reported.getAttribute("source")} ]
    refs = list()
    for adv in issue.getElementsByTagName('advisory'):
       url = adv.getAttribute("url")
       if (not url.startswith("htt")):
          url = "https://www.openssl.org"+url
       refs.append({"url":url})
    for git in issue.getElementsByTagName('git'):
       refs.append({"url":"https://git.openssl.org/gitweb/?p=openssl.git;a=commitdiff;h="+git.getAttribute("hash")})
    if refs:
        cve['references'] = { "reference_data": refs  }

    vv = list()
    for affects in issue.getElementsByTagName('fixed'):
        text = "Fixed in OpenSSL %s (Affected %s)" %(affects.getAttribute('version'),merge_affects(issue,affects.getAttribute("base")))
        # Let's condense into a list form since the format of this field is 'free text' at the moment, not machine readable (as per mail with George Theall)
        vv.append({"version_value":text})
        # Mitre want the fixed/affected versions in the text too
        desc += " "+text+"."

    cve['affects'] = { "vendor" : { "vendor_data" : [ { "vendor_name": "OpenSSL", "product": { "product_data" : [ { "product_name": "OpenSSL", "version": { "version_data" : vv}}]}}]}}
        
    # Mitre want newlines and excess spaces stripped
    desc = re.sub('[\n ]+',' ', desc)
        
    cve['description'] = { "description_data": [ { "lang":"eng", "value": desc} ] }
    cvej.append(cve)
        

for issue in cvej:
    fn = issue['CVE_data_meta']['ID'] + ".json"
    if not issue:
       continue

    f = codecs.open(options.outputdir+"/"+fn, 'w', 'utf-8')
    f.write(json.dumps(issue, sort_keys=True, indent=4))
    print "wrote %s" %(options.outputdir+"/"+fn)
    f.close()

    try:
       validate(issue, schema_doc)
       print "%s passed validation" % (fn)
    except jsonschema.exceptions.ValidationError as incorrect:
       v = Draft4Validator(schema_doc)
       errors = sorted(v.iter_errors(issue), key=lambda e: e.path)
       for error in errors:
          print "%s did not pass validation: %s" % (fn,str(error.message))
    except NameError:
       print "%s skipping validation, no schema defined" %(fn)
       
