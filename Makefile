all: Flow.py f_*.csv
	python Flow.py

f_noon.csv: balance_entries_exits.R entries_exits_average.csv SingularTrainFlow.csv 
	Rscript balance_entries_exits.R

entries_exits_average.csv: Load_Subway_Trips.R trainnames.R readyformerge.txt GoogleLineNames.csv new_ts/turnstile_*.txt 
	Rscript Load_Subway_Trips.R

readyformerge.txt: join.sh ./turnstile_data/turnstile_*.txt ./gtfs_data/stops.txt
	./join.sh

join.sh: pp_namesformerge.awk takethetop.awk smalledits.awk a_names_script_v2.py
	chmod 777 join.sh
	./join.sh
 
GoogleLineNames.csv: GoogleLineNames.R ./gtfs_data/stop_times.txt ./gtfs_data/modifiedstops.txt new_google_data.txt
	Rscript GoogleLineNames.R

gtfs_data/modifiedstops.txt: pp_namesformerge.awk
	awk -f pp_namesformerge.awk > gtfs_data/modifiedstops.txt

new_google_data.txt: g_orderlinenames.py
	python g_orderlinenames.py


new_ts/turnstile_*.txt: c_order.py ./turnstile_data/turnstile_*.txt
	python c_order.py

SingularTrainFlow.csv: SingularTrainTravel.R ./gtfs_data/modifiedstops.txt new_google_data.txt ./gtfs_data/stop_times.txt
	Rscript SingularTrainTravel.R
