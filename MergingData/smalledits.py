
file1 = open("unmatchedwords.txt")
words = file1.readlines()


for w in words:
    print w, "!"



file1.close()

