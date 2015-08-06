#1:Take turnstile data:
#turnstile_141018.txt
#turnstile_150711.txt
cd ./MergingData
rm ./turnstile_150711.txt
cp ../turnstile_data/turnstile_150711.txt ./turnstile_150711.txt
cat ../turnstile_data/turnstile_141018.txt >> turnstile_150711.txt

awk -f pp_turnstile.awk > ./ts1.txt

cat ts1.txt | sort | uniq > ts2.txt

#5: GTFS Data:
#stops.txt
awk -f pp_namesformerge.awk > stops1.txt
cat stops1.txt | cut -d, -f2 | sort | uniq > stops2.txt
#8: (rm stops1.txt, rm stops2.txt)

python a_names_script_v2.py #(It goes to matchtable.txt)
awk -f takethetop.awk #(goes to unmatchedwords.txt and easymatches.txt)
awk -f smalledits.awk #(goes to readyformerge.txt)

cd ../
#12: Eiman's file:
#../GoogleLineNames.csv

#13: python gtfsorderlinenames.py (It goes to s_gtfs_names.csv)
#14: mkdir new_ts
#15: python orderlinenames.py (Lots of files go to new_ts; problem with 20141206)
#16: cd ../
#17: trainnames.R
