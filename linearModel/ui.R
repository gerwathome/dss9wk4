#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
dataSets <- c("iris", "rock", "swiss", "airquality", "attitude",
              "CO2", "Loblolly", "LifeCycleSavings", "mtcars")

shinyUI(
  fluidPage(
    # Application title
    titlePanel("Fitting a Linear Model"),
    tabsetPanel(type = "tabs", 
                tabPanel("1. Data Selection",   
                         selectInput("dataSetName",
                                     label = h3("First, select the data set:"), 
                                     choices = dataSets, 
                                     selected = dataSets[1]),
                         helpText(strong("The pairs plot below compares all of the data set variables on a grid. The different colors are based on bins from one of the categorical variables.  If no categorical variables exist in the data set, one is created from the continuous variable which correlates best with the other variables.  The diagonal shows density plots for continuous variables and histograms for categorical variables.  The lower triangle shows scatter plots of each variable pair for continuous variables and histograms when comparing continuous with categorical variables.   The upper triangle gives the correlation coefficient for each continuous variable pair and box plots to compare categorical variables with continuous variables.")),
                         #        hr(),
                         helpText(strong("One should examine the realtionships among the variables shown below to help with model construction.  In the next tab, you will need to select a response variable and appropriate explanatory variables.  Note that factors are not appropriate response variables for linear regression."
                         )),     
                         plotOutput("pairsPlot")
                ), # end first tabPanel
                
                tabPanel("2. Variable Selection",
                         h3("Second, select the variables for the linear model:"),
                         # the radio button and check box choices are dummies,
                         # as they will be replaced by the update functions in
                         # server
                         radioButtons("depVar", "Select the response variable:",
                                      choices = c("Sepal.Length", "Sepal.Width",
                                                  "Petal.Length", "Petal.Width"),
                                      inline = TRUE,
                                      selected = "Sepal.Length"
                         ),
                         checkboxGroupInput("indVars",
                                            "Select the explanatory variables:",
                                            choices = c("Sepal.Width",
                                                        "Petal.Length",
                                                        "Petal.Width",
                                                        "Species"),
                                            inline = TRUE,
                                            selected = "Sepal.Width"
                         ),
                         h5(strong("Choose model type:")),
                         checkboxInput("interactions",
                                       "Should model interaction terms be included?",
                                       FALSE),
                         helpText(strong("The first plot below compares the fit for the selected terms to a perfect model fit.  It would be desirable for the regression fit line to be close to the perfect fit line.")),
                         helpText(strong("The second plot below looks at the standardized residuals for the regression fit.  For a decent fit, one would expect a horizontal fit line near zero with no odd trends in the data points, and no points more than two standard deviations from zero.  This would imply randomly distributed errors with no major outliers.  Change the selection of explanatory variables until you are happy (as possible) with the result.  The parameter estimates for the model are shown in the next tab.")),     
                         plotOutput("fitPlot"),
                         plotOutput("residPlot")
                ), # end second tabPanel
                
      tabPanel("3. Model Summary",
               helpText(strong("The first table below shows statistics assessing the overall quality of the model.  The second table gives the best fit estimates of the coefficients for each model parameter, along with an assessment of the quality of that estimate.")),
               h3("Model Summary Statistics"),
               tableOutput("modelSummary"),
               h3("Model Parameter Statistics"),
               tableOutput("modelParams")
      )# end third tabPanel
    ) # end tabsetPanel
  ) # end fluidPage
) # end shinyUI
