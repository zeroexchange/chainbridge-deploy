import fileinput

for line in fileinput.input():
    if line.startswith('Erc20:'):
        print(line.split()[1])
        break
