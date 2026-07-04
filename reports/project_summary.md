# Project Summary: Monthly Banana Price Forecasting

This project evaluates monthly U.S. banana prices from January 1990 through January 2026 using FRED series `APU0000711211`.

## Business objective

Banana prices are an input for short-term food cost planning. Forecasting monthly banana prices can support purchasing, budgeting, and inventory decisions.

## Data

- Monthly U.S. banana prices
- Unit: dollars per pound
- Source: FRED
- Date range: January 1990 through January 2026
- Missing October 2025 value replaced with assigned estimate of 0.667 dollars per pound

## Exploration

The price series shows a general upward trend over the sample period. Prices were lower and more volatile in the early 1990s, shifted upward after the late 2000s, and reached high levels in recent years.

STL decomposition shows that banana prices are driven mainly by long-term trend and persistence. Seasonality exists but is relatively weak.

## Transformations and stationarity

The project compares:

- Log transformation
- Guerrero Box-Cox transformation
- First difference of log price

The original price and log price series are nonstationary. The differenced log price is more stationary based on ADF and KPSS test results.

## Autocorrelation

The ACF plot shows strong persistence and slow decay. The PACF plot shows a large lag-1 spike, supporting the inclusion of persistence-based models such as Naive, Drift, AR(1), ETS, and ARIMA.

## Models compared

- Mean
- Naive
- Drift
- Seasonal Naive
- AR(1)
- ETS(ANN)
- ETS(AAN)
- ETS(AAA)
- Auto ARIMA

## Results

The final 12 observations are used as the test set. The Drift model performs best out of sample.

| Model | RMSE | MAPE |
|---|---:|---:|
| Drift | 0.0315 | 4.2741 |
| ETS_AAN | 0.0319 | 4.3320 |
| ETS_AAA | 0.0338 | 4.5399 |
| Naive | 0.0346 | 4.7135 |
| ETS_ANN | 0.0350 | 4.7622 |
| Seasonal Naive | 0.0371 | 4.9906 |
| ARIMA_auto | 0.0391 | 5.3176 |
| AR1 | 0.0532 | 7.2775 |
| Mean | 0.1122 | 16.9936 |

## Conclusion

The Drift model is selected as the preferred practical forecasting model because it gives the strongest out-of-sample forecast accuracy. Although residual diagnostics show some remaining autocorrelation, no model fully eliminates this issue, and the Drift model provides a clear and interpretable baseline for 12-month-ahead banana price planning.
