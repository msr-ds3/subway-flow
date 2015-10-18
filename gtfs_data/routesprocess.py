import re

f1 = open("routes.txt")
routes = f1.readlines()

pattern1 = re.compile('^([A-Z1-7]),')
pattern2 = re.compile(',([A-Z0-9]{6}),')
dict1 = {}
for route in routes:
    a = pattern1.findall(route)
    b = pattern2.findall(route)
    if len(a) > 0 and len(b) > 0:

        dict1[a[0]] = b[0]

f1.close()

for a in dict1:
    print a + "," + dict1[a]









