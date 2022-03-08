filename="datalog.txt"
outputname="out.csv"
bytes = ""
output = ""
with open(filename, "rb") as f:
    with open(outputname, "w") as g:
        while True:
            if bytes != '':
                output = ','
            bytes = f.read(4)
            if len(bytes) < 4:
                break
            number=int.from_bytes(bytes, byteorder='little')
            output = output + str(number)
            g.write(output)
