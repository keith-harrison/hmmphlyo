import requests, sys, re
while True:
    try:
        filename = input("Enter File name (fixes ids to instead be organism names): ")
        fastafile = open(filename, "r")
        break   
    except FileNotFoundError:
        print("File not found")
name = open("filename.txt","w")
foldername = filename.split(".", 1)[0]
name.write(foldername)
name.close()

newname = "fixed"+filename
#TURN INTO SINGLE LINE FASTA
with open(filename) as f_input, open(newname, 'w') as f_output:
    block = []

    for line in f_input:
        if line.startswith('>'):
            if block:
                f_output.write(''.join(block) + '\n')
                block = []
            f_output.write(line)
        else:
            block.append(line.strip())

    if block:
        f_output.write(''.join(block) + '\n')
#READLINE OF FILES
fastafile = open(newname, "r")
fastalines = fastafile.readlines()


        
newlines = []
for i in range(len(fastalines)):
    if fastalines[i][0] == ">":
        uniprotid = (str(fastalines[i][1:]).rstrip("\n").split("/", 1)[0])
        try:
            requestURL = str("https://www.uniprot.org/uniprot/"+uniprotid)
            r = requests.get(requestURL, headers={ "Accept" : "application/xml"})
            try:
                #try catch loop add
                responseBody = r.text
                result = re.search('OS=(.*)OX=', responseBody)
                newlines.append("\n>"+result.group(1).rstrip().replace(" ", "_")+"\n")
                newlines.append(fastalines[i+1])
            except:
                print("website not found for: "+uniprotid)
        except:
            print("website not found for: "+uniprotid)
newname = "fixed"+filename
f = open(newname,"w")
f.close()
f = open(newname,"a")

f.writelines(newlines)
f.close()