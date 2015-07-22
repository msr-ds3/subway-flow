function shut(list){
    if(close(list)){
	print list "failed to close" > "/dev/stderr";
    }
}
BEGIN{

file = "../gtfs_data/stops.txt"
FS = ","

while((getline < file) > 0)
    print substr($1, 1,3) ","  $3 "," $5 "," $6 > "stops_no_direction.txt"

shut(file)

}
