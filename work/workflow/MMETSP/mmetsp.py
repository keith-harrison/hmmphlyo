

import csv
from subprocess import ABOVE_NORMAL_PRIORITY_CLASS
import pandas as pd
df = pd.read_csv("MMETSPinfo.csv")
#print first column 
keep = df.iloc[:,0]
#delete files in current directory that are not in the list
'''
if we want to remove mmetsp files that are bad we can use the following code
import os
for file in os.listdir("."):
    

    if file not in keep.tolist():
        os.remove(file)
        print("removed: " + file)
'''
print("unid." not in "unid. Prasinophyte Clade VIIA1")
#print each record
#write each row's genus to a file
with open("genus.txt", "w") as f:
    for index, row in df.iterrows():
        #only write if not Undescribed or contains the string 'unid'
        #print(row["Genus"])
        if row["Genus"] != "Undescribed" and ("unid" not in row["Genus"]) and ('nov.' not in row["Genus"]) and ("Unid." not in row["Genus"]) and ("Unknown" not in row["Genus"]):
            f.write(row["Genus"] + "\n")


#zip togehter mmetsp ids and the genus they belong to
#remove those at match th eif statement above
#Remove mmetsp files that do not match 


