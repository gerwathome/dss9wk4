#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(datasets)
library(tidyverse)
library(GGally)
library(broom)

# Define server logic
shinyServer(function(input, output, session) {
  dsdf <- reactive({
    dsn <- input$dataSetName
    as.data.frame(eval(parse(text=dsn)))
      }) # end reactive
  
  vars <- reactive({
    ds <- dsdf()
    names(ds)
  }) # end reactive
  
  posDepVars <- reactive({
    ds <- dsdf()
    nums <- sapply(ds, is.numeric)
    names(ds[,nums])
  }) # end reactive
  
  remVars <- reactive({
    iv <- vars()
    iv[iv != input$depVar]
  }) # end reactive
  
  observe({
    x <- posDepVars()
    # Can also set the label and select items
    updateRadioButtons(session, "depVar",
                       label = "Select the response variable:",
                       choices = x,
                       selected = x[1]
    )
  }) # end observe
  
  observe({
    x <- remVars()
    updateCheckboxGroupInput(session, "indVars",
                             label = "Select the explanatory variables:",
                             choices = x,
                             selected = x[1]
    )
  }) # end observe
  output$pairsPlot <- renderPlot({
    ds <- dsdf()
#    values$vars <- names(ds)
#    values$depVars <- names(ds)
    binName <-""
    # find out if there are any factors
    facts <- sapply(ds, is.factor)
    # pick the first factor to color divide the data into bins
    binCol <- match(TRUE,facts)
    if(!is.na(binCol)){
      binName <- names(ds)[binCol]
    }else{
      # if there are no factors, create one from the numeric values which
      # correlate best with the remaining values
      nums <- sapply(ds, is.numeric)
      dsnums <- ds[,nums]
      bbCol <- (max(colMeans(abs(cor(dsnums, use = "complete.obs"))))
                == colMeans(abs(cor(dsnums, use = "complete.obs"))))
      binName <- paste(names(dsnums)[bbCol], "bins", sep="_")
      ds <- mutate(ds, asdf = cut(dsnums[,bbCol],3))
      names(ds) <- gsub("asdf", binName, names(ds))
    }
    # create a pairs plot
    plotString = paste0("plt <- ggpairs(ds, aes(colour = ",
                        binName,
                        ", alpha = 0.4))")
    eval(parse(text=plotString))
    plt <- plt + theme_bw()
    plt
  }, height = function() {
    session$clientData$output_pairsPlot_width
  }) # end render pairsPlot
  
  mdl <- reactive({
    op <- ifelse(input$interactions,"*","+")
    frmla <- as.formula(
      paste(
        input$depVar,  "~",  paste(input$indVars, collapse = op)
        ) # end paste
    ) # end as.formula
    lm(frmla,data=dsdf())
  }) # end reactive
  
  
  output$modelPlot <- renderPlot({
    plt <- ggnostic(
      mdl(),
      columnsY = c(".fitted", ".sigma", ".se.fit", ".cooksd")
#      columnsY = c(".fitted", ".resid", ".se.fit")
    )
    plt <- plt + theme_bw()
    plt
  }, height = function() {
    session$clientData$output_modelPlot_width
  }) # end render modelPlot
  
  
  output$residPairsPlot <- renderPlot({
    dt <- broomify(mdl())
    pm <- ggpairs(
      dt, c(".fitted", ".resid"),
      columnLabels = c("fitted", "residuals"),
      lower = list(continuous = ggally_nostic_resid)
    )
    pm
  }) # end render residPairsPlot
  
  output$fitPlot <- renderPlot({
    dt <- augment(mdl())
    pm <- ggplot(data=dt, aes(x = dt[,names(dt)==input$depVar],
                              y = .fitted))
    pm <- pm + geom_point()
    pm <- pm + scale_colour_discrete("Fit Lines")
    pm <- pm + geom_line(aes(x = dt[,names(dt)==input$depVar],
                             y = dt[,names(dt)==input$depVar],
                             colour = "Perfect Fit"),
                         size=1)
    pm <- pm + stat_smooth(method="lm",
                           aes(colour = "Regression Fit"),
                           size=1)
    pm <- pm + labs(
      title = "Data, Regression Fit and Perfect Fit",
      x = input$depVar,
      y = paste("Best fit to",input$depVar)
    )
    pm <- pm + theme_bw()
    pm
  }) # end render fitPlot
  
  output$residPlot <- renderPlot({
    dt <- augment(mdl())
    pm <- ggplot(data=dt, aes(x = dt[,names(dt)==input$depVar],
                              y = .std.resid))
    pm <- pm + geom_point()
    pm <- pm + scale_colour_discrete("Fit Lines")
    pm <- pm + geom_line(aes(x = dt[,names(dt)==input$depVar],
                             y = rep(0,length(dt[,1])),
                             colour = "Zero error"),
                         size=1)
    pm <- pm + geom_line(aes(x = dt[,names(dt)==input$depVar],
                             y = rep(2,length(dt[,1])),
                             colour = "Expected Limit"),
                         size=1)
    pm <- pm + geom_line(aes(x = dt[,names(dt)==input$depVar],
                             y = rep(-2,length(dt[,1])),
                             colour = "Expected Limit"),
                         size=1)
    pm <- pm + stat_smooth(method="lm",
                           aes(colour = "Fit to residuals"),
                           size=1)
    pm <- pm + labs(
      title = "Standardized Residuals",
      x = input$depVar,
      y = paste("Standardized Residuals to best fit of",input$depVar)
    )
    pm <- pm + theme_bw()
    pm
  }) # end render residPlot
  
  
  
  output$modelSummary <- renderTable({
   glance(mdl())},
    digits = 5
    )
  
  output$modelParams <- renderTable({
    tidy(mdl())},
    digits = 5
  )
  
}) # end shinyServer
