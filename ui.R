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
		      	br()
			)
		),

		tabsetPanel(
			tabPanel("File Selection",
				row(
					column(width=6,
						br(),
				      	fileInput('file1', 'Choose a PATS+ file', 
				      		accept=c('text/csv', 'text/comma-separated-values,text/plain', '.csv', '.txt', '.TXT'))
				    )
			    ),
				row(
					dataTableOutput('dateTable')
				),
				hr(),
				h4("Millivolt-to-Mass Algorithm Parameters"),
				row(
					column(width=3,
						numericInput("pc_low", label = "Photoelectric Coeff (Low)", value = 21.64),
						numericInput("tc_low", label = "Temp Coeff (Low)", value = 0.202)
					),
					column(width=3,
						numericInput("pc_high", label = "Photoelectric Coeff (High)", value = 1),
						numericInput("tc_high", label = "Temp Coeff (High)", value = 4.0)
					),
					column(width=3,
						numericInput("zero_dur", label = "Zero Duration (mins)", value = 600),
						selectizeInput("timezone", "Select Timezone", 
				    		list(
								"Africa/Accra",
								"Asia/Kathmandu",
								"Asia/Kolkata",
								"Asia/Vientiane"
							), selected="Asia/Vientiane",
						options = list(create = TRUE))
					)

				)
			),

			tabPanel("Raw Signal Plot",
				row(plotOutput('fullplot'))
			),

			tabPanel("Interactive Plot",
				br(),
				row(dygraphOutput("mass", height='300px')),
				row(dygraphOutput("low20", height='200px')),
				row(dygraphOutput("high320", height='200px')),
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

