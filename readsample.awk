function shut(list){
    if(close(list)){
	print list "failed to close" > "/dev/stderr";
    }
}
BEGIN{
file1 = "./tssample.txt"

RS = "</a>"
FS = "/"
while((getline < file1) > 0){
    split($5, v, /"/)
    print v[1]
}

shut(file1)
}
