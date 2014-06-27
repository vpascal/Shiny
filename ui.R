library(googleVis)
library(shiny)

shinyUI(fluidPage(theme = "bootstrap.css",
  
  headerPanel("Novateca  Data App"),
    mainPanel(
    tabsetPanel(tabPanel("Profile",	
    #plotOutput("map"),
    ggvisOutput("u"),
    ggvisOutput("g")
    
  )
  )
  )
))