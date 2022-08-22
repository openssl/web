#! /usr/bin/python3
#
# Convert our JSON vulnerability files to HTML files for the web page

import json
import codecs
import os
import re
import xml.sax.saxutils as saxutils 
from optparse import OptionParser
import datetime
import sys
parser = OptionParser()
 
parser.add_option("-b","--base",help="major version to filter on",dest="base")
parser.add_option("-i","--inputdirectory",help="directory of json files",dest="directory")
(options,args) = parser.parse_args()

def natural_sort_key(s, _nsre=re.compile('([0-9]+)')):
    return [int(text) if text.isdigit() else text.lower()
            for text in _nsre.split(s)]   

def getbasefor(fixedin):
    dotparts = re.search('^(\d)\.(\d)\.(\d)',fixedin)
    if not dotparts:
        return None
    if int(dotparts.group(1))<3:
        # Old style, the base is first 3 digits no letters
        return dotparts.group(1)+"."+dotparts.group(2)+"."+dotparts.group(3)
    return dotparts.group(1)+"."+dotparts.group(2)        

base = options.base or ""
cves = []
entries = {}
allbase = []

for x in os.listdir(options.directory or "./"):
    if x.endswith(".json"):
        try:
            fd = codecs.open(options.directory+x,"r","utf-8")
            cve = json.load(fd)
            cves.append(cve)
        except:
            print ("Ignoring due to error parsing: "+options.directory+x)
            continue

# Filter on version 
# We want to sort on reverse date then cve name
statements = ""
disputedcve = {}
for cve in cves:
    if "statements" in cve:
        for statement in cve["statements"]:
            if (statement["base"] in (options.base or "none")):
                statements +="<p>"+statement["text"].strip()+"</p>"
    if "disputed" in cve:
        for dispute in cve["disputed"]:
            disputedcve[dispute["cve"]]=dispute
    if "containers" in cve:
        cna = cve["containers"]["cna"]
        cveid = cve["cveMetadata"]["cveId"]
        for version in cna["affected"][0]["versions"]:
            fixedin = version["version"]
            fixedbase = getbasefor(fixedin)
            if fixedbase and fixedbase not in allbase:
                allbase.append(fixedbase)
            if (fixedin.startswith(base)):
                datepublic = cna["datePublic"]+"-"+cveid
                entries[datepublic]=cve

allbase = sorted(allbase, reverse=True)
           
lastfixedv = ""
productname = ""
sections = []
lastyear = ""
allyears = []
allissues = ""
for k,cve in sorted(entries.items(), reverse=True):
    year = k.split('-')[0]

    if (lastyear != year):
        if (lastyear != ""):
            allissues += "</dl>";
        allissues += "<h3><a name=\"y%s\">%s</a></h3>\n<dl>" %(year,year)            
        allyears.append(year)
        lastyear = year

    cna = cve["containers"]["cna"]
    e = {}
    cveid = cve["cveMetadata"]["cveId"]

    allissues += "<dt>"
    # CVE name
    if cve:
        allissues += "<a href=\"https://cve.org/CVERecord?id=%s\" name=\"%s\">%s</a> " %(cveid,cveid,cveid)        

    # Advisory (use the title instead of openssl advisory)
    title= "(OpenSSL Advisory)"
    refs = ""
    if "title" in cna:
        title = cna['title']
        refs = title
    for ref in cna["references"]:
        if "tags" in ref:
            if "vendor-advisory" in ref["tags"]:
                url = ref["url"]
                refs = "<a href=\""+url+"\">"+title+"</a>"
    allissues += " "+refs

    # Impact
    for metric in cna["metrics"]:
        if "other" in metric["format"]:
            impact = metric["other"]["content"]["text"]
            if not "unknown" in impact:
                 allissues += " <a href=\""+metric["other"]["type"]+"\">["+impact+" severity]</a>"
            
    # Date
    datepublic =cna["datePublic"]
    t = datetime.datetime(int(datepublic[:4]), int(datepublic[5:7]), int(datepublic[8:10]), 0, 0)
    allissues += t.strftime(" %d %B %Y: ")    

    allissues += "<a href=\"#toc\"><img src=\"/img/up.gif\"/></a></dt>\n<dd>"
    
    # Description
    for desc in cna["descriptions"]:
        allissues += desc["value"]

    # Credits
    if ("credits" in cna):
        for credit in cna["credits"]:
            creditprefix = " Reported by "
            if "type" in credit and "remediation dev" in credit["type"]:
                creditprefix = " Fix developed by "
            elif "type" in credit and "finder" not in credit["type"]:
                creditprefix = " Thanks to "
            allissues += creditprefix+credit["value"]+"."

    affects = []
    product = cna["affected"][0]
    productname = product['product']
    allissues += "<ul>"
    also = []
    for ver in product["versions"]:
        if "lessThan" in ver:
            fixedin = ver["lessThan"]
            earliest = ver["version"]
            git = ""
            for reference in cna["references"]:
                if reference["name"].startswith(fixedin+" git"):
                    git = reference["url"]

            if base:
                if (not earliest.startswith(base)):
                    also.append("OpenSSL <a href=\"vulnerabilities-%s.html#%s\">%s</a>" %( getbasefor(earliest), cveid, fixedin))
                    continue
            allissues += "<li>Fixed in OpenSSL %s " %(fixedin)
            if (git != ""):
                allissues += "<a href=\"%s\">(git commit)</a> " %(git)
            allissues += "(Affected since "+earliest+")"       
            allissues += "</li>"
    if also:
         allissues += "<li>This issue was also addressed in "+ ", ".join( also)
    allissues += "</ul></dd>\n"

preface = "<!-- do not edit this file it is autogenerated, edit vulnerabilities.xml -->"
bases = []
for base in allbase:
    if (options.base and base in options.base):
        bases.append("%s" %(base))
    else:
        bases.append( "<a href=\"vulnerabilities-%s.html\">%s</a>" %(base,base))
preface += "<p>Show issues fixed only in OpenSSL " + ", ".join(bases)
if options.base:
    preface += ", or <a href=\"vulnerabilities.html\">all versions</a></p>"
    preface += "<h2>Fixed in OpenSSL %s</h2>" %(options.base)
else:
    preface += "</p>"
preface += statements
if len(allyears)>1: # If only vulns in this year no need for the year table of contents
    preface += "<p><a name=\"toc\">Jump to year: </a>" + ", ".join( "<a href=\"#y%s\">%s</a>" %(year,year) for year in allyears)
preface += "</p>"
if allissues != "":
    preface += allissues + "</dl>"
else:
    preface += "No vulnerabilities fixed"

nonissues = ""
for nonissue in disputedcve:
    if (not options.base or disputedcve[nonissue]["base"] in (options.base or "none")):
        nonissues += "<li><a href=\"https://cve.org/CVERecord?id=%s\" name=\"%s\">%s</a>: " %(nonissue,nonissue,nonissue)        
        nonissues += disputedcve[nonissue]["text"]
        nonissues +="</li>"
if (nonissues != ""):
    preface += "<h3>Not Vulnerabilities</h3><ul>" + nonissues + "</ul>"    

sys.stdout.reconfigure(encoding='utf-8')
sys.stdout.write(preface)
