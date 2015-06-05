# PATS+ Shiny Visualizer

This is a simple visualization tool for PATS+ files.

```R
library(shiny)
library(ggplot2)
library(reshape2)
library(plyr)
library(lubridate)
library(data.table)
library(dygraphs)
library(xts)

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