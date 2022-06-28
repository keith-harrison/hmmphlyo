filename = "fixedconcatenated_ready_seq.fa"
oldname = "concatenated_ready_seq.fa"
#TURN INTO SINGLE LINE FASTA
with open(oldname) as f_input, open(filename, 'w') as f_output:
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