library(anomalyr)
library(data.table)

## Add validation with param and metric
# metric <- Metric$new()
model <- Model$new()
date <- "2025-08-24"

function(input, output, session) {
  data_train <- reactive({
    file <- input$train
    if (is.null(file)) return(NULL)
    dt <- fread(file$datapath)
    if (all(c("timestamp", "value") %in% colnames(dt))) {
      stop("Dataset must contain 'timestamp' and 'value' columns.")
    }
    setorder(dt, timestamp)
    return(dt)
  })

  output$table_train <- renderDT({
    datatable(data_train(), options = list(dom = "tpi"))
  })

  output$plot_train <- renderPlotly({
    dt <- data_train()
    index <- sort(sample.int(nrow(dt), 0.1 * nrow(dt)))
    dt <- dt[index]
    plot_ly() %>%
      add_lines(
        x = dt$timestamp,
        y = dt$value,
        name = "Value",
        line = list(color = 'blue', width = 1L)
      ) %>%
      layout(title = "Training Data", xaxis = list(title = "Timestamp"), yaxis = list(title = "Value"))
  })

  output$summary_train <- renderDT({
    req(data_train())
    dt <- data_train()
    dt_summary <- dt[, .(count = .N,
                         nas = sum(is.na(value)),
                         mean = mean(value, na.rm = TRUE),
                         median = median(value, na.rm = TRUE),
                         sd = sd(value, na.rm = TRUE),
                         min = min(value, na.rm = TRUE),
                         max = max(value, na.rm = TRUE))]
    datatable(dt_summary[, lapply(.SD, function(x) round(x, 2))], options = list(dom = "t"))
  })

  metrics <- eventReactive(input$run_train, {
    req(data_train())
    dt <- data_train()
    days <- difftime(dt$timestamp[nrow(dt)], dt$timestamp[1], units = "days")
    days <- round(as.numeric(days))
    model$normalize(dt, 1440L)$train(k = input$k)$predict(1440L * days, k = input$k)
    pred <- model$prediction
    me <- mean(dt$value - pred$mean)
    mae <- mean(abs(dt$value - pred$mean))
    mse <- mean((dt$value - pred$mean)^2)
    rmse <- sqrt(mse)
    mpe <- mean((dt$value - pred$mean) / dt$value) * 100
    mape <- mean(abs((dt$value - pred$mean) / dt$value)) * 100
    data.table(me = round(me, 4), mae = round(mae, 4), mse = round(mse, 4),
               rmse = round(rmse, 4), mpe = round(mpe, 4), mape = round(mape, 4))
  })

  output$metrics_model <- renderDT({
    datatable(metrics(), options = list(dom = "t"))
  })

  data_test <- reactive({
    file <- input$test
    if (is.null(file)) return(NULL)
    dt <- fread(file$datapath)
    if (all(c("timestamp", "value") %in% colnames(dt))) {
      stop("Dataset must contain 'timestamp' and 'value' columns.")
    }
    setorder(dt, timestamp)
    return(dt)
  })

  data_pred <- eventReactive(input$run_test, {
    req(data_test())
    dt <- data_test()
    days <- difftime(dt$timestamp[nrow(dt)], dt$timestamp[1], units = "days")
    days <- round(as.numeric(days))
    model$predict(1440L * days, as.integer(input$confidence))
    pred <- model$prediction
    dt[, outlier := value < pred$lower - input$epsilon | value > pred$upper + input$epsilon]
  })

  output$pred_test <- renderDT({
    datatable(data_pred(), extensions = "Buttons",
              options = list(dom = "Btpirl", buttons = c("csv"), lengthMenu = list(c(10, -1), c("10", "All"))))
  })

  chart_test <- eventReactive(input$run_test, {
    req(data_pred())
    dt <- data_pred()
    time <- Time$new(date = format(dt$timestamp[1], "%Y-%m-%d"))
    days <- difftime(dt$timestamp[nrow(dt)], dt$timestamp[1], units = "days")
    days <- round(as.numeric(days))
    time$scale(1L, 1440L * days)
    index <- which(dt$outlier)
    plot_ly() %>%
      add_ribbons(
        x = time$serie,
        ymin = model$prediction$lower,
        ymax = model$prediction$upper,
        color = I("gray"), name = "Confidence") %>%
      add_lines(
        x = time$serie,
        y = model$prediction$mean,
        name = "Prediction",
        line = list(color = 'blue', width = 1L)) %>%
      add_markers(
        x = time$serie[-index],
        y = dt$value[-index],
        name = "Normal",
        marker = list(color = 'green', size = 2L)
      ) %>%
      add_markers(
        x = time$serie[index],
        y = dt$value[index],
        name = "Anomaly",
        marker = list(color = 'red', size = 3L)
      )
  })

  output$plotly_test <- renderPlotly({
    chart_test()
  })
}
