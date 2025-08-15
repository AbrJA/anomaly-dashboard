library(bslib)

page_navbar(
  title = "Sensor!",
  nav_panel(
    title = "Train",
    icon = icon("robot"),
    layout_sidebar(
      sidebar = sidebar(
        width = 300,
        fileInput("train", "Dataset:", accept = ".csv"),
        sliderInput("k", "K:", min = 1L, max = 4L, value = 2L, step = 1L),
        actionButton("run_train", "Train!", icon("robot"))
      ),
       navset_card_underline(
        title = "View",
        nav_panel("Summary", DTOutput("summary_train"), hr(), DTOutput("metrics_model")),
        nav_panel("Table", DTOutput("table_train")),
        nav_panel("Plot", plotlyOutput("plot_train"))
      )
    )
  ),
  nav_panel(
    title = "Test",
    icon = icon("chart-simple"),
    layout_sidebar(
      sidebar = sidebar(
        width = 300,
        fileInput("test", "Dataset:", accept = ".csv"),
        selectInput("confidence", "Confidence:", choices = c(80, 90, 95, 99)),
        sliderInput("epsilon", "Epsilon:", min = 0.0, max = 1.0, value = 0.0, step = 0.1),
        actionButton("run_test", "Test!", icon("chart-simple"))
      ),
      navset_card_underline(
        title = "View",
        nav_panel("Plot", plotlyOutput("plotly_test")),
        nav_panel("Table", DTOutput("pred_test"))
      )
    )
  )
)

# sudo docker build -t dashboard .
# sudo docker run -p 8000:8000 --name dashboard-cont dashboard
