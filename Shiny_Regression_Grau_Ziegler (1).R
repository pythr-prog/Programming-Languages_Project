#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

#Libraries________________
#For the implementation we used the following libraries
#Shiny: library to build interactive web apps straight from R
library(shiny)
#Leaflet: an open-source JavaScript library for mobile-friendly interactive maps
library(leaflet)
#dplyr: a grammar of data manipulation, providing a consistent set of verbs that help you solve the most common data manipulation challenges
library(dplyr)
# Shinydashboard: Create Dashboards with 'Shiny'
library(shinydashboard)
#shinywidgets: Extend widgets available in shiny
library(shinyWidgets)

# Define UI for application that draws a histogram
ui <- dashboardPage(
    dashboardHeader(title = "Airbnb Dataset Analysis & Regression"),
    
    #The dashboard side bar can have multiple differtent menu items. Those can be configured with a name or an icon and
    # function as single sides in the App. We create regression page 
    dashboardSidebar(sidebarMenu(
        menuItem("Regression", tabName = "regression", icon = icon("th"))
       
        
        
    )),
    
    
    dashboardBody(
        
        setBackgroundColor("ghostwhite"),
        
        tabItems(
           
                    
            tabItem(tabName = "regression",
                    fluidRow(
                        column(width = 12,
                               includeHTML("/Users/alexandra.grau@de.ibm.com/Downloads/FINALFINAL.html"))))
            
            
            
        )))



# Define server logic required to draw a histogram
server <- function(input, output) {
    
}

# Run the application 
shinyApp(ui = ui, server = server)
