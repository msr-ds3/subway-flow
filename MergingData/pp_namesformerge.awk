# CURRENT
# Riva Tropp
# 7/27/2015
# Takes stop_ids and names and gets rid of directions (producing 'reduced' or 'modified' stops).

function shut(list){
    if(close(list)){
	print list "failed to close" > "/dev/stderr";
    }
}
BEGIN{

file = "../gtfs_data/stops.txt"
FS = ","

while((getline < file) > 0){
    print $1 ", "  "\"" $3 "\""
}
shut(file)

}
