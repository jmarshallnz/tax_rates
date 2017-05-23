library(shiny)

thresholds <- c(14000,48000,70000)

deciles <- read.csv("deciles.csv")

deciles <- data.frame(Decile=1:10, AvgIncome=(deciles$Income[-1] + deciles$Income[-nrow(deciles)])/2,
                      Min=deciles$Income[-nrow(deciles)], Max=deciles$Income[-1])

cols <- c("darkred", "steelblue")
labels <- sprintf("$%d-%dk", round(deciles$Min/1000), round(deciles$Max/1000))
labels[length(labels)] <- sprintf("$%dk+", round(deciles$Min/1000)[length(labels)])

calc_tax <- function(income, thresh=c(0,thresholds,Inf), rate=c(10.5, 17.5, 30, 33)/100) {
  # split income up into the amount in each threshold
  tax <- numeric(length(income))
  while(sum(income) > 0) {
    tax_cat <- as.numeric(cut(income, thresh, include.lowest=TRUE, right=TRUE))
    tax <- tax + (income - thresh[tax_cat]) * rate[tax_cat]
    income <- thresh[tax_cat]
  }
  tax
}

shinyServer(function(session, input, output) {

  observeEvent(input$reset, {
    for (i in seq_along(thresholds))
      updateSliderInput(session, paste0("thresh",i), value=thresholds[i])
  })

  # validate input...
  observe({
    if (input$thresh2 <= input$thresh1) {
      updateSliderInput(session, "thresh2", value=input$thresh1+1)
    }
    if (input$thresh3 <= input$thresh2) {
      updateSliderInput(session, "thresh3", value=input$thresh2+1)
    }
  })

  output$distPlot <- renderPlot({

    validate(
      need(input$thresh2 > input$thresh1 && input$thresh3 > input$thresh2, "Thresholds must be increasing")
    )

    # generate a plot of decile vs tax differences
    tax_curr <- calc_tax(deciles$AvgIncome)
    tax_next <- calc_tax(deciles$AvgIncome, thresh = c(0, input$thresh1, input$thresh2, input$thresh3, Inf))
    tax_decr <- tax_curr - tax_next

    tax_col <- cols[cut(tax_decr, c(-Inf, 0, Inf))]

#    draw_y_axt <- if (sum(tax_decr != 0) > 0) 's' else 'n'

    b = barplot(tax_decr/52, col=tax_col, xlab="Income decile (StatsNZ, 2015)", ylab="Extra money per week",
                names.arg=labels, las=1, axes=FALSE)
    ticks <- unique(round(axTicks(2)))
    cat("ticks=", ticks, "\n")
    labs  <- sprintf("$%d",abs(ticks))
    axis(2, at=ticks, labels=ifelse(ticks<0, paste0('-',labs), labs), las=1)
  })

})
