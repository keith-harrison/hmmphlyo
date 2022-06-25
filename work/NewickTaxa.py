import requests, sys, re


fastafile = open("Uniprot.txt", "r")
fastalines = fastafile.readlines()
     
newlines = []
for i in range(len(fastalines)):
    uniprotid = fastalines[i]
    try:
        requestURL = str("https://www.uniprot.org/uniprot/"+uniprotid)
        r = requests.get(requestURL, headers={ "Accept" : "application/xml"})
        try:
            responseBody = r.text
            result = re.search('href="/taxonomy/(.*)">(.*)</a>', responseBody)
            newlines.append(result.group(1).split('"')[0]+"\n")
        except:
            print("website not found for: "+uniprotid)
    except:
        print("website not found for: "+uniprotid)
newname = "taxas.txt"
f = open(newname,"w")
f.close()
f = open(newname,"a")

f.writelines(newlines)
f.close()
