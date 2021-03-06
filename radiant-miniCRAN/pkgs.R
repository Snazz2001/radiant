# Specify list of packages needed
#   "Cairo","car", "gridExtra", "psych", "vegan", "lubridate", "RColorBrewer",
# 	"wordcloud", "AlgDesign", "reshape2", "plyr", "markdown", "rmarkdown", "knitr",
# pkgs_cran <- c("mime","BH","GPArotation","R.methodsS3", "R.oo", "R.utils",
# 	"wordcloud", "AlgDesign", "Cairo", "igraph", "brew", "reshape2", "plyr", "markdown", "knitr", "rmarkdown",

pkgs_cran <- c("car", "gridExtra", "GPArotation", "psych", "vegan",  "RColorBrewer",
	"wordcloud", "AlgDesign", "brew", "reshape2", "plyr", "markdown", "knitr", "rmarkdown",
  "testthat", "lubridate", "ggplot2", "shinyFiles", "shiny","magrittr", "tidyr", "dplyr", "ggvis")

pkgs_gh <- c("shinyAce", "rvest")

pkgs <- c(pkgs_cran,pkgs_gh)
# pkgs[order(pkgs)]

# remove reshape2 and plyr when possible
