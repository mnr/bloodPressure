
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#
library(shiny)
#oldestSampleDate <- as.Date("2011-06-16")
#youngestSampleDate <- as.Date("2015-06-16")

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Blood Pressure"),
  
   fluidRow(
     column(6,
            uiOutput("firstDateRangeSelector"),
            hr(),
            tableOutput("firstBpTable"),
            plotOutput("firstBoxplotSystolic")
     ),
     column(6,
            uiOutput("SecondDateRangeSelector"),
            hr(),
            tableOutput("secondBpTable"),
            plotOutput("secondBoxplotSystolic")
     )
   )
  
)
)
