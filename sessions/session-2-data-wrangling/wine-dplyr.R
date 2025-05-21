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


wine_df <- wine_imports_df |>
  select(-c(type, sitc)) |>
  mutate(
    year = perref %/% 100,
    comcode = as.character(comcode),
    mode = case_when(mode == 10 ~ "Sea",
                     mode == 20 ~ "Rail",
                     mode == 30 ~ "Air",
                     mode == 50 ~ "Mail",
                     mode == 60 ~ "RORO",
                     mode == 80 ~ "Inland Waterway",
                     mode == 90 ~ "Self Propulsion",
                     .default = "Unknown"),
    price_hl = value / supp_unit,
    cod_region = case_match(cod,
                            eu_countries ~ "EU",
                            .default = "Non-EU"),
    coo_region = case_match(coo,
                            eu_countries ~ "EU",
                            .default = "Non-EU"),
    transhipment = if_else(coo != cod, "yes", "no")
  ) |>
  relocate(year, .after = perref) |>
  select(year:transhipment)

## SAVE THIS DATA

# Before we conduct any analysis, we want to save this dataframe for future use.
# There a number of options of how to save this data, but will save it as an rds file.
wine_df |> write_rds("data/wine-imports.rds")



## QUESTIONS

# - What is the average price per hl by country?

wine_df |>
  filter(!is.infinite(price_hl)) |>
  summarise(price_hl = mean(price_hl), .by = cod) |>
  arrange(desc(price_hl))

# - What are the top 10 countries for UK wine imports in 2023 and 2024?

wine_df |>
  filter(year %in% c(2023, 2024)) |>
  group_by(year, cod) |>
  summarise(total_value = sum(value)) |>
  slice_max(order_by = total_value, n = 10) |>
  ungroup()

# - What is the level of transshipment trade in 2024?

wine_df |>
  filter(year == 2024) |>
  summarise(level = sum(value[transhipment == "yes"], na.rm = TRUE) / sum(value, na.rm = TRUE)) |>
  pull(level)

# - What are the top ports of entry for each country exporting wine into the UK in 2025?

wine_df |>
  filter(year == 2025, !is.na(port)) |>
  summarise(total_value = sum(value, na.rm = TRUE),
            .by = c(cod, port)) |>
  slice_max(order_by = total_value,
            n = 1,
            by = c(cod)) |>
  arrange(-total_value)
