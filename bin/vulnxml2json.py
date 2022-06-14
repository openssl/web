#! /usr/bin/python3
#
# Convert our XML file to a JSON file as accepted by Mitre for CNA purposes
# as per https://github.com/CVEProject/automation-working-group/blob/master/cve_json_schema/DRAFT-JSON-file-format-v4.md
#
# ASF httpd and OpenSSL use quite similar files, so this script is designed to work with either
#

from xml.dom import minidom
import html
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

# Specific project stuff is here
import vulnxml2jsonproject as cfg

# Location of CVE JSON schema (default, can use local file etc)
default_cve_schema = "https://raw.githubusercontent.com/CVEProject/automation-working-group/master/cve_json_schema/CVE_JSON_4.0_min_public.schema"

parser = OptionParser()
parser.add_option("-s", "--schema", help="location of schema to check (default "+default_cve_schema+")", default=default_cve_schema,dest="schema")
parser.add_option("-i", "--input", help="input vulnerability file vulnerabilities.xml", dest="input")
parser.add_option("-c", "--cve", help="comma separated list of cve names to generate a json file for (or all)", dest="cves")
parser.add_option("-o", "--outputdir", help="output directory for json file (default ./)", default=".", dest="outputdir")
(options, args) = parser.parse_args()

if not options.input:
   print("needs input file")
   parser.print_help()
   exit();

if options.schema:
   try:
      response = urllib.request.urlopen(options.schema)
   except:
      print(f'Problem opening schema: try downloading it manually then specify it using --schema option: {options.schema}')
      exit()
   schema_doc = json.loads(response.read())

cvej = list()
    
with codecs.open(options.input,"r","utf-8") as vulnfile:
    vulns = vulnfile.read()
dom = minidom.parseString(vulns.encode("utf-8"))

for issue in dom.getElementsByTagName('issue'):
    if not issue.getElementsByTagName('cve'):
        continue
    # ASF httpd has CVE- prefix, but OpenSSL does not, make either work
    cvename = issue.getElementsByTagName('cve')[0].getAttribute('name').replace('CVE-','')
    if (cvename == ""):
       continue
    if (options.cves): # If we only want a certain list of CVEs, skip the rest
       if (not cvename in options.cves):
          continue

    cve = dict()
    cve['data_type']="CVE"
    cve['data_format']="MITRE"
    cve['data_version']="4.0"
    cve['CVE_data_meta']= { "ID": "CVE-"+cvename, "ASSIGNER": cfg.config['cve_meta_assigner'], "STATE":"PUBLIC" }
    datepublic = issue.getAttribute("public")
    if datepublic:
       cve['CVE_data_meta']['DATE_PUBLIC'] = datepublic[:4]+'-'+datepublic[4:6]+'-'+datepublic[6:8]
    if issue.getElementsByTagName('title'):
        cve['CVE_data_meta']['TITLE'] = issue.getElementsByTagName('title')[0].childNodes[0].nodeValue.strip()
    desc = ""
    for d in issue.getElementsByTagName('description')[0].childNodes:
#        if d.nodeType == d.ELEMENT_NODE:
            if desc:
                desc += " "
            desc += re.sub('<[^<]+?>', '', d.toxml().strip())
    desc = html.unescape(desc)
    problemtype = "(undefined)"
    if issue.getElementsByTagName('problemtype'):
        problemtype = issue.getElementsByTagName('problemtype')[0].childNodes[0].nodeValue.strip()    
    cve['problemtype'] = { "problemtype_data": [ { "description" : [ { "lang":"eng", "value": problemtype} ] } ] }
    impact = issue.getElementsByTagName('impact') # openssl does it like this
    if impact:
        cve['impact'] = [ { "lang":"eng", "value":impact[0].getAttribute('severity'), "url":cfg.config['security_policy_url']+impact[0].getAttribute('severity').lower() } ]
    impact = issue.getElementsByTagName('severity')  # httpd does it like this
    if impact:
        cve['impact'] = [ { "lang":"eng", "value":impact[0].childNodes[0].nodeValue, "url":cfg.config['security_policy_url']+impact[0].childNodes[0].nodeValue } ]

    # Create the list of credits
    
    credit = list()
    for reported in issue.getElementsByTagName('reported'):  # openssl style credits
        credit.append( { "lang":"eng", "value":re.sub('[\n ]+',' ', reported.getAttribute("source"))} )
    for reported in issue.getElementsByTagName('acknowledgements'): # ASF httpd style credits
        credit.append(  { "lang":"eng", "value":re.sub('[\n ]+',' ', reported.childNodes[0].nodeValue.strip())} )
    if credit:
        cve['credit']=credit        

    # Create the list of references
        
    refs = list()
    for adv in issue.getElementsByTagName('advisory'):
       url = adv.getAttribute("url")
       if (not url.startswith("htt")):
          url = cfg.config['default_reference_prefix']+url
       refs.append({"url":url,"name":url,"refsource":"CONFIRM"})
    for git in issue.getElementsByTagName('git'): # openssl style references to git
       url = cfg.config['git_prefix']+git.getAttribute("hash")
       refs.append({"url":url,"name":url,"refsource":"CONFIRM"})       
    if cfg.config['project'] == 'httpd': # ASF httpd has no references so fake them
       for fixed in issue.getElementsByTagName('fixed'):
          base = "".join(fixed.getAttribute("version").split('.')[:-1])
          refurl = cfg.config['default_reference']+base+".html#CVE-"+cvename
          refs.append({"url":refurl,"name":refurl,"refsource":"CONFIRM"})
    if refs:
        cve['references'] = { "reference_data": refs  }

    # Create the "affected products" list
        
    vv = list()
    for affects in issue.getElementsByTagName('fixed'): # OpenSSL and httpd since April 2018 does it this way
       text = f'Fixed in {cfg.config["product_name"]} {affects.getAttribute("version")} (Affected {cfg.merge_affects(issue,affects.getAttribute("base"))})'
       # Let's condense into a list form since the format of this field is 'free text' at the moment, not machine readable (as per mail with George Theall)
       vv.append({"version_value":text})
       # Mitre want the fixed/affected versions in the text too
       desc += " "+text+"."

#    if issue.getAttribute('fixed'): # httpd used to do it this way
#        base = ".".join(issue.getAttribute("fixed").split('.')[:-1])+"."
#        text = f'Fixed in {cfg.config["product_name"]} {cfg.merge_affects(issue,base)}'
#        vv.append({"version_value":text})
#        # Mitre want the fixed/affected versions in the text too
#        desc += " "+text+"."            

    cve['affects'] = { "vendor" : { "vendor_data" : [ { "vendor_name": cfg.config['vendor_name'], "product": { "product_data" : [ { "product_name": cfg.config['product_name'], "version": { "version_data" : vv}}]}}]}}
            
    # Mitre want newlines and excess spaces stripped
    desc = re.sub('[\n ]+',' ', desc)        
    cve['description'] = { "description_data": [ { "lang":"eng", "value": desc} ] }
    cvej.append(cve)
        
for issue in cvej:
    fn = issue['CVE_data_meta']['ID'] + ".json"
    if not issue:
       continue

    f = codecs.open(options.outputdir+"/"+fn, 'w', 'utf-8')
    f.write(json.dumps(issue, sort_keys=True, indent=4, separators=(',',': ')))
    print(f'wrote {options.outputdir+"/"+fn}')
    f.close()

    try:
       validate(issue, schema_doc)
       print(f'{fn} passed validation')
    except jsonschema.exceptions.ValidationError as incorrect:
       v = Draft4Validator(schema_doc)
       errors = sorted(v.iter_errors(issue), key=lambda e: e.path)
       for error in errors:
          print(f'{fn} did not pass validation: {str(error.message)}')
    except NameError:
       print(f'{fn} skipping validation, no schema defined')
       
