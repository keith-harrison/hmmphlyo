with open("names.txt") as namesfile:
    names = namesfile.read().splitlines() 

with open("Taxa.txt") as taxasfile:
    taxas = taxasfile.read().splitlines() 

treefile = open("treefile", "r")
tree = treefile.readlines()[0].strip()
result = zip(names,taxas)

result = sorted(result,key=lambda t: len(t[0]), reverse=True)
print(list(result)[0][0])
#NEED TO SORT ZIPPED OBJECT BY LONGEST TO SHORTEST NAMES
for name, taxa in result:
    tree = tree.replace(name, taxa)
newtree = open("newtreefile","w")
newtree.write(tree)