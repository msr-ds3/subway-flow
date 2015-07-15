function shut(list){
    if(close(list)){
	print list "failed to close" > "/dev/stderr";
    }
}
BEGIN{

file = "./data/origstops.txt"
#file = ARGV[1];
FS = ","

while((getline < file) > 0)
    print $1 ", "  "\"" $3 "\""
#$3 is a dup of 1, $2 is the same each time, everything after 4 is the long name
shut(file)

}
