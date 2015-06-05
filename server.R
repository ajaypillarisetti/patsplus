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



shinyServer(function(input, output) {

	#read in data
	datasetInput <- reactive({
	    inFile <- input$file1
    	if (is.null(inFile)){
      		return(NULL)
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
		a<-qplot(datetime, value, data=melt(data_cleaned(), id.var='datetime', measure.var=c('degC_air',"RH_air",'low20', 'high320')), geom='line', color=variable) +theme_bw(12) + ylab('Value') + xlab('Datetime') + facet_wrap(~variable, ncol=1, scales='free') + theme(legend.position='bottom')
		print(a)
	})

	#DYGRAPHS
	output$temp <- renderDygraph({
		dygraph(as.xts(datasetInput()[,c('degC_air'), with=F], order.by=datasetInput()$datetime), group='lab')%>% 
	    dyOptions(axisLineWidth = 1.5, fillGraph = F, drawGrid = FALSE, useDataTimezone=TRUE) %>%
	    dyAxis("y", label = "Temp C") %>%
	    dyAxis("x", label = "datetime")%>%
		dyRangeSelector() 
	})
	output$low20 <- renderDygraph({
		dygraph(as.xts(datasetInput()[,c('low20'), with=F], order.by=datasetInput()$datetime), group='lab')%>% 
	    dyOptions(axisLineWidth = 1.5, fillGraph = F, drawGrid = FALSE, useDataTimezone=TRUE) %>%
	    dyAxis("y", label = "mv (low20)") %>%
	    dyAxis("x", label = "")
	})
	output$high320 <- renderDygraph({
		dygraph(as.xts(datasetInput()[,c('high320'), with=F], order.by=datasetInput()$datetime), group='lab')%>% 
	    dyOptions(axisLineWidth = 1.5, fillGraph = F, drawGrid = FALSE, useDataTimezone=TRUE) %>%
	    dyAxis("y", label = "mv (high320)") %>%
	    dyAxis("x", label = "")	
	})

})