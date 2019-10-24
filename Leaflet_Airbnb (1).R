#Introduction______________
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# This applocation aims to imitate a filter dashboard for Airbnb selections. It can be used in the booking process
# and can be applied to various other use cases where a interacitve filtering is needed.
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





#Dataframe ________________

#Here we load our dataframe which contains Airbnb booking data from New York City.
newyork <- read.csv("/Users/alexandra.grau@de.ibm.com/Downloads/ts_new_york_2016-01-20 2.csv")

#As the dataset contains rows with missing values, we cut them out. The dataset has now around 22.000 records.
newyork <- na.omit(newyork)

#During the implementation, we recognized performance issues while using all records. With this statement we limit the dataset to 150 records.
newyork <- head(newyork,150) 




# UI Part_________________
#The UI part of the shiny App defines the user interface of the App. Here you can define the body of the app and
# add your widgets.

# For the body we use the dashboardpage function of the shinydashboard library. It eases the creation of dashboards
# with adding a header,a body, a sidebar and a title. We use the header, the sidbar and the body.
ui <- dashboardPage(
    dashboardHeader(title = "Airbnb Filter Location Page"),

#The dashboard side bar can have multiple differtent menu items. Those can be configured with a name or an icon and
# function as single sides in the App. We create a dashboard and a regression page 
    dashboardSidebar(sidebarMenu(
        menuItem("Regression", tabName = "regression", icon = icon("th")),
        menuItem("Filter Dashboard", tabName = "dashboard", icon = icon("dashboard"))
        
        
    )),
    
#The main body typically contains which can be plots or widgets. In our case we use one box as the leaflet map output
# and the other box as our widget with different inputs e.g. slider, radiobuttons, picker. Here, the user can
# filter the accomodations depending on its preferences. 

    dashboardBody(
        
        setBackgroundColor("ghostwhite"),
        
    tabItems(
        tabItem(tabName = "dashboard",
            
        fluidRow(
            column(width = 8,
            # Box with leaflet output.
            box(width = NULL, status= "success",  leafletOutput(outputId = "map", height = "95vh"))),
            
            box(
                title = "About New York", width = 4, background = "light-blue",
                "New York City, officially the City of New York, historically New Amsterdam, the Mayor, Alderman, and Commonality of the City of New York, and New Orange, byname the Big Apple, city and port located at the mouth of the Hudson River, southeastern New York state, northeastern U.S. It is the largest and most influential American metropolis, encompassing Manhattan and Staten islands, the western sections of Long Island, and a small portion of the New York state mainland to the north of Manhattan. New York City is in reality a collection of many neighbourhoods scattered among the city’s five boroughs—Manhattan, Brooklyn, the Bronx, Queens, and Staten Island—each exhibiting its own lifestyle. Moving from one city neighbourhood to the next may be like passing from one country to another. New York is the most populous and the most international city in the country. "
            ),
            
            column(width = 4,
            #Box with user input widgets.
            box(width = NULL, status = "warning",
                title = "Choose your settings:",
                
                sliderInput("price", "What is the maximum price per night for the Airbnb?",
                            0, 5000,100,  step = 20, pre = "$"),
                
                radioButtons("roomtype", "Select your room type", choices = list("Entire home/apt","Private room","Shared room")),
                
                sliderInput("reviews", "Minimum number of reviews on AirBnb",
                            10, 300,0, step = 10),
                
                sliderInput("satisfaction", "Overall Satisfication with the AirBnb",
                            1, 5,0, step = 0.5),
                
                sliderInput("accommodates", "For how many people would you like to book (min)?",
                            1, 10,0, step = 1),
                
                sliderInput("bedrooms", "How many bedrooms should the accommodation have?",
                            1, 10,0, step = 1),
                
                pickerInput(
                    inputId = "borough", 
                    label = "Select/deselect your borough:", 
                    choices = c("Manhattan", "Brooklyn", "Queens", "Bronx", "Staten Island"), 
                    options = list(
                        `actions-box` = TRUE, 
                        size = 10,
                        `selected-text-format` = "count > 3"
                    ), 
                    multiple = TRUE
                        )
                        )
                    )
            
            )
        ),
    
    #Here we would like to insert our regression, as we had problems with the HTML file, we use the rmd file
        tabItem(tabName = "regression",
                fluidRow(
                column(width = 12,
                       includeMarkdown("/Users/alexandra.grau@de.ibm.com/Downloads/Abgabe.Rmd"))))
    
         
    
    )))
       
    
    




# Define server logic required to draw a map
server <- function(input, output, session) {
    #Here our leaflet map is called the fist time, it uses the dataframe newyork
       output$map <- renderLeaflet({
           leaflet() %>%
               
               #addTiles changes the template of the map
               addTiles(urlTemplate = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
                        attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>') %>%  # Add default OpenStreetMap map tiles
               
               #with addMarkers we put markers on the Airbnb locations, popup makes information popup when clicking on the marker of a certain airbnb
               addMarkers(data=newyork, lng=~longitude, lat=~latitude, popup=paste("Borough:", newyork$borough, "<br>",
                                                                                   "Neighborhood:", newyork$neighborhood, "<br>",
                                                                                   "Price per night:", newyork$price, "<br>",
                                                                                   "Rating:", newyork$overall_satisfaction))
       })
    
    #reactive is a function which reacts to user innput, here we create a dataset depending on the user input and filters
    ny1 <- reactive({
    subset(newyork, reviews >= input$reviews & 
               overall_satisfaction  >=  input$satisfaction &
               price <= input$price &
               room_type == input$roomtype &
               bedrooms >= input$bedrooms &
               accommodates  >=  input$accommodates &
               borough == input$borough
               )
    })
    
    
    
    
    # respond to the filtered datad a new map is generated based on the new dataset and therefore is filtered
    observe({
        
        leafletProxy(mapId = "map") %>%
            clearMarkers() %>%   ## clear previous markers
            addMarkers(data = ny1(), lng=~longitude, lat=~latitude, popup=paste("Borough:", ny1()$borough, "<br>",
                                    "$ per night:", ny1()$price, "<br>",
                                  "Neighborhood:", ny1()$neighborhood, "<br>",
                                  "Rating:", ny1()$overall_satisfaction, "<br>",
                                  "Type:", ny1()$room_type, "<br>"
                                  ))
    })
    
    
    session$onSessionEnded(stopApp)
    
}


# Run the application 
shinyApp(ui = ui, server = server)
