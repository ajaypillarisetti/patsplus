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

Mode <- function(x) {
  ux <- unique(x)
  ux[which.max(tabulate(match(x, ux)))]
}
