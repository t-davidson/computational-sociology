library(tidyverse)
library(haven)

data <- read_dta("../data/GSS2018.dta")

data_final <- data %>% select(age, sex, race, sibs,
                                    paeduc, maeduc,
                                    family16, fund16, incom16, relig16, mawrkgrw,
                                    othlang, born, parborn, granborn,
                                    zodiac,
                                    degree ) %>%
    drop_na(degree) %>%
    filter(age >= 21 & age <= 89) %>%
    haven::zap_labels() %>%
    mutate(sex = ifelse(sex == 1, 1, 0),
           degree = ifelse(degree >= 3, 1, 0))

# Define a function to calculate the mode that works for both numeric and categorical data
get_mode <- function(x) {
    ux <- unique(na.omit(x))
    mode <- ux[which.max(tabulate(match(x, ux)))]
    return(as.character(mode))
}

# Fill NA values with the mode for each column, works for all types of columns
data_filled <- data_final %>%
    mutate(across(everything(), ~ifelse(is.na(.), get_mode(.), .)))

write_csv(data_filled, "../data/2018_gss_sample.csv")


