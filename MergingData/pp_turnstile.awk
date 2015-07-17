function shut(list){
    if(close(list)){
	print list "failed to close" > "/dev/stderr";
    }
}
BEGIN{

file = "turnstile_150711.txt"
#file = ARGV[1];
FS = ","

while((getline < file) > 0)
    print $4

shut(file)

}
