
library(shiny)

shinyUI(fluidPage(

  # Application title
  titlePanel("Effect of NZ income tax threshold changes"),

  # Sidebar with a slider input for number of bins
  sidebarLayout(
    sidebarPanel(
      sliderInput("thresh1",
                  "10.5% threshold",
                  min = 1000,
                  max = 30000,
                  step = 500,
                  value = 14000),
      sliderInput("thresh2",
                  "17.5% threshold",
                  min = 15000,
                  max = 70000,
                  step = 500,
                  value = 48000),
      sliderInput("thresh3",
                  "30% threshold",
                  min = 48000,
                  max = 150000,
                  step = 500,
                  value = 70000),
      actionButton("reset", "Reset")
    ),

    # Show a plot of the generated distribution
    mainPanel(
      plotOutput("distPlot"),
      p("NOTES: Midpoint of decile taken as representative. Income deciles from ", 
        a(href="http://www.stats.govt.nz/browse_for_stats/people_and_communities/Households/HouseholdEconomicSurvey_HOTPYeJun15/Tables.aspx", "StatsNZ, June 2015."))
    )
  )
))
