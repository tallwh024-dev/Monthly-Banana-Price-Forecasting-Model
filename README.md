# Monthly Banana Price Forecasting Model

This repository contains a CFRM 586 time-series forecasting project analyzing monthly U.S. banana prices.

The project uses FRED series `APU0000711211`, monthly U.S. average retail banana prices, from January 1990 through January 2026. The analysis evaluates trend, seasonality, transformations, autocorrelation, model accuracy, residual diagnostics, and 12-month-ahead forecasts.

## Project objective

The goal is to determine whether historical banana price patterns can support short-term food cost planning, purchasing, budgeting, and inventory decisions.

## Data

- Source: Federal Reserve Economic Data (FRED)
- Series: `APU0000711211`
- Description: Average Price: Bananas, per pound in U.S. city average
- Frequency: Monthly
- Sample period: January 1990 to January 2026
- Unit: U.S. dollars per pound

The October 2025 missing value is replaced with the assigned estimate of `0.667` dollars per pound.

## Methods

The analysis includes:

- Time-series visualization
- STL decomposition
- Seasonal plot and monthly subseries plot
- Log transformation
- Guerrero Box-Cox transformation
- First difference of log price
- ADF and KPSS stationarity tests
- ACF and PACF analysis
- Train/test split using the final 12 months as the test period
- Forecast comparison across multiple models
- Ljung-Box residual diagnostics
- 12-month-ahead forecast table with 5th and 95th percentile ranges

## Models compared

- Mean
- Naive
- Random Walk with Drift
- Seasonal Naive
- AR(1)
- ETS(ANN)
- ETS(AAN)
- ETS(AAA)
- Auto ARIMA

## Key findings

- Banana prices show a long-term upward trend from 1990 to 2026.
- Seasonality is present but weak compared with the long-term trend and persistence.
- The original price and log price series are nonstationary.
- The differenced log price is more stationary based on ADF and KPSS results.
- ACF shows strong persistence and slow decay, while PACF has a large lag-1 spike.
- The Drift model performs best out of sample, with the lowest RMSE and MAPE in the test-period comparison.
- The Drift model is selected as the preferred model for practical 12-month-ahead banana price forecasting.

## Main result

The final model selection is based primarily on out-of-sample forecast accuracy. The Drift model produces the strongest test-set performance:

| Model | RMSE | MAPE |
|---|---:|---:|
| Drift | 0.0315 | 4.2741 |

## Repository structure

```text
Monthly-Banana-Price-Forecasting-Model/
├── README.md
├── scripts/
│   └── banana_price_forecasting.R
├── source/
│   └── project_report.Rmd
├── reports/
│   └── project_summary.md
├── outputs/
│   ├── model_accuracy.csv
│   └── model_fit_statistics.csv
├── data/
│   └── data_notes.md
└── requirements.txt
```

## How to run

1. Install the R packages listed in `requirements.txt`.
2. Run:

```r
source("scripts/banana_price_forecasting.R")
```

The script downloads the FRED data directly with `quantmod::getSymbols()`. If using the original class file, place `banana_data.RData` locally, but this repository is designed to be reproducible from FRED.

## Tools used

- R
- tidyverse
- quantmod
- tsibble
- tsbox
- fable
- feasts
- ggplot2
- tseries
- knitr

## Author

Jackson Wang  
M.S. Computational Finance and Risk Management  
University of Washington
