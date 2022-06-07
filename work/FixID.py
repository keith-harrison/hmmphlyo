import requests, sys, re
filename = input("Enter File name: ")
name = open("filename.txt","w")
foldername = filename.split(".", 1)[0]
name.write(foldername)
name.close()
#try catch valid file name
while True:
    try:
        fastafile = open(filename, "r")
        break   
    except FileNotFoundError:
        print("File not found")



fastalines = []
for i in fastafile:
    if i[0] == ">":
        fastalines.append(str(i[1:]).rstrip("\n").split("/", 1)[0])

        
newlines = []
removeids = []
for uniprotid in fastalines:
    requestURL = str("https://www.uniprot.org/uniprot/"+uniprotid)

    r = requests.get(requestURL, headers={ "Accept" : "application/xml"})

    if not r.ok:
        r.raise_for_status()
        sys.exit()
        newlines.append((uniprotid+"removed"))
        #add to remove from list
        
    else:
        try:
            #try catch loop add
            responseBody = r.text
            result = re.search('OS=(.*)OX=', responseBody)
            newlines.append(result.group(1).split("</name>",1)[0].rstrip())
        except:
            newlines.append((uniprotid+"removed"))
fastafile = open(filename, "r")
fastafile = fastafile.readlines()
counter = 0
newname = "fixed"+filename
f = open(newname,"w")
f.close()
f = open(newname,"a")
for i in range(len(fastafile)):
    try:
        if fastafile[i][0] == ">":
            if "removed" not in newlines[counter]:
                fastafile[i] = ">"+newlines[counter]+"\n"
                counter+=1
            else:
                #if we do not want sequence remove from > to next > found
                fastafile.pop(i)
                nextcarrot = False
                while nextcarrot == False:
                    if fastafile[i+1][0] == ">":
                        nextcarrot=True
                        fastafile.pop(i)
                    else:
                        fastafile.pop(i)
                counter+=1
                if "removed" not in newlines[counter]:
                    fastafile[i] = ">"+newlines[counter]+"\n"
                    counter+=1
                else:
                    #if we do not want sequence remove from > to next > found
                    fastafile.pop(i)
                    nextcarrot = False
                    while nextcarrot == False:
                        if fastafile[i+1][0] == ">":
                            nextcarrot=True
                            fastafile.pop(i)
                        else:
                            fastafile.pop(i)
                    counter+=1
                    if "removed" not in newlines[counter]:
                        fastafile[i] = ">"+newlines[counter]+"\n"
                        counter+=1
    except:
        #file is now shorter so indexes will overshoot so just finish early
        break
f.writelines(fastafile)
f.close()