install.packages("readxl")

library(readxl)

library(readxl); library(dplyr); library(purrr)
library(janitor); library(stringr); library(lubridate); library(readr)

# 1. Point to your Excel file
path <- "data-raw/schools.xlsx"     # <- change to your real file name

# 2. Read and stack all sheets
sheet_names <- excel_sheets(path)
print(sheet_names)

schools <- map_dfr(sheet_names, function(s) {
  read_excel(path, sheet = s, col_types = "text") |>
    clean_names() |>
    mutate(sheet_name = s)
})

# 3. Clean
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

# 4. Checks (look at the output in the Console)
glimpse(schools)                      # about 109 rows
print(sum(is.na(schools$month)))      # should be 0
print(count(schools, topic))          # 5 topics
print(n_distinct(schools$school_name))

# 5. Aggregate for the app (no school names)
reach <- schools |>
  group_by(month, topic) |>
  summarise(presentations = sum(engagements, na.rm = TRUE),
            students      = sum(students, na.rm = TRUE),
            schools       = n_distinct(school_name),
            .groups = "drop")

dir.create("data", showWarnings = FALSE)
write_csv(reach, "data/reach.csv")

# 6. Overall totals for reference
cat("Unique schools:", n_distinct(schools$school_name), "\n")
cat("Presentations:", sum(schools$engagements, na.rm = TRUE), "\n")
cat("Students reached:", sum(schools$students, na.rm = TRUE), "\n")

