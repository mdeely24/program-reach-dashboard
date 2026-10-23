# Program Reach Dashboard

An interactive R Shiny dashboard showing the reach of school-based youth mental health presentations: how many presentations were delivered, how many students were reached, how many schools were visited, and which topics were covered.

**Live dashboard:** (https://mdeely24.shinyapps.io/gabriels-light-dashboard/)



## What it shows
- **Summary cards:** total presentations, students reached, and unique schools visited
- **Presentations per month:** a bar chart across the school year (bars, not a line, so gaps such as summer break are shown honestly)
- **Presentations by topic:** a ranked comparison of the topics presented
- **Filters:** date range and topic checkboxes that update every card and chart

## Questions it answers
- How has the number of presentations and students reached changed over time?
- Which topics are presented most often?
- How many different schools has the program reached?

## Data and privacy
- Source data came from Excel records of presentations and is **not included** in this repository.
- School names and contact information are **not used** in the dashboard. Schools are replaced with random codes, so the app can count unique schools without identifying them.
- The dashboard covers student presentations only.
- The data shown is real and has been approved for public use by the organization.

## Tools
R, Shiny, bslib, plotly, dplyr, purrr, readxl, janitor, stringr, lubridate, readr

## How it works
1. `prep.R` reads the Excel workbook (one sheet per semester), stacks the sheets, cleans dates, names, and counts, assigns anonymous school codes, and writes `data/visits.csv`.
2. `app.R` reads `data/visits.csv` and builds the dashboard.

## Data cleaning highlights
- Combined four semester sheets with matching columns into one table
- Converted text dates like `(09/2024)` into real dates
- Trimmed stray whitespace and standardized inconsistent school and topic names
- Removed contact columns, summary rows, and blank rows
- Replaced school names with random codes before any data reaches the app

## Run it yourself
1. Install the packages:
   ```r
   install.packages(c("shiny", "bslib", "bsicons", "dplyr", "plotly",
                      "readr", "lubridate"))
   ```
2. Open `app.R` in RStudio and click **Run App**. The repository includes `data/visits.csv`, so `prep.R` is only needed if you have your own source data.

## Repository contents
| File | Purpose |
|---|---|
| `app.R` | The Shiny dashboard |
| `prep.R` | Cleans the source Excel data and writes `data/visits.csv` |
| `data/visits.csv` | Anonymized visit-level data used by the app |

## Author
Maeve Deely, DePaul University, B.A. Data Science
