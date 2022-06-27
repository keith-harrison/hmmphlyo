import pandas as pd
import requests, sys, re

#try catch valid file name
while True:
    try:
        startfilename = input("Enter start domain alignment:")
        startfile = open(startfilename, "r")
        break   
    except FileNotFoundError:
        print("File not found")
#Make a bunch bunch of nested arrays which follow format [ID,Start,End,Taxa]
array = []
startlines = startfile.readlines()
#Get all start locations
for i in range(len(startlines)):
    if startlines[i][0] == ">":
        startNO = (str(startlines[i][1:]).rstrip("\n").split("/", 1)[1]).split("-",1)[0]        
        uniprotid = (str(startlines[i][1:]).rstrip("\n").split("/", 1)[0])
        array.append([uniprotid,startNO,0])

#Get all end Locations    
while True:
    try:
        endfilename = input("Enter end domain alignment:")
        endfile = open(endfilename, "r")
        break   
    except FileNotFoundError:
        print("File not found")
#make end array just the uniprotID and endNO
endArray = []
endlines = endfile.readlines()
for i in range(len(endlines)):
    if endlines[i][0] == ">":
        endNO = (str(endlines[i][1:]).rstrip("\n").split("/", 1)[1]).split("-",1)[1]   
        uniprotid = (str(endlines[i][1:]).rstrip("\n").split("/", 1)[0])
        endArray.append([uniprotid,endNO])

#Loop through Array and endArray adding endNo to array if there is matching uniprotID
for i in range(len(array)):
    for j in range(len(endArray)):
        if array[i][0]==endArray[j][0]:
            array[i][2] = endArray[j][1]


#Remove empty sequences, traverse backwards or ELSE INDEX ERRORS!!! >_>
for list in array[::-1]:
    #If end element is missing
    if list[2]==0:
        array.remove(list)
#Now have an array of all the IDs and their start and stop
#Webscrap the whole sequence and its taxa.

file = open("full.fasta", "w")
file.close()
for i in range(len(array)):
    try:
        requestFasta = str("https://www.uniprot.org/uniprot/"+array[i][0]+".fasta")
        rFasta = requests.get(requestFasta, headers={ "Accept" : "application/xml"})

        requestTaxa = str("https://www.uniprot.org/uniprot/"+array[i][0])
        rTaxa = requests.get(requestTaxa, headers={ "Accept" : "application/xml"})
        try:
            #Get taxa number
            responseTaxa = rTaxa.text
            resultTaxa = re.search('href="/taxonomy/(.*)">(.*)</a>', responseTaxa)
            resultTaxa = resultTaxa.group(1).split('"')[0]
            responseFasta = rFasta.text
            newsequence = ""
            lines = responseFasta.split("\n")
            lines = filter(None,lines)
            for j in lines:
                if j[0] != ">":
                    newsequence=str(newsequence+j.strip())
            file = open("full.fasta","a")
            file.write(">"+resultTaxa+"\n")
            start = int(array[i][1])-1
            end = int(array[i][2])
            file.write(newsequence[start:end]+"\n")
            #Write results to file
            file.close()

        except Exception as e: print(e)
            #print("Could not find Taxa or Fasta Sequence")
            
    except Exception as e: print(e)
        #print("Could not find Taxa or Fasta Sequence")

file.close()
#Maybe get all the middle IDs and make sure they are all in there