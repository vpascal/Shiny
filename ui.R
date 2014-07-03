#library(googleVis)
library(shiny)
library(ggvis)


shinyUI(navbarPage("Novateca  Data App", theme="bootstrap.css",
                  tabPanel("Online Reporting Tool",
p("The Online Reporting Tool (ORT) is an on-line data collection platform, which allows the Novateca impact team to collect data from participating libraries on a monthly basis. The ORT collects information in several core areas: visits; user activities in the library/at workstations; trainings statistics; consultations; events for library users/other organizations; success stories; comments and feedback."),navlistPanel("Categories",widths = c(2,8),tabPanel("Map",                                                                                                                                                                                                                                                                                                                                                                                                                                                                     # mainPanl(
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
    ggvisOutput("map")),tabPanel("Demographic Profile", 
    tags$div(HTML("<strong>Number of Library Users</strong>")),
    ggvisOutput("u"), tags$div(HTML("<strong>Number of Library Users by Sex</strong>")),
    ggvisOutput("g"), tags$div(HTML("<strong>Number of Library Users by Age</strong>")),
    ggvisOutput("a")),tabPanel("Visits", tags$div(HTML("<strong>Number of Physical Visits</strong>")),
    ggvisOutput("v"), tags$div(HTML("<strong>Number of Event Participants</strong>")),
    ggvisOutput("p")
    
  ))),
tabPanel("POP Surveys"),
tabPanel("National Statistics")
  ))