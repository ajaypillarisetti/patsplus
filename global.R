### Ajay Pillarisetti, University of California, Berkeley, 2015
### V1.0N

#install missing packages.
list.of.packages <- c("shiny","ggplot2","reshape2","plyr","lubridate","data.table","dygraphs","xts")
	new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages))(print(paste("The following packages are not installed: ", new.packages, sep="")))else(print("All packages installed"))
if(length(new.packages)) install.packages(new.packages)
lapply(list.of.packages,function(x){library(x,character.only=TRUE)}) 

#global functions
alt.diff <- function (x, n = 1, na.pad = TRUE) {
  NAs <- NULL
  if (na.pad) {NAs <- rep(NA, n)}
  diffs <- c(NAs, diff(x, n))
}

read.patsplus<- function(x, tzone="America/Los_Angeles"){
	#confirm file contains data
	fileCheck <- file.info(x)$size>0
	if(fileCheck){
		#read in without regard for delimiters
		raw <- read.delim(x)
		#use a regular expression to identify lines that are data, denote the line number
		kLines <- as.numeric(sapply(raw, function(x) grep('[0-9/0-9/0-9]{2,} [0-9:]{6,},[0-9.,]{3,}',x)))
		#convert to character
		rare <- as.character(raw[kLines,])
		#create a tempfile and write to it
		fn <- tempfile()
		write(rare, file=fn)
		#read in using fread
		mediumwell <- fread(fn)
		#remove cruft
		unlink(fn)
		if(ncol(mediumwell)==12){
			setnames(mediumwell, c('datetime','V_power','degC_sys','degC_air','RH_air','degC_thermistor','usb_pwr','fanSetting','filterSetting','ref_sigDel','low20','high320'))}else{
			setnames(mediumwell, c('datetime','V_power','degC_sys','degC_air','RH_air','degC_CO','mV_CO','status','ref_sigDel','low20','high320'))				
		}
		mediumwell[,datetime:=ymd_hms(datetime, tz=tzone)]
		#filename string extraction madness
		mediumwell[,file:=x]
	}else{warning(paste("File", x, "does not contain valid data", sep=" "))}
}


Mode <- function(x) {
  ux <- unique(x)
  ux[which.max(tabulate(match(x, ux)))]
}
