################################################################################
# functions to set initial values and take information from state_list
# when available
################################################################################

state_singlevar <- function(inputvar, vars) vars[vars == state_list[[inputvar]]]
state_multvar <- function(inputvar, vars) vars[vars %in% state_list[[inputvar]]]

state_init <- function(inputvar, init = "") {
  ifelse(is.null(state_list[[inputvar]]), return(init), return(state_list[[inputvar]]))
}

state_init_list <- function(inputvar, init = "", vals) {
  ifelse(is.null(state_list[[inputvar]]), return(init), return(state_singlevar(inputvar, vals)))
}

state_init_multvar <- function(inputvar, pre_inputvar, vals) {
  # for factor and cluster use variable selection from the pre-analysis
  ifelse(is.null(state_list[[inputvar]]), return(vals[vals %in% pre_inputvar]),
    return(state_multvar(inputvar, vals)))
}

################################################################################
# function to save app state on refresh or crash
################################################################################
saveState <- function(filename) {
  isolate({
    RadiantInputs <- state_list
    LiveInputs <- reactiveValuesToList(input)
    RadiantInputs[names(LiveInputs)] <- LiveInputs
    RadiantValues <- reactiveValuesToList(values)
    save(RadiantInputs, RadiantValues , file = filename)
  })
}

saveStateOnCrash <- function(session = session)
  session$onSessionEnded(function() {
    observe({
      pth <- "~/radiant_temp/state"
      cdir <- ""
      if(!file.exists(pth))
        cdir <- try(dir.create(pth), silent = TRUE)
      if(!is(cdir, 'try-error')) try(saveState(paste0(pth,"/RadiantState-",Sys.Date(),".rsf")), silent = TRUE)
   })
})


################################################################
# functions used across tools in radiant
################################################################
changedata <- function(addCol, addColName = "") {
	if(nrow(getdata()) == nrow(addCol) && addColName[1] != "") {
  	return(values[[input$datasets]][,addColName] <- addCol)
	}
}

changedata_names <- function(oldnames, newnames) {
	upnames <- colnames(values[[input$datasets]])
	upnames[which(upnames %in% oldnames)] <- newnames
	return(colnames(values[[input$datasets]]) <- upnames)
}

inChecker <- function(tocheck) {
	ifelse(sum(tocheck %in% varnames()) < length(tocheck), return(NULL), return('OK'))
}

getdata <- reactive({
	values[[input$datasets]]
})

getdata_class <- reactive({
	# don't use isolate here or values won't change when the dataset is changed
	cls <- sapply(getdata(), function(x) class(x)[1])
	gsub("ordered","factor", cls)
})

varnames <- reactive({
	dat <- getdata_class()
	vars <- names(dat)
	names(vars) <- paste(vars, " {", dat, "}", sep = "")
	vars
})

date2character <- reactive({
	date2character_dat(getdata())
})

date2character_dat <- function(dat) {
	# xtable doesn't like dates
  isDate <- c(sapply(dat, is.Date))
	dat[,isDate] <- sapply(dat[,isDate], as.character)
	dat
}

################################################################
# functions used to create Shiny in and outputs
################################################################
plotWidth <- function() {
	ifelse(is.null(input$viz_plot_width), return(values$plotWidth),
		return(input$viz_plot_width))
}

plotHeight <- function() {
	ifelse(is.null(input$viz_plot_height), return(values$plotHeight),
		return(input$viz_plot_height))
}

statPanel <- function(fun_name, rfun_label, fun_label, widthFun, heightFun) {

	if(isolate(input$nav_radiant) != fun_name) return()

	sum_name <- paste0("summary_", fun_label)
	plot_name <- paste0("plots_", fun_label)

	# Generate output for the summary tab
	output[[sum_name]] <- renderPrint({

		result <- get(rfun_label)()
		# when no analysis was conducted (e.g., no variables selected)
		if(is.character(result)) return(cat(result,"\n"))

		get(sum_name)()
	})

	# Generate output for the plots tab
	output[[plot_name]] <- renderPlot({

		result <- get(rfun_label)()
		# when no analysis was conducted (e.g., no variables selected)
		if(is.character(result)) return(plot(x = 1, type = 'n', main=result, axes = FALSE, xlab = "", ylab = ""))

		get(plot_name)()
	}, width=get(widthFun), height=get(heightFun))

  return(tabsetPanel(
    id = paste0("tabs_",fun_label),
    tabPanel("Summary", verbatimTextOutput(sum_name)),
    tabPanel("Plots", plotOutput(plot_name, height = "100%"))
  ))
}

statTabPanel <- function(menu_name, fun_name, rfun_label, fun_label, widthFun = "plotWidth", heightFun = "plotHeight") {
	  sidebarLayout(
	    sidebarPanel(
	      wellPanel(
	        HTML(paste("<label><strong>Menu:",menu_name,"</strong></label>")),
	        HTML(paste("<label><strong>Tool:",isolate(input$nav_radiant),"</strong></label>")),
	        HTML(paste("<label><strong>Data:",input$datasets,"</strong></label>"))
	      ),
	      uiOutput(paste0("ui_",fun_label))
	    ),
	    mainPanel(
				statPanel(fun_name, rfun_label, fun_label, widthFun, heightFun)
	    )
	  )
}