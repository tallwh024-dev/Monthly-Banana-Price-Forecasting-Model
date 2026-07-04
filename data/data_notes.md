# Data

This project uses public monthly banana price data from FRED.

Series used:

- APU0000711211: Average Price: Bananas, per pound in U.S. city average

Sample period:

- January 1990 through January 2026

The script downloads the data directly with `quantmod::getSymbols()`.

The local `banana_data.RData` file is not uploaded because the data can be reproduced from FRED. In the original class assignment, the missing October 2025 value was replaced with the assigned estimate of 0.667 dollars per pound.
