library(googleVis)
library(shiny)
shinyUI(navbarPage("Novateca  Data App", theme="bootstrap.css",
                  tabPanel("ORT",
p("The Online Reporting Tool (ORT) is an on-line data collection platform, which allows the Novateca impact team to collect data from participating libraries on a monthly basis. The ORT collects information in several core areas: visits; user activities in the library/at workstations; trainings statistics; consultations; events for library users/other organizations; success stories; comments and feedback."),navlistPanel("categories",widths = c(2,8),tabPanel("Map",
   # mainPanl(
    ggvisOutput("map")),tabPanel("Demographic Profile",
    ggvisOutput("u"),
    ggvisOutput("g"),
    ggvisOutput("a")),tabPanel("Visits",
    ggvisOutput("v")
    
  ))),
tabPanel("POP Survey")
  ))