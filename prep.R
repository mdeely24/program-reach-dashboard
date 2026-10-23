library(readxl); library(dplyr); library(purrr)
library(janitor); library(stringr); library(lubridate); library(readr)

path <- "data-raw/schools.xlsx"     # <- your real file name

sheet_names <- excel_sheets(path)

schools <- map_dfr(sheet_names, function(s) {
  read_excel(path, sheet = s, col_types = "text") |>
    clean_names() |>
    mutate(sheet_name = s)
})

schools <- schools |>
  rename(engagements = starts_with("number_of_engagements")) |>
  filter(!is.na(school_name)) |>
  mutate(
    month       = my(str_remove_all(month_and_year, "[()]")),
    school_name = str_squish(school_name),
    grade       = str_squish(grade),
    topic       = str_squish(topic_presented),
    students    = as.numeric(number_of_students),
    engagements = as.numeric(engagements)
  ) |>
  select(sheet_name, month, school_name, grade, topic, students, engagements)

reach <- schools |>
  group_by(month, topic) |>
  summarise(presentations = sum(engagements, na.rm = TRUE),
            students      = sum(students, na.rm = TRUE),
            schools       = n_distinct(school_name),
            .groups = "drop")

dir.create("data", showWarnings = FALSE)
write_csv(reach, "data/reach.csv")

glimpse(schools)