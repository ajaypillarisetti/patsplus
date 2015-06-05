# PATS+ Shiny Visualizer

This is a simple visualization tool for PATS+ files built using R and Shiny. On first run, it will install required packages that are missing. It does require the shiny library.

```R
list.of.packages <- c("shiny")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages))(print(paste("The following packages are not installed: ", new.packages, sep="")))else(print("All packages installed"))
if(length(new.packages)) install.packages(new.packages)
lapply(list.of.packages,function(x){library(x,character.only=TRUE)}) 

# Easiest way is to use runGitHub
runGitHub("patsplus_visualizer", "ajaypillarisetti")

# Run a tar or zip file directly
runUrl("https://github.com/ajaypillarisetti/patsplus_visualizer/archive/master.tar.gz")
runUrl("https://github.com/ajaypillarisetti/patsplus_visualizer/archive/master.zip")
```

Or you can clone the git repository, then use `runApp()`:

```R
# First clone the repository with git. If you have cloned it into
# ~/patsplus, first go to that directory, then use runApp().
setwd("~/patsplus")
runApp()
```