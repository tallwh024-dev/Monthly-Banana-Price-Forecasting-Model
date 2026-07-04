# Monthly Banana Price Forecasting Model
# Author: Jackson Wang

library(tidyverse)
library(quantmod)
library(tsibble)
library(tsbox)
library(fable)
library(feasts)
library(lubridate)
library(tseries)
library(ggtime)

symbol <- "APU0000711211"
from <- as.Date("1990-01-01")
to <- as.Date("2026-01-01")

invisible(getSymbols(symbol, src = "FRED", from = from, to = to))

banana_tsbl <- ts_tsibble(APU0000711211) |>
  rename(Date = time, Price = value) |>
  mutate(
    Month = yearmonth(Date),
    Price = if_else(Month == yearmonth("2025 Oct") & is.na(Price), 0.667, Price)
  ) |>
  as_tsibble(index = Month) |>
  select(Month, Price) |>
  filter(Month >= yearmonth("1990 Jan"), Month <= yearmonth("2026 Jan"))

# Exploration
banana_tsbl |> autoplot(Price) + labs(title = "Monthly Banana Prices", y = "Price per Pound")
banana_tsbl |> model(STL(Price ~ season(window = "periodic"))) |> components() |> autoplot()
banana_tsbl |> ggtime::gg_season(Price, labels = "both") + labs(title = "Seasonal Banana Price")
banana_tsbl |> ggtime::gg_subseries(Price) + labs(title = "Banana Price Monthly Subseries")

# Transformations and stationarity
lambda_banana <- banana_tsbl |> features(Price, guerrero) |> pull(lambda_guerrero)

banana_tsbl <- banana_tsbl |>
  mutate(
    log_price = log(Price),
    boxcox_price = box_cox(Price, lambda_banana),
    diff_log_price = difference(log_price)
  )

banana_tsbl |> autoplot(log_price) + labs(title = "Log Price of Bananas")
banana_tsbl |> autoplot(boxcox_price) + labs(title = "Box-Cox Transformed Banana Price")
banana_tsbl |> autoplot(diff_log_price) + labs(title = "First Difference of Log Price")

adf.test(banana_tsbl$Price)
adf.test(na.omit(banana_tsbl$diff_log_price))
banana_tsbl |> features(Price, unitroot_kpss)
banana_tsbl |> features(log_price, unitroot_kpss)
banana_tsbl |> features(diff_log_price, unitroot_kpss)

# ACF and PACF
banana_tsbl |> ACF(Price, lag_max = 100) |> autoplot() + labs(title = "ACF: Banana Price")
banana_tsbl |> PACF(Price, lag_max = 100) |> autoplot() + labs(title = "PACF: Banana Price")

# Train-test model comparison
n_test <- 12
train <- banana_tsbl |> slice(1:(n() - n_test))
test <- banana_tsbl |> slice((n() - n_test + 1):n())

fit_models <- train |>
  model(
    Mean = MEAN(Price),
    Naive = NAIVE(Price),
    Drift = RW(Price ~ drift()),
    Seasonal_Naive = SNAIVE(Price ~ lag("year")),
    AR1 = ARIMA(Price ~ pdq(1, 0, 0) + PDQ(0, 0, 0)),
    ETS_ANN = ETS(Price ~ error("A") + trend("N") + season("N")),
    ETS_AAN = ETS(Price ~ error("A") + trend("A") + season("N")),
    ETS_AAA = ETS(Price ~ error("A") + trend("A") + season("A")),
    ARIMA_auto = ARIMA(Price)
  )

fc_test <- fit_models |> forecast(h = n_test)
fc_test |> autoplot(banana_tsbl, level = NULL) + labs(title = "Model Forecasts Compared with Test Data")

accuracy_table <- fc_test |> accuracy(test) |> select(.model, ME, RMSE, MAE, MAPE, MASE, RMSSE) |> arrange(RMSE)
accuracy_table

fit_models |> glance() |> select(.model, sigma2, log_lik, AIC, AICc, BIC) |> arrange(AICc)
fit_models |> select(Drift) |> gg_tsresiduals()
augment(fit_models) |> features(.innov, ljung_box, lag = 12, dof = 0) |> arrange(lb_pvalue)

# Final 12-month-ahead forecasts
final_fit <- banana_tsbl |> model(
  Mean = MEAN(Price),
  Naive = NAIVE(Price),
  Drift = RW(Price ~ drift()),
  Seasonal_Naive = SNAIVE(Price ~ lag("year")),
  AR1 = ARIMA(Price ~ pdq(1, 0, 0) + PDQ(0, 0, 0)),
  ETS_ANN = ETS(Price ~ error("A") + trend("N") + season("N")),
  ETS_AAN = ETS(Price ~ error("A") + trend("A") + season("N")),
  ETS_AAA = ETS(Price ~ error("A") + trend("A") + season("A")),
  ARIMA_auto = ARIMA(Price)
)

final_forecast <- final_fit |> forecast(h = 12)
final_forecast |> autoplot(banana_tsbl) + labs(title = "12-Month Ahead Forecast: Banana Price")

forecast_table <- final_forecast |>
  hilo(level = 90) |>
  mutate(p5 = `90%`$lower, p95 = `90%`$upper) |>
  as_tibble() |>
  select(.model, Month, Point_Forecast = .mean, p5, p95)

forecast_table
