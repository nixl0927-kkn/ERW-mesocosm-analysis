# ERW Mesocosm Analysis

This repository contains the R code used to analyse carbon cycling and stream metabolism in an enhanced rock weathering (ERW) mesocosm experiment.

The experiment investigated how different ERW application rates (0, 5, 10, 20, 50 and 100 t ha⁻¹) influenced freshwater carbon dynamics under groundwater and river water conditions. The analyses include stream metabolism (GPP, ER and NEP), dissolved inorganic carbon (DIC), dissolved organic carbon (DOC), benthic and pelagic particulate carbon pools, and an overview of measured carbon components.

The associated experimental dataset is not included in this repository because it is part of an unpublished research project. Data availability will be updated following publication. For reasonable requests regarding data access, please contact:

**Xinlin Ni**
Email: [niiixl0927@gmail.com](mailto:niiixl0927@gmail.com)

## Repository structure

```text
ERW-mesocosm-analysis/
├── code/
│   ├── stream_metabolism_analysis.Rmd
│   ├── DIC_analysis.Rmd
│   ├── DOC_analysis.Rmd
│   ├── particulate_carbon_analysis.Rmd
│   └── carbon_overview_first_week.R
├── outputs/
└── README.md
```

The `outputs/` directory is created automatically by the analysis scripts and contains exported figures, tables and model results.

## Analysis scripts

| Script                            | Description                                                                                                                                                       |
| --------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `stream_metabolism_analysis.Rmd`  | Calculates GPP and ER using dissolved oxygen and light measurements, applies the selected K600 approach, and performs mixed-effects modelling of GPP, ER and NEP. |
| `DIC_analysis.Rmd`                | Analyses dissolved inorganic carbon responses to ERW treatments, including model selection and mixed-effects modelling.                                           |
| `DOC_analysis.Rmd`                | Analyses dissolved organic carbon responses to ERW treatments and water-source effects.                                                                           |
| `particulate_carbon_analysis.Rmd` | Analyses benthic and pelagic particulate organic carbon (POC) and particulate inorganic carbon (PIC).                                                             |
| `carbon_overview_first_week.R`    | Combines different carbon pools into an overview figure of carbon dynamics during the experiment.                                                                 |

## Data availability

Raw and processed experimental data are not provided in this repository because they are associated with an ongoing, unpublished research project.

The analysis scripts require the corresponding datasets to reproduce the results. Data access may be considered upon reasonable request after appropriate review.

## R packages

The analyses use the following R packages:

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

Packages only need to be installed once. Each script loads the required packages at the beginning of the analysis.

## Running the analyses

1. Clone or download this repository.
2. Open the required script from the `code/` directory in RStudio.
3. Provide access to the corresponding datasets in the expected file locations.
4. Run each `.Rmd` file from top to bottom to reproduce the analyses and generate figures/tables.

Recommended order:

```text
stream_metabolism_analysis.Rmd
DIC_analysis.Rmd
DOC_analysis.Rmd
particulate_carbon_analysis.Rmd
carbon_overview_first_week.R
```

## Author

Xinlin Ni


