import re
while True:
    try:
        filename = input("Enter File name (MMETSP style headers e.g. hitsTara.fa): ")
        fastafile = open(filename, "r")
        break   
    except FileNotFoundError:
        print("File not found")

#remove all text in > headers after second |
fastalines = fastafile.readlines()
file = open(filename,"w")
for i in range(len(fastalines)):
    if fastalines[i][0] == ">":
        splitline = fastalines[i].split()
        header=splitline[-1]
        header =re.sub(r'\W+', '_', header)
        file.write(">"+header+"\n")
    else:
        file.write(fastalines[i])
file.close()
