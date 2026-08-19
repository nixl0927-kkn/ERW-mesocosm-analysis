# ERW Mesocosm Analysis

This repository contains the data and R code used to analyse carbon cycling and stream metabolism in an enhanced rock weathering (ERW) mesocosm experiment. The experiment compared six ERW application rates (0, 5, 10, 20, 50 and 100 t ha⁻¹) under groundwater and river-water conditions.

The analyses cover stream metabolism (GPP, ER and NEP), dissolved inorganic and organic carbon, benthic and pelagic particulate carbon, and an overview of the measured carbon pools.

## Repository structure

```text
ERW-mesocosm-analysis/
├── code/
│   ├── stream_metabolism_analysis.Rmd
│   ├── DIC_analysis.Rmd
│   ├── DOC_analysis.Rmd
│   ├── particulate_carbon_analysis.Rmd
│   └── carbon_overview_first_week.R
├── data/
│   ├── combined_do_light_data.csv
│   ├── Meso_9_clean.xlsx
│   ├── ERW_IC_results_R_ready.xlsx
│   ├── ERW_DOC.xlsx
│   ├── benthic_carbon_mass.xlsx
│   └── pelagic_carbon_mass.xlsx
└── outputs/
```

The `outputs/` directory is created automatically by the analysis scripts and contains exported figures, tables and model results.

## Analysis scripts

| Script | Description |
|---|---|
| `stream_metabolism_analysis.Rmd` | Calculates GPP and ER using three K600 approaches, compares their physiological signs and retained observations, and uses the fixed literature value K600 = 6.72 for the final GPP, ER and NEP figures and mixed-effects models. The corrected Mesocosm 9 dataset is incorporated here. |
| `DIC_analysis.Rmd` | Analyses carbonate-derived dissolved inorganic carbon (DIC), including ERW functional-form selection, mixed-effects models, date-specific models and predictions. |
| `DOC_analysis.Rmd` | Analyses dissolved organic carbon (DOC), compares raw and log1p ERW forms, tests the water-type interaction and reports the selected mixed-effects model. |
| `particulate_carbon_analysis.Rmd` | Analyses benthic and pelagic particulate organic carbon (POC) and particulate inorganic carbon (PIC), including overall and date-specific models. |
| `carbon_overview_first_week.R` | Combines DIC, DOC, benthic POC/PIC and pelagic POC/PIC into a two-panel carbon-pool overview figure. |

## Input data

| File | Contents |
|---|---|
| `combined_do_light_data.csv` | Dissolved oxygen, temperature, light and mesocosm information used for stream-metabolism calculations. |
| `Meso_9_clean.xlsx` | Corrected dissolved-oxygen and temperature records for Mesocosm 9. |
| `ERW_IC_results_R_ready.xlsx` | Carbonate-derived inorganic carbon measurements. |
| `ERW_DOC.xlsx` | Dissolved organic carbon measurements and experimental-design information. |
| `benthic_carbon_mass.xlsx` | Benthic POC and PIC measurements. |
| `pelagic_carbon_mass.xlsx` | Pelagic POC and PIC measurements. |

## R packages

The analyses use the following packages:

```r
install.packages(c(
  "tidyverse",
  "readxl",
  "lubridate",
  "suncalc",
  "lme4",
  "lmerTest",
  "ggeffects",
  "broom.mixed",
  "MuMIn",
  "patchwork",
  "scales",
  "DHARMa",
  "knitr",
  "janitor",
  "performance",
  "parameters",
  "emmeans",
  "writexl"
))
```

Packages only need to be installed once. The scripts load the required packages at the beginning of each analysis.

## Running the analyses

1. Download or clone the complete repository. Keep the `code/` and `data/` folders in their current relative positions.
2. Open the required file from the `code/` folder in RStudio.
3. Knit each `.Rmd` file or run its code from top to bottom.
4. Run `05_carbon_pool_overview.R` after checking that all four carbon data files are available.
5. Generated figures and tables will be written to subfolders within `outputs/`.

Recommended order:

```text
stream_metabolism_analysis.Rmd
DIC_analysis.Rmd
DOC_analysis.Rmd
particulate_carbon_analysis.Rmd
carbon_overview_first_week.R
```

The scripts use paths such as `../data/filename.xlsx`, assuming that they are run from the `code/` directory.

## Author

Xinlin Ni

