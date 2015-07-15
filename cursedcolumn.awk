function shut(list){
    if(close(list)){
	print list "failed to close" > "/dev/stderr";
    }
}
BEGIN{

#file = "./data/origstops.txt"
file = ARGV[1];
FS = ","

while((getline < file) > 0)
    print $1 ", "  "\"" $3 "\""
#Grabs stop_ids and names
shut(file)

}
