filename = "concatenated_ready_seq.fa"
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