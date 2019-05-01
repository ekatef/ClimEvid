rm(list = ls())

library(tidyverse)

url_const_char <- "https://dane.imgw.pl/data/dane_pomiarowo_obserwacyjne/dane_meteorologiczne/terminowe/klimat/"
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#		extract data
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#	url to read aggregated by 5-year ranges
#****************************************
range_step <- 5
first_year_of_range <- seq(from = 1951, to = 1996, by = range_step)
last_year_of_range <- first_year_of_range + (range_step - 1)
na_months_in_current_year <- 10

# default vectorization is applied
range_char <- paste(first_year_of_range, last_year_of_range, sep = "_")
seq_in_range_list <- lapply(function(i) {
	seq(from = first_year_of_range[i], to = last_year_of_range[i], by = 1)
	}, X = seq(along.with = first_year_of_range))
time_ranges_key_list <- lapply(function(i){
		paste(range_char[i], seq_in_range_list[[i]], sep = "/")
	}, X = seq(along.with = first_year_of_range)
)
# e.g. "k_t_1951.csv"
fl_ranges_names_list <- lapply(function(i){	
		paste0("k_t_", seq_in_range_list[[i]], ".csv")
	}, X = seq(along.with = first_year_of_range)
)

#****************************************
#	url to read aggregated annually
#****************************************
single_year <- 2001:2019
month_seq_char <- c(paste0("0", 1:9), 11:12)

time_single_year_key_list <- lapply(function(i){
		paste0(single_year[i], "/", single_year[i], "_", month_seq_char)
	}, X = seq(along.with = single_year)
)
# e.g. "k_t_12_2018.csv"
fl_single_year_names_list <- lapply(function(i){
		paste0("k_t_", month_seq_char, "_", single_year[i], ".csv")
	}, X = seq(along.with = single_year)
)

time_key <- c(unlist(time_ranges_key_list), unlist(time_single_year_key_list))
time_key <- time_key[-((length(time_key) - na_months_in_current_year + 2):length(time_key))]
url_names <- paste0(url_const_char, time_key, "_k.zip" )
fl_names <- c(unlist( fl_ranges_names_list), unlist(fl_single_year_names_list))

#****************************************
#	read it
#****************************************
meteo_data_list <- vector(mode = "list", length = length(url_names))
for (i in seq(along.with = url_names)){
	print(time_key[i])
	# following https://stackoverflow.com/a/3053883/8465924
	temp <- tempfile()
	download.file(url_names[i], temp)
	meteo_data_list[[i]] <- read.table(unz(temp, fl_names[i]), sep = ",",
		stringsAsFactors = FALSE)
	unlink(temp)
	# trying to be polite
	Sys.sleep(1 + abs(rnorm(1, mean = 1, sd = 2)))
}

# according to
# https://dane.imgw.pl/data/dane_pomiarowo_obserwacyjne/dane_meteorologiczne/terminowe/klimat/k_t_format.txt
# NB Status "8" brak pomiaru = Statuses "8" means no observation available
res_df <- bind_rows(meteo_data_list)
colnames(res_df) <- c("st_id", "st_name", "year", "month", "day", "hour",
	"tas", "tas_status", "twet", "twet_status", "ice_ind", "ventil_ind",
	"hum_rel", "hum_status", "wind_drct", "wind_drct_status", 
	"wind_vel", "wind_vel_status", "cloudns", "cloudns_status",
	"visability", "visability_status")

if (!dir.exists("./data")) dir.create("./data")
write_delim(res_df, file.path("./data", "PL_meteo_klim.csv"), delim = ";")
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~