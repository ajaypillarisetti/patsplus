### Ajay Pillarisetti, University of California, Berkeley, 2015
### V1.0N

library(shiny)
library(ggplot2)
library(reshape2)
library(plyr)
library(lubridate)
library(data.table)
library(dygraphs)
library(xts)

options(shiny.maxRequestSize=30*1024^2)

shinyServer(function(input, output) {

	#read in data
	datasetInput <- reactive({

		Sys.setenv(TZ=input$timezone)
		print(Sys.getenv("TZ"))

	    inFile <- input$file1
    	if (is.null(inFile)){
      		return(NULL)
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
			mediumwell[,datetime:=ymd_hms(datetime, tz=input$timezone)]
			#filename string extraction madness
			mediumwell[,file:=x]

			#mass conversion algorithm
			mediumwell[datetime>mediumwell[,min(datetime)+(input$zero_dur*0.25)] & datetime<mediumwell[,min(datetime)+input$zero_dur], initialzero:=1]
			mediumwell[initialzero==1]
			mediumwell[datetime<mediumwell[,max(datetime)-180] & datetime>mediumwell[,max(datetime)-880], finalzero:=1]
			mediumwell[finalzero==1]

			averageInitialZeroAirTemp <- mediumwell[initialzero==1, mean(degC_air)]

			mediumwell[,lowTempLinearAdjusted:= low20 - input$tc_low * (degC_air - averageInitialZeroAirTemp)]
			mediumwell[,highTempLinearAdjusted:= high320 - input$tc_high * (degC_air - averageInitialZeroAirTemp)]

			medianLowTempAdjustedZero1 <- mediumwell[initialzero==1, median(lowTempLinearAdjusted)]
			medianHighTempAdjustedZero1 <- mediumwell[initialzero==1, median(highTempLinearAdjusted)]

			medianLowTempAdjustedZero2 <- mediumwell[finalzero==1, median(lowTempLinearAdjusted)]
			medianHighTempAdjustedZero2 <- mediumwell[finalzero==1, median(highTempLinearAdjusted)]

			incrementalSlopeLow <- (medianLowTempAdjustedZero2-medianLowTempAdjustedZero1)/mediumwell[status!=10, length(status)]
			incrementalSlopeHigh <- (medianHighTempAdjustedZero2-medianHighTempAdjustedZero1)/mediumwell[status!=10, length(status)]

			mediumwell[status!=10, slopeindex:=1:nrow(mediumwell[status!=10])]

			mediumwell[,highPEInitialZeroLinearAdjust:=incrementalSlopeHigh*slopeindex+medianHighTempAdjustedZero1]
			mediumwell[,lowPEInitialZeroLinearAdjust:=incrementalSlopeLow*slopeindex+medianLowTempAdjustedZero1]

			mediumwell[,highPERefLinearAdj:=highTempLinearAdjusted -  highPEInitialZeroLinearAdjust]
			mediumwell[,lowPERefLinearAdj:=lowTempLinearAdjusted -  lowPEInitialZeroLinearAdjust]

			mediumwell[,lowPM:=lowPERefLinearAdj*input$pc_low]
			mediumwell[,highPM:=highPERefLinearAdj*input$pc_high]

			mediumwell[highTempLinearAdjusted<3000,pm_mass:=highPM]
			mediumwell[highTempLinearAdjusted>=3000,pm_mass:=lowPM]
			mediumwell[pm_mass<10, pm_mass:=10]

			mediumwell[,c('datetime','V_power','degC_sys','degC_air','RH_air','degC_CO','mV_CO','status','ref_sigDel','low20','high320','pm_mass'), with=F]


		}else{warning(paste("File", x, "does not contain valid data", sep=" "))}
	}

		dta<-read.patsplus(inFile$datapath)
	})

	filename <- reactive({
		inFile <- input$file1
		filename <- inFile$name
		filename
		print(filename)
	})

	data_cleaned <- reactive({
		if (is.null(datasetInput())) return(NULL)
		data_d <- datasetInput()[,with=F]
	})

	#TABLE OUTPUTS
	output$allDataTable<-renderDataTable({
		datasetInput()[,file:=NULL]}, 
		options = list(paging=FALSE, searching=FALSE))


	#DOWNLOAD OUTPUTS
	output$downloadFull <- downloadHandler(
    	filename = function() {paste(substring(filename(), 1, nchar(filename())-4), '.cleaned.csv', sep="")
    	},
	    content = function(file) {
    		write.csv(datasetInput()[,with=F], file, row.names=F)
    	}
	)

	#PLOT OUTPUTS
	output$fullplot<-renderPlot({
		a<-qplot(datetime, value, data=melt(data_cleaned(), id.var='datetime', measure.var=c('pm_mass','degC_air',"RH_air",'low20', 'high320')), geom='line', color=variable) +theme_bw(12) + ylab('Value') + xlab('Datetime') + facet_wrap(~variable, ncol=1, scales='free') + theme(legend.position='bottom')
		print(a)
	})

	#DYGRAPHS
	output$temp <- renderDygraph({
		dygraph(as.xts(datasetInput()[,c('datetime', 'degC_air'), with=F]), group='lab')%>% 
	    dyOptions(axisLineWidth = 1.5, fillGraph = F, drawGrid = FALSE, useDataTimezone=TRUE) %>%
	    dyAxis("y", label = "Temp C") %>%
	    dyAxis("x", label = "datetime")%>%
		dyRangeSelector() 
	})
	output$low20 <- renderDygraph({
		dygraph(as.xts(datasetInput()[,c('datetime','low20'), with=F]), group='lab')%>% 
	    dyOptions(axisLineWidth = 1.5, fillGraph = F, drawGrid = FALSE, useDataTimezone=TRUE) %>%
	    dyAxis("y", label = "mv (low20)") %>%
	    dyAxis("x", label = "")
	})
	output$high320 <- renderDygraph({
		dygraph(as.xts(datasetInput()[,c('datetime','high320'), with=F]), group='lab')%>% 
	    dyOptions(axisLineWidth = 1.5, fillGraph = F, drawGrid = FALSE, useDataTimezone=TRUE) %>%
	    dyAxis("y", label = "mv (high320)") %>%
	    dyAxis("x", label = "")	
	})
	output$mass <- renderDygraph({
		dygraph(as.xts(datasetInput()[,c('datetime','pm_mass'), with=F]), group='lab')%>% 
	    dyOptions(axisLineWidth = 1.5, fillGraph = F, drawGrid = FALSE, useDataTimezone=TRUE) %>%
	    dyAxis("y", label = "mass") %>%
	    dyAxis("x", label = "")	
	})
})