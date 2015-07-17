f1 = open("stops2.txt")

file2 = f1.readlines()

def addressdistance(turnstile, google):
    arr1 = turnstile.replace('-', ' ').split(' ')
    arr2 = google.replace('-', ' ').split(' ')
    
    numbers = re.compile(r'[0-9]+ [avstrd]{2}')



