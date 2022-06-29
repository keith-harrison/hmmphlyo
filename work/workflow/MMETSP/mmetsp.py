from taxonomy_ranks import TaxonomyRanks
import csv
import pandas as pd
df = pd.read_csv("MMETSPinfo.csv")

#loop through rows in df and run rank_taxon on them
for index, row in df.iterrows():
    #make new column for taxon
    #print size of df
    try:
        rank_taxon = TaxonomyRanks(row['Genus'])
        rank_taxon.get_lineage_taxids_and_taxanames()
        taxon = str(list(rank_taxon.lineages)[0])
        df.loc[index, "Taxon"] = taxon
    except:
        df.loc[index, "Taxon"] = "NA"

#make a list of MMETSP ids that have a valid taxon column
keep_list = []
for index, row in df.iterrows():
    if row['Taxon'] != "NA":
        keep_list.append(row['ID'])
#concatenate files together that have the same taxon
#group MMETSP ids by taxon not including NA
df = df[df["Taxon"] != "NA"]

#add .pep suffix to ID column
df["ID"] = df["ID"] + ".pep"
#get all unique taxas
taxas = df["Taxon"].unique()

for i in taxas:
    #write file called i.pep
    with open(i + ".pep", "w") as f:
        #write contents to file if the taxon is in the row
        for index, row in df.iterrows():
            if row["Taxon"] == i:
                #open file from row["ID"]
                with open(row["ID"]) as g:
                    #write contents of g to f
                    for line in g:
                        f.write(line)

