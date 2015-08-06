
all: Flow.py f_*.csv
	python Flow.py

f_noon.csv: ./PrePres/balance_entries_exits.R entries_exits_average.csv SingularTrainFlow.csv 
	Rscript ./PrePres/balance_entries_exits.R

entries_exits_average.csv: Load_Subway_Trips.R trainnames.R ./MergingData/readyformerge.txt GoogleLineNames.csv ./MergingData/new_ts/turnstile_*.txt 
	Rscript Load_Subway_Trips.R

./MergingData/readyformerge.txt: ./MergingData/join.sh ./turnstile_data/turnstile_*.txt ./gtfs_data/stops.txt
	bash ./MergingData/join.sh

#join.sh: 

GoogleLineNames.csv: GoogleLineNames.R ./gtfs_data/stop_times.txt ./gtfs_data/modifiedstops.txt new_google_data.txt
	Rscript GoogleLineNames.R

./gtfs_data/modifiedstops.txt: ./MergingData/pp_namesformerge.awk
	awk -f ./MergingData/pp_namesformerge.awk > ./gtfs_data/modifiedstops.txt

new_google_data.txt: ./MergingData/orderlinenames.py
	python ./MergingData/orderlinenames.py


./MergingData/new_ts/turnstile_*.txt: ./MergingData/c_order.py ./turnstile_data/turnstile_*.txt
	python ./MergingData/c_order.py

SingularTrainFlow.csv: SingularTrainTravel.R ./gtfs_data/modifiedstops.txt new_google_data.txt ./gtfs_data/stop_times.txt
	Rscript SingularTrainTravel.R


