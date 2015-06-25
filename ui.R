
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#
library(shiny)

shinyUI(fluidPage(
  
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
