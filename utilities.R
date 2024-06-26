# Utility Functions

# Function to sort AIC and BIC Scores
# Example: sort.score(AIC(model1, model2), score = 'aic')
sort.score <- function(x, score = c("bic", "aic")){
  if (score == "aic"){
    x[with(x, order(AIC)),]
  } else if (score == "bic") {
    x[with(x, order(BIC)),]
  } else {
    warning('score = "x" only accepts valid arguments ("aic","bic")')
  }
}

# ============================================================================= #

# Fitted ARIMA Models Summary generator
# Example: arima_summary(Data, c(1,1,1))

arima_summary <- function(TS_data, pdq_order, seasonal_order, period){

  # Check if TS_data is of class 'ts'
  if (!inherits(TS_data, "ts")) {
    stop("TS_data must be of class 'ts'")
  }

  # Estimate ARIMA model using CSS method
  model_css <- TS_data %>% Arima(order = pdq_order,
                                 seasonal = list(order=seasonal_order, period = period),
                                 method = 'CSS')

  # Print parameter estimation results for CSS method
  cat("\nParameter Estimation through Least Squares (CSS) Method for ARIMA(",
      pdq_order, ")(1,1,2)[11]\n")
  print(lmtest::coeftest(model_css))
  cat("==============================================================")

  # Estimate ARIMA model using ML method
  model_ml <- TS_data %>% Arima(order = pdq_order,
                                seasonal = list(order=seasonal_order, period = period),
                                method = 'ML')

  # Print parameter estimation results for ML method
  cat("\nParameter Estimation through Maximum Likelihood (ML) Method for ARIMA(",
      pdq_order, ")(1,1,2)[11]\n")
  print(lmtest::coeftest(model_ml))
  cat("==============================================================")

  # Estimate ARIMA model using CSS-ML method
  model_cssml <- TS_data %>% Arima(order = pdq_order,
                                   seasonal = list(order=seasonal_order, period = period),
                                   method = 'CSS-ML')

  # Print parameter estimation results for CSS-ML method
  cat("\nParameter Estimation through Combination (CSS-ML) Method for ARIMA(",
      pdq_order, ")(1,1,2)[11]\n")
  print(lmtest::coeftest(model_cssml))
  cat("==============================================================")

  # Store the models in a list
  ret_list <- list(model_css, model_ml, model_cssml)

  # Create names for the list elements based on pdq_order
  label <- paste0(pdq_order, collapse = "")
  names(ret_list) <- c(paste0("model_", label, "_css"),
                       paste0("model_", label, "_ml"),
                       paste0("model_", label, "_cssml"))

  # Return the list of models
  return(ret_list)
}

# ============================================================================= #

# Function for Plotting ACF and PACF Plots

plot_acf_pacf <- function(TS_data, acf_main = 'ACF Plot', pacf_main = 'PACF Plot', max_lag = 30) {
  # Set up the plotting area to have 2 plots side by side
  par(mfrow = c(1, 2))

  # Plot ACF
  acf(TS_data, lag.max = max_lag, main = acf_main, xlab = "Lag", ylab = "ACF")
  grid(nx = NULL, ny = NULL, col = "gray", lty = "dotted")

  # Plot PACF
  pacf(TS_data, lag.max = max_lag, main = pacf_main, xlab = "Lag", ylab = "PACF")
  grid(nx = NULL, ny = NULL, col = "gray", lty = "dotted")

  # Reset plotting area to default
  par(mfrow = c(1, 1))
}

# ============================================================================= #

check_residuals <- function(TS_data, order, seasonal_order, period,
                            acf_lag=60,
                            pacf_lag=60,
                            res_main='Residuals',
                            hist_main='Histogram',
                            acf_main='ACF',
                            pacf_main='PACF',
                            qq_main='QQ-Plot'){

  # Set up the plotting area to have 2 plots side by side
  par(mfrow = c(2, 3))

  library(FitAR)
  # Obtain Residuals
  residuals <- TS_data %>%
    Arima(order = order,
          seasonal = list(order=seasonal_order, period = period)) %>%
    rstandard()

  print(shapiro.test(residuals))

  # Plot Residuals
  residuals %>% plot(type = 'o',
                     main = res_main,
                     ylab = 'Standardized Residuals',
                     lwd=1)
  abline(h=0, lty=2, col='blue', lwd=2)

  grid(nx = NULL, ny = NULL, col = "gray", lty = "dotted")

  # Plot Histogram
  residuals %>% hist(main = hist_main)
  grid(nx = NULL, ny = NULL, col = "gray", lty = "dotted")

  # Plot QQ-Plot
  residuals %>% qqnorm(main = qq_main)
  residuals %>% qqline(lty=2, col='blue')
  grid(nx = NULL, ny = NULL, col = "gray", lty = "dotted")

  # Plot ACF
  residuals %>% acf(main=acf_main, lag.max = acf_lag)
  grid(nx = NULL, ny = NULL, col = "gray", lty = "dotted")

  # Plot PACF
  residuals %>% pacf(main=pacf_main, lag.max = pacf_lag)
  grid(nx = NULL, ny = NULL, col = "gray", lty = "dotted")

  # LJung-Box Test
  k=0
  if (length(residuals) < 30){
    lagM <- length(residuals) - 1
  } else {
    lagM <- 29
  }
  LBQPlot(residuals, lag.max = lagM, StartLag = k + 1, k = 0, SquaredQ = FALSE)
  grid(nx = NULL, ny = NULL, col = "gray", lty = "dotted")


  # Reset plotting area to default
  par(mfrow = c(1, 1))
}
















