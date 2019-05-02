# @res_df is the data frame of the meteorological observations
# like one read by "1_imgw_data_prepar.R" 

st_id_sltd <- 250190390

#*******************************************************
#	check station info
#	(its name, in particular)
#*******************************************************
id_set <- c(250190390, 252170210, 252200150, 251210120, 251200030, 252220030, 
254200080, 252210050, 252160230, 252200120)

st_name <- res_df %>%
	filter(st_id %in% id_set) %>%
	select(st_name)
print(unique(st_name))	

#*******************************************************
#		raw data/annual plot		
#*******************************************************
res_to_plot <- res_df %>%
	filter(st_id %in% st_id_sltd) %>%
	group_by(year, month) %>%
	summarize(tas_month = mean(tas))
	# mutate(date = paste(year, month, day, sep = "-") )
	# select(tas)
print(head(res_to_plot))	

if (!dir.exists("./res")) {dir.create("./res")}
png(file.path("./res", "test_monthly_plot.png"))
plot(ts(res_to_plot$tas_month),  
# plot(x = res_to_plot$year, y = (res_to_plot$tas_ann), 
	type = "l", col = "red", lwd = 2)
# plot(ts(res_to_plot$tas), type = "l", col = "red", lwd = 2)
dev.off()

#*******************************************************
#	seasonal plots
#*******************************************************
months_set <- data.frame(spring = 3:5, summer = 6:8, autumn = 9:11)

ssn_name <- "summer"
res_ssn_to_plot <- res_df %>%
	filter(st_id %in% st_id_sltd) %>%
	filter(month %in% unlist(months_set[ssn_name])) %>%
	group_by(year, month) %>%
	summarize(tas_month = mean(tas))
	# mutate(date = paste(year, month, day, sep = "-") )
	# select(tas)
print(head(res_ssn_to_plot))	

if (!dir.exists("./res")) {dir.create("./res")}
png(
	file.path("./res", paste("test", ssn_name, "plot.png", sep = "_"))
)
plot(ts(res_ssn_to_plot$tas_month),  
# plot(x = res_to_plot$year, y = (res_to_plot$tas_ann), 
	type = "l", col = "red", lwd = 2)
# plot(ts(res_to_plot$tas), type = "l", col = "red", lwd = 2)
dev.off()
#*******************************************************




