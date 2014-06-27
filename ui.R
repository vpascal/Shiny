library(googleVis)
library(shiny)

shinyUI(fluidPage(theme = "bootstrap.css",
  
  headerPanel("Novateca  Data App"),
  
  mainPanel(
    #plotOutput("map"),
    ggvisOutput("u"),
    ggvisOutput("g")
    
  )
))