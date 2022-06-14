import json
import os
import re
import xml.sax.saxutils as saxutils 
from optparse import OptionParser
parser = OptionParser()
 
parser.add_option("-v","--version",help="major version to filter on",dest="filterversion")
parser.add_option("-e","--extratext",help="extra text to add to description",dest="extratext")
parser.add_option("-i","--inputdirectory",help="directory of json files",dest="directory")
(options,args) = parser.parse_args()


def natural_sort_key(s, _nsre=re.compile('([0-9]+)')):
    return [int(text) if text.isdigit() else text.lower()
            for text in _nsre.split(s)]   
            
filterversion = options.filterversion or ""
cves = []
entries = {}

for x in os.listdir(options.directory or "./"):
    if x.endswith(".json"):
        try:
            fd = open(options.directory+x)
            cve = json.load(fd)
            cves.append(cve)
        except:
            print ("Ignoring due to error parsing: "+options.directory+x)
            continue

# Filter on version 
# We want to sort on reverse date then cve name
for cve in cves:
    cna = cve["containers"]["cna"]
    cveid = cve["cveMetadata"]["cveId"]
    for version in cna["affected"][0]["versions"]:
       fixedin = version["version"]
       if (fixedin.startswith(filterversion)):
           datepublic = cna["datePublic"]+"-"+cveid
           entries[datepublic]=cve

lastfixedv = ""
productname = ""
sections = []
lastyear = ""
for k,cve in sorted(entries.items(), reverse=True):
    year = k.split('-')[0]

    if (lastyear != year):
        print("<h1>"+year+"</h1>")
        lastyear = year

    cna = cve["containers"]["cna"]
    e = {}
    e['cveid'] = cve["cveMetadata"]["cveId"]

    # CVE name
    print("<a href=\"https://cve.org/CVERecord?id="+e['cveid']+"\">"+e['cveid']+"</a>")

    # Advisory (use the title instead of openssl advisory)
    title= "(OpenSSL Advisory)"
    if "title" in cna:
        title = cna['title']
    refs = title
    for ref in cna["references"]:
        if "tags" in ref:
            if "vendor-advisory" in ref["tags"]:
                url = ref["url"]
                refs = "<a href=\""+url+"\">"+title+"</a>"
    print (" "+refs)

    # Impact
    for metric in cna["metrics"]:
        if "other" in metric["format"]:
            impact = metric["other"]["content"]["text"]
            if not "unknown" in impact:
                print(" <a href=\""+metric["other"]["type"]+"\">["+impact+" severity]</a>")
            
    # Date
    datepublic =cna["datePublic"]
    print(" "+datepublic)

    # Description
    for desc in cna["descriptions"]:
        print(desc["value"])

    # Credits
    if ("credits" in cna):
        for credit in cna["credits"]:
            print("Reported by "+credit["value"])

    affects = []
    product = cna["affected"][0]
    productname = product['product']
    for ver in product["versions"]:
        if "lessThan" in ver:
            fixedin = ver["lessThan"]
            earliest = ver["version"]
            git = ""
            for reference in cna["references"]:
                if reference["name"].startswith(fixedin+" git"):
                    git = reference["url"]
                    text = "Fixed in "+productname+" "+fixedin
                    if (git != ""):
                        text += " <a href=\""+git+"\">(git commit)</a>"
                    text += " (Affected since "+earliest+")"
                    print (text)

    # Got everything ready to print out now
    
# Everything is sorted and pretty, this should be some python template thing

print ("<h1>"+productname+" "+filterversion+" vulnerabilities</h1>")
print ("<p>This page lists all security vulnerabilities fixed in released versions of "+productname+" "+filterversion+". Each vulnerability is given a security <a href=\"/security/impact_levels.html\">impact rating</a> by the Apache security team - please note that this rating may well vary from platform to platform.  We also list the versions the flaw is known to affect, and where a flaw has not been verified list the version with a question mark.</p>")
print ("<p>Please note that if a vulnerability is shown below as being fixed in a \"-dev\" release then this means that a fix has been applied to the development source tree and will be part of an upcoming full release.</p>")
print ("<p>Please send comments or corrections for these vulnerabilities to the <a href=\"/security_report.html\">Security Team</a>.</p> <br/>")

if (options.extratext):
    print ("<p>"+options.extratext+"</p><br/>")

for sectioncves in sections:
    print ("\n<h1 id=\""+sectioncves["fixed"]+"\">Fixed in "+sectioncves["product"]+" "+sectioncves["fixed"]+"</h1><dl>\n")
    for e in sectioncves["cves"]:
        html = "<dt><h3 id=\""+e['cveid']+"\">"+e['impact']+": <name name=\""+e['cveid']+"\">"+saxutils.escape(e['title'])+"</name>\n";
        html += "(<a href=\"https://cve.mitre.org/cgi-bin/cvename.cgi?name="+e['cveid']+"\">"+e['cveid']+"</a>)</h3></dt>\n";
        desc = saxutils.escape(e['desc'])
        desc = re.sub(r'\n','</p><p>', desc)
        html += "<dd><p>"+desc+"</p>\n"
        if (e['credit'] != ""): html += "<p>Acknowledgements: "+saxutils.escape(e['credit'])+"</p>\n"
        html += "<table class=\"cve\">"
        e['timetable'].append(["Affects",e['affects']]);
        for ti in e['timetable']:
            html+= "<tr><td class=\"cve-header\">"+ti[0]+"</td><td class=\"cve-value\">"+ti[1]+"</td></tr>\n"
        html+= "</table></dd>"
        print (html.encode("utf-8"))
    print ("</dl></br/>")


