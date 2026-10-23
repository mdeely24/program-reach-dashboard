library(shiny); library(bslib); library(bsicons)
library(dplyr); library(plotly); library(readr); library(lubridate)

visits <- read_csv("data/visits.csv", show_col_types = FALSE)

# Orange palette (change these to adjust the look everywhere)
orange_dark  <- "#C2410C"
orange_main  <- "#EA580C"
orange_mid   <- "#F97316"
orange_light <- "#FB923C"
orange_pale  <- "#FED7AA"

theme <- bs_theme(version = 5, bootswatch = "flatly",
                  primary = orange_main, success = orange_mid, info = orange_light)

ui <- page_navbar(
  title = "Program Reach Dashboard",
  theme = theme,
  bg = orange_dark, inverse = TRUE,
  nav_panel("Reach",
            layout_sidebar(
              sidebar = sidebar(
                width = 280,
                dateRangeInput("dates", "Date range",
                               start = min(visits$month), end = max(visits$month),
                               min = min(visits$month), max = max(visits$month),
                               format = "M yyyy", startview = "year"),
                checkboxGroupInput("topics", "Topic",
                                   choices = sort(unique(visits$topic)),
                                   selected = unique(visits$topic)),
                hr(),
                helpText("Student presentations only. School names are not shown.")
              ),
              layout_columns(
                fill = FALSE, col_widths = c(4, 4, 4),
                value_box("Presentations", textOutput("n_pres"),
                          showcase = bs_icon("easel"),
                          theme = value_box_theme(bg = orange_dark, fg = "white")),
                value_box("Students reached", textOutput("n_students"),
                          showcase = bs_icon("people-fill"),
                          theme = value_box_theme(bg = orange_main, fg = "white")),
                value_box("Schools visited", textOutput("n_schools"),
                          showcase = bs_icon("building"),
                          theme = value_box_theme(bg = orange_light, fg = "#431407"))
              ),
              layout_columns(
                col_widths = c(7, 5),
                card(card_header("Presentations per month"), plotlyOutput("trend")),
                card(card_header("Presentations by topic"), plotlyOutput("by_topic"))
              )
            )
  )
)

server <- function(input, output) {
  d <- reactive({
    visits |>
      filter(month >= floor_date(input$dates[1], "month"),
             month <= floor_date(input$dates[2], "month"),
             topic %in% input$topics)
  })
  
  output$n_pres     <- renderText(format(sum(d()$engagements, na.rm = TRUE), big.mark = ","))
  output$n_students <- renderText(format(sum(d()$students, na.rm = TRUE), big.mark = ","))
  output$n_schools  <- renderText(n_distinct(d()$school_id))
  
  output$trend <- renderPlotly({
    df <- d() |> group_by(month) |> summarise(presentations = sum(engagements))
    validate(need(nrow(df) > 0, "No data for these filters"))
    plot_ly(df, x = ~month, y = ~presentations, type = "bar",
            marker = list(color = orange_mid),
            hovertemplate = "%{x|%b %Y}: %{y} presentations<extra></extra>") |>
      layout(xaxis = list(title = "", tickformat = "%b %Y"),
             yaxis = list(title = "Presentations"),
             margin = list(t = 10)) |>
      config(displayModeBar = FALSE)
  })
  
  output$by_topic <- renderPlotly({
    df <- d() |> group_by(topic) |>
      summarise(presentations = sum(engagements)) |>
      arrange(presentations)
    validate(need(nrow(df) > 0, "No data for these filters"))
    plot_ly(df, x = ~presentations, y = ~factor(topic, levels = topic),
            type = "bar", orientation = "h",
            marker = list(color = orange_main),
            hovertemplate = "%{y}: %{x}<extra></extra>") |>
      layout(xaxis = list(title = "Presentations"),
             yaxis = list(title = ""),
             margin = list(t = 10, l = 10)) |>
      config(displayModeBar = FALSE)
  })
}

shinyApp(ui, server)