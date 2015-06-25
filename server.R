
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
# http://shiny.rstudio.com


# create data --------------------------------------------------------

# Read from a Google SpreadSheet.
require(RCurl)
myCsv <- getURL("https://docs.google.com/spreadsheet/pub?key=0Amm-j5PR-PnndDJGX0t0alJaZF8wWUoxb3UwSV9hb1E&single=true&gid=1&output=csv")
bpressureData <- read.csv(textConnection(myCsv),stringsAsFactors=FALSE)

# convert column one (Timestamp) from factor to Date
bpressureData[,1] <- as.Date(bpressureData[,1], format="%m/%d/%Y")
bpressureData <-na.omit(bpressureData)

oldestSampleDate <- min(bpressureData[,"Timestamp"],na.rm=TRUE)
youngestSampleDate <- max(bpressureData[,"Timestamp"],na.rm=TRUE)

# build a data table of all of the different blood pressure ranges and their names
bPressures <- data.frame(
  "Hypotension"= c(90,60),
  "Normal"= c(119,79),
  "Prehypertension"= c(159,89),
  "Stage 1 hypertension" = c(169,99),
  "Stage 2 hypertension"= c(179,109),
  "Hypertensive emergency" = c(999,999)
)
rownames(bPressures) <- c("systolic","diastolic")

# add a column indicating the index of bPressures for systolic and diastolic
# this will pick the worst case scenario for systolic and diastolic conditions
for (bpCondIdx in ncol(bPressures):1) {
  for (bpDataIdx in 1:nrow(bpressureData)) {
    if (bpressureData[bpDataIdx,"systolic"] < bPressures["systolic",bpCondIdx]) {
      bpressureData[bpDataIdx,"condition"] <-  bpCondIdx
    }
    if (bpressureData[bpDataIdx,"diastolic"] < bPressures["diastolic",bpCondIdx] &
          bpressureData[bpDataIdx,"condition"] < bpCondIdx) {
      bpressureData[bpDataIdx,"condition"] <-  bpCondIdx
    }
  }
}
# The following will convert numeric value to text descriptors
# bpressureData[,"condition"] <-  colnames(bPressures)[as.numeric(bpressureData[,"condition"])]


# Shiny setup --------------------------------------------------------


library(shiny)
shinyServer(function(input, output) {
  
  output$firstDateRangeSelector <- renderUI({
    dateRangeInput("firstBpDates", label = h3("Date range"),
                   start=oldestSampleDate,end=youngestSampleDate,
                   min=oldestSampleDate,max=youngestSampleDate)
  })
  
  output$SecondDateRangeSelector <- renderUI({
    dateRangeInput("secondBpDates", label = h3("Date range"),
                   start=oldestSampleDate,end=youngestSampleDate,
                   min=oldestSampleDate,max=youngestSampleDate)
  })
  
  # calculateBPTable --------------------------------------------------------
  getBPSubset <- function(useTheseDates) {
    subset(bpressureData,
           Timestamp >= useTheseDates[1] &
             Timestamp <= useTheseDates[2]
    )
  }
  
  buildBPTable <- function(useTheseDates) {
    bpDataSelectedByDates <- getBPSubset(useTheseDates)
    bpCounts <- numeric()
    
    for (theIndex in 1:ncol(bPressures)) {
      bpCounts <- append(bpCounts,sum(bpDataSelectedByDates[,"condition"] == theIndex))
    }
            
    theBPTable <- data.frame(
      "Count" = bpCounts,
      "Percent" = bpCounts / sum(bpCounts)
    )
    
    rownames(theBPTable) <- colnames(bPressures)
    
    return(theBPTable) #output this table for rendertable
  }
  
  output$firstBpTable <- renderTable(buildBPTable(input$firstBpDates))
  
  output$secondBpTable <- renderTable(buildBPTable(input$secondBpDates))
  
  # BuildBoxPlots --------------------------------------------------------
  buildAPlot <- function(useTheseDates) {
    bpDataSelectedByDates <- getBPSubset(useTheseDates)
    
    boxplot(bpDataSelectedByDates[,"systolic"],xlab="Systolic",
            ylim=c(80,200)
            )
    for (bpCondIdx in 1:ncol(bPressures)) {
      yoffset <- bPressures["systolic",bpCondIdx]
      abline(h=yoffset,col="red")
      text(x=1,y=yoffset,labels=colnames(bPressures[bpCondIdx]),col="black")
    }
  }
  
  output$firstBoxplotSystolic <- renderPlot( { buildAPlot(input$firstBpDates) })
  output$secondBoxplotSystolic <- renderPlot( { buildAPlot(input$secondBpDates) })
  
  #   output$secondBoxplotSystolic <- renderPlot( {
  #     boxplot(bpressureData[,"systolic"],xlab="Systolic")
  #     for (bpCondIdx in 1:ncol(bPressures)) {
  #       yoffset <- bPressures["systolic",bpCondIdx]
  #       abline(h=yoffset,col="red")
  #       text(x=1,y=yoffset,labels=colnames(bPressures[bpCondIdx]),col="black")
  #     }
  #   })
  
  # otherOutputDefines ------------------------------------------------------
  output$theseDates <- renderPrint({input$bpDates})
  
})




