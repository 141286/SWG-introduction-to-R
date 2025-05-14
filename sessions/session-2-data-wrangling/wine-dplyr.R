library(readr)
library(dplyr)

# Read in the data
wine_files <- list.files("data/wine-imports/", full.names = TRUE)
wine_imports_df <- read_csv(wine_files)
glimpse(wine_imports_df)


## CLEAN THE DATA

# There a number of issues we would like to clean up before using this data.
# - The variables `type` and `sitc` are not needed.
# - The variable `perref` is a date variable, but not very usable in it current form. Create a year variable instead.
# - `comcode` is a numeric value but we want it as a character variable.
# - The variable `mode` is code for transport modes, therefore would like to recode into description value.
# - Would like to add extra variables to the dataset:
#   - price per supplementary unit
#   - indicate if coo and cod are EU countries
#   - transshipment i.e. (coo != cod)
# - Place the year variable at the beginning of dataframe.


# list of EU countries
eu_countries <- c(
  "BE", "BG", "CZ", "DK", "DE",
  "EE", "IE", "ES", "FR", "HR",
  "IT", "HU", "CY", "LV", "LT",
  "LU", "MT", "NL", "AT", "PL",
  "PT", "RO", "SI", "SK", "FI",
  "SE", "GR"
)


## SAVE THIS DATA

# Before we conduct any analysis, we want to save this dataframe for future use.
# There a number of options of how to save this data, but will save it as an rds file.




## QUESTIONS

# - What is the average price per hl by country?

# - What are the top 10 countries for UK wine imports in 2023 and 2024?

# - What is the level of transshipment trade in 2024?

# - What are the top ports of entry for each country exporting wine into the UK in 2025?
