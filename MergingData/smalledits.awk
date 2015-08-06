# CURRENT
# Riva Tropp
# 7/27/2015
# Does a bunch of tiny edits on names too distant for a_names_script_v2.py to match them.

function shut(list){
    if(close(list)){
	print list "failed to close" > "/dev/stderr";
    }
}
#Transformed_Turnstile, Distance, Orig_Google, Transformed_Google, Orig_Turnstile
function change_g(a, b, c, d, e, newstring){
    b = 0
    c = d = newstring
    print a " , " b " , " c " , " d " , " e > file3
}
function change_t(a, b, c, d, e, newstring){
    b = 0
    a = e = newstring
    print a " , " b " , " c " , " d " , " e > file3
}
BEGIN{
file1 = "easymatches.txt"
file2 = "unmatchedwords.txt"
file3 = "readyformerge.txt"

FS = ","
while((getline < file1) > 0)
    print $0 > file3

while((getline < file2) > 0){

    a = $1
    b = $2
    c = $3
    d = $4

    if ($1 == " jfk jamaica ct1")
	change_g(a, b, c, d, $5, "Jamaica Center - Parsons/Archer") 
    else if ($1 == " e 177 st parkch")
	change_g(a, b, c, d, $5, "Parkchester") 
    else if ($1 == " 81 st museum")
	change_g(a, b, c, d, $5, "81 St - Museum of Natural History") 
    else if ($1 == " jfk howard bch")
	change_g(a, b, c, d, $5, "Howard Beach - JFK Airport") 
    else if ($1 == " howard bch jfk")
	change_g(a, b, c, d, $5, "Howard Beach - JFK Airport") 
    else if ($1 == " ditmars bl 31 s")
	change_g(a, b, c, d, $5, "Astoria - Ditmars Blvd") 
    else if ($1 == " union tpk kew g")
	change_g(a, b, c, d, $5, "Kew Gardens - Union Tpke") 
    else if ($1 == " barclays center")
	change_g(a, b, c, d, $5, "Atlantic Av - Barclays Ctr") 
    else if ($1 == " greenwood 111")
	change_g(a, b, c, d, $5, "111 St") 
    else if ($1 == " rit roosevelt")
	change_g(a, b, c, d, $5, "Roosevelt Island") 
    else if ($1 == " THIRTY THIRD ST")
	change_g(a, b, c, d, $5, "None") #No PATH
    else if ($1 == " 7 av 53 st") #There are three of these in the google data, with three different lat/longs.
	change_g(a, b, c, d, $5, "7 Av")
    else if ($1 == "twenty third st")
	change_g(a, b, c, d, $5, "None") #No PATH}#PATH
    else if ($1 == " rit manhattan")
	change_g(a, b, c, d, $5, "None") #No PATH
    #I don't even know what this is.
    else if ($1 == " jamaica center") #Two of these in TS data, 1 in google?
	change_g(a, b, c, d, $5, "Jamaica Center - Parsons/Archer") 
    else if ($1 == " path wtc 2")
	change_g(a, b, c, d, $5, "None") 
#PATH. Possible connection to E, have not been able to confirm?
    else if ($1 == " van wyck blvd")
	change_g(a, b, c, d, $5, "Briarwood - Van Wyck Blvd") 
    else if ($1 == " lefferts blvd")
	change_g(a, b, c, d, $5, "Ozone Park - Lefferts Blvd") 
    else if ($1 == " washington 36 a")
	change_g(a, b, c, d, $5, "36 Av") 
    else if ($1 == " e 143 st")
	change_g(a, b, c, d, $5, "E 143 St - St Mary's St") 
    else if ($1 == " hoyt st astoria")
	change_g(a, b, c, d, $5, "Astoria Blvd") 
    else if ($1 == " stillwell av")
	change_g(a, b, c, d, $5, "Coney Island - Stillwell Av") 
    else if ($1 == " 5 av bryant pk")
	change_g(a, b, c, d, $5, "42 St - Bryant Pk") 
    else if ($1 == " broadway 31 st")
	change_g(a, b, c, d, $5, "None") #I cannot find this station for the life of me. ? 
    else if ($1 == " orchard beach") #This is not the common name.
	change_g(a, b, c, d, $5, "Pelham Bay Park") 
    else if ($1 == " forest parkway")
	change_g(a, b, c, d, $5, "85 St - Forest Pkwy") 
    else if ($1 == " 242 st")
	change_g(a, b, c, d, $5, "Van Cortlandt Park - 242 St") 
    else if ($1 == " westchester sq")
	change_g(a, b, c, d, $5, "Westchester Sq - E Tremont Av") 
    else if ($1 == " lackawanna")
	change_g(a, b, c, d, $5, "None") #No PATH  #In Hoboken?
    else if ($1 == " 110 st cathedrl")
	change_g(a, b, c, d, $5, "Cathedral Pkwy (110 St)") 
    else if ($1 == " station")
	change_g(a, b, c, d, $5, "None") #No PATH #List name?
    else if ($1 == " bushwick av")
	change_g(a, b, c, d, $5, "Bushwick Av - Aberdeen St") 
    else if ($1 == " path wtc")
	change_g(a, b, c, d, $5, "None") #No PATH 
    else if ($1 == " elderts lane")
	change_g(a, b, c, d, $5, "75 St") 
    else if ($1 == " eastern pkwy")
	change_g(a, b, c, d, $5, "Eastern Pkwy - Brooklyn Museum") 
    else if ($1 == " flatbush av")
	change_g(a, b, c, d, $5, "Flatbush Av - Brooklyn College") 
    else if ($1 == " court sq 23 st")
	change_g(a, b, c, d, $5, "Court Sq") 
    else if ($1 == " roosevelt av")
	change_g(a, b, c, d, $5, "74 St - Broadway") #The other 46th st may be wrong.
    else if ($1 == " morrison av")
	change_g(a, b, c, d, $5, "Morrison Av- Sound View") 
    else if ($1 == " thirty st"){
	change_g(a, b, c, d, $5, "None") #No PATH
    }
    else if ($1 == " broadway lafay")
	change_g(a, b, c, d, $5, "Broadway-Lafayette St") 
    else if ($1 == " lexington av")
	change_g(a, b, c, d, $5, "Lexington Av/59 St") 
    else if ($1 == " dyre av")
	change_g(a, b, c, d, $5, "Eastchester - Dyre Av") 
    else if ($1 == " main st")
	change_g(a, b, c, d, $5, "Flushing - Main St") 
    else if ($1 == " 42 st times sq")
	change_g(a, b, c, d, $5, "Times Sq - 42 St") 
    else if ($1 == " 42 st pa bus te")
	change_g(a, b, c, d, $5, "42 St - Port Authority Bus Terminal") 
    else if ($1 == " rockaway pky")
	change_g(a, b, c, d, $5, "Canarsie - Rockaway Pkwy") 
    else if ($1 == " broadway eny")
	change_g(a, b, c, d, $5, "Broadway Jct") 
    else if ($1 == " 42 st grd cntrl")
	change_g(a, b, c, d, $5, "Grand Central - 42 St")     
    else
	print a "," b "," c "," d "," $5 > file3
}


shut(file1)
shut(file2)
shut(file3)
}


