function shut(list){
    if(close(list)){
	print list "failed to close" > "/dev/stderr";
    }
}
BEGIN{

file = "../../data/transfers.txt"

FS = ","

while((getline < file) > 0)
    if($1 != $2)
	print $1 "," $2 "," $4
shut(file)

}
