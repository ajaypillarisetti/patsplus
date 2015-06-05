### Ajay Pillarisetti, University of California, Berkeley, 2015
### V1.0N

row <- function(...) {
  tags$div(class="row", ...)
}

col <- function(width, ...) {
  tags$div(class=paste0("span", width), ...)
}

actionLink <- function(inputId, ...) {
  tags$a(href='javascript:void',
         id=inputId,
         class='action-button',
         ...)
}

shinyUI(bootstrapPage(
	tags$head(
		tags$link(rel='stylesheet', type='text/css', href='styles.css'),
		tags$script(type='text/javascript', src='scripties.js')
	),

	tags$div(
		class = "container",

		tags$p(tags$br()),
		row(
			col(12, 
				h2('disPATSchR'), 
		      	h4('PATS+ File Processor'),
			 #    selectInput("timezone", "Select Timezone", 
			 #    	list(
	   #                "Africa/Accra",
	   #                "Africa/Dakar",
	   #                "Africa/Nairobi",
	   #                "America/Chicago",
	   #                "America/Los_Angeles",
	   #                "America/New_York",
	   #                "Asia/Bangkok",
	   #                "Asia/Beirut",
	   #                "Asia/Calcutta",
	   #                "Asia/Katmandu"
				# )),
		      	br()
			)
		),

		tabsetPanel(
			tabPanel("File Selection",
				row(
					br(),
			      	fileInput('file1', 'Choose a PATS+ file', 
			      		accept=c('text/csv', 'text/comma-separated-values,text/plain', '.csv', '.txt', '.TXT'))
			    ),
				row(
					dataTableOutput('dateTable')
				)
			),

			tabPanel("Raw Signal Plot",
				row(plotOutput('fullplot'))
			),

			tabPanel("Interactive Plot",
				br(),
				row(dygraphOutput("low20", height='300px')),
				row(dygraphOutput("high320", height='300px')),
				row(dygraphOutput("temp", height='200px'))
			),
			
			tabPanel("Tables",
				row(
					col(12,
						p(id='tableTitle',strong("Data Table"), a("hide", id='hide_ce', onclick='false'), downloadLink("downloadFull", class='export')),
						dataTableOutput('allDataTable')
					)
				)
			)
		),

		row(
			col(12, 
				p(id="colophon",class='text-center',"Though this be madness, yet there is method in't.")
			)
		)
	)
))

