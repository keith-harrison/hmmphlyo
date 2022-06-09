import requests, sys, re


#try catch valid file name
while True:
    try:
        filename = input("Enter File name: ")
        fastafile = open(filename, "r")
        break   
    except FileNotFoundError:
        print("File not found")

fastalines = []
for i in fastafile:
    if i[0] == ">":
        fastalines.append(str(i[1:]).rstrip("\n").split("/", 1)[0])



newlines = []

for uniprotid in fastalines:
    try:
        requestURL = str("https://www.uniprot.org/uniprot/"+uniprotid+".fasta")
        r = requests.get(requestURL, headers={ "Accept" : "application/xml"})
        try:
            #try catch loop add
            responseBody = r.text
            newsequence = []
            lines = responseBody.split("\n")
            lines = filter(None,lines)
            for i in lines:
                if i[0] != ">":
                    newsequence.append(i)
            newlines.append(">"+uniprotid)
            newlines.append("".join(newsequence)+"\n")
        except:
            newlines.append(">"+uniprotid)
    except:
        newlines.append(">"+uniprotid)
        

#iterate through newlines and remove lines that start with > if the next element is blank
indexestoremove=[]
for i in range(len(newlines)):
    if newlines[i][0] == ">":
        if newlines[i+1] == "\n":
            indexestoremove.append(i)
#remove the lines with indexes in indexestoremove
newlines= [i for j, i in enumerate(newlines) if j not in indexestoremove]

content =  "\n".join(newlines)
file = open("full"+filename, "w")
file.write(content)
file.close()

#Now we want to go through and fix the fasta headers ids to now be their taxonomy
        

