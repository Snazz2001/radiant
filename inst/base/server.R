shinyServer(function(input, output, session) {

#   setInitValues()   # using a function here so it can also be called from state.R to reset the app

	# source shared functions
	source('radiant.R', local = TRUE)

	# source data & analysis tools
  for(file in list.files(c("tools/app","tools/data"), pattern="\\.(r|R)$", full.names = TRUE))
    source(file, local = TRUE)

	if(Sys.getenv("RSTUDIO") != "1" & running_local) saveStateOnCrash(session)
})
