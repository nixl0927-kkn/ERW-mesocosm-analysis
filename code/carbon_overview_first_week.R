# ============================================================
# Carbon-pool overview on 22 May 2025 — final version
# Two panels (Groundwater / River water), x = ERW dose,
# y = carbon concentration, colour = carbon pool.
# ============================================================

# 1. Packages ------------------------------------------------

library(tidyverse)
library(readxl)
library(janitor)
library(patchwork)
library(scales)

options(contrasts = c("contr.treatment", "contr.poly"))


# 2. General settings ----------------------------------------

DIC_DATE <- as.Date("2025-05-21")
OTHER_CARBON_DATE <- as.Date("2025-05-22")

ERW_LEVELS <- c(0, 5, 10, 20, 50, 100)

WATER_LEVELS <- c("Ground", "River")

WATER_LABELS <- c(
  "Ground" = "Groundwater",
  "River"  = "River water"
)

CARBON_POOL_LEVELS <- c(
  "DIC",
  "DOC",
  "Benthic POC",
  "Pelagic POC",
  "Benthic PIC",
  "Pelagic PIC"
)

# Colour scheme matches the daily NEP figure (viridis "plasma")
# for visual consistency across figures in the thesis.


# 3. Locate data files ----------------------------------------

IC_FILE <- "../data/ERW_IC_results_R_ready.xlsx"

DOC_FILE <- "../data/ERW_DOC.xlsx"

BENTHIC_FILE <- "../data/benthic_carbon_mass.xlsx"

PELAGIC_FILE <- "../data/pelagic_carbon_mass.xlsx"

input_files <- c(
  IC_FILE,
  DOC_FILE,
  BENTHIC_FILE,
  PELAGIC_FILE
)

if (any(!file.exists(input_files))) {
  stop(
    "Could not find: ",
    paste(input_files[!file.exists(input_files)], collapse = ", ")
  )
}


# 4. Experimental design -------------------------------------

design <- tribble(
  ~Mesocosm, ~Water_type, ~ERW_level, ~volume_from_22_may_ml,
  1, "Ground",   5, 240,
  2, "Ground",  50, 240,
  3, "Ground",  10, 300,
  4, "Ground",   0, 360,
  5, "Ground",  20, 300,
  6, "Ground", 100, 300,
  
  7, "River",   10, 300,
  8, "River",   20, 300,
  9, "River",    0, 240,
  10, "River",  100, 300,
  11, "River",   50, 300,
  12, "River",    5, 300,
  
  13, "River",  100, 300,
  14, "River",    0, 240,
  15, "River",    5, 300,
  16, "River",   20, 300,
  17, "River",   10, 240,
  18, "River",   50, 300,
  
  19, "Ground",  20, 300,
  20, "Ground", 100, 300,
  21, "Ground",   5, 240,
  22, "Ground",   0, 240,
  23, "Ground",  10, 300,
  24, "Ground",  50, 300,
  
  25, "Ground",   0, 300,
  26, "Ground",  50, 300,
  27, "Ground",  10, 300,
  28, "Ground", 100, 300,
  29, "Ground",  20, 300,
  30, "Ground",   5, 300,
  
  31, "River",   20, 300,
  32, "River",  100, 300,
  33, "River",    5, 240,
  34, "River",   50, 300,
  35, "River",    0, 300,
  36, "River",   10, 240
) %>%
  mutate(
    Water_type = factor(
      Water_type,
      levels = WATER_LEVELS
    ),
    ERW_level = as.numeric(ERW_level)
  )


# 5. Read and prepare DIC data --------------------------------

ic_data_22may <- read_excel(
  path = IC_FILE,
  sheet = "ic_data"
) %>%
  clean_names() %>%
  transmute(
    sample_date = as.Date(sample_date),
    Mesocosm = as.integer(mesocosm),
    Water_type = factor(
      water_type,
      levels = WATER_LEVELS
    ),
    ERW_level = as.numeric(erw_level),
    carbonate_mg_l = as.numeric(carbonate_mg_l),
    
    # Convert carbonate to carbon concentration
    value = carbonate_mg_l * (12.011 / 60.008)
  ) %>%
  filter(
    sample_date == DIC_DATE,
    !is.na(value)
  ) %>%
  mutate(
    carbon_pool = "DIC"
  ) %>%
  select(
    carbon_pool,
    Mesocosm,
    Water_type,
    ERW_level,
    value
  )


# 6. Read and prepare DOC data --------------------------------

doc_data_22may <- read_excel(
  path = DOC_FILE,
  sheet = 1,
  na = c("", "NA", "N/A", "n.a.")
) %>%
  clean_names() %>%
  transmute(
    sample_date = as.Date(date),
    Mesocosm = as.integer(mesocosm),
    Water_type = factor(
      water_type,
      levels = WATER_LEVELS
    ),
    ERW_level = as.numeric(erw_level),
    value = as.numeric(doc)
  ) %>%
  filter(
    sample_date == OTHER_CARBON_DATE,
    !is.na(value)
  ) %>%
  mutate(
    carbon_pool = "DOC"
  ) %>%
  select(
    carbon_pool,
    Mesocosm,
    Water_type,
    ERW_level,
    value
  )


# 7. Functions for particulate carbon -------------------------

read_particulate_file <- function(path, compartment) {
  
  read_excel(path) %>%
    clean_names() %>%
    transmute(
      sample_name,
      Mesocosm = as.integer(mesocosm),
      sample_date = as.Date(date),
      
      mass_carbon_whole_filter_mg = as.numeric(
        mass_of_organic_carbon_in_whole_filters_mg
      ),
      
      fraction = if_else(
        str_detect(
          str_to_upper(sample_name),
          "POC"
        ),
        "POC",
        "TC"
      ),
      
      compartment = compartment,
      
      sample_status = if_else(
        is.na(mass_carbon_whole_filter_mg),
        "missing_or_not_measured",
        "measured"
      )
    )
}


prepare_particulate_22may <- function(path, compartment) {
  
  read_particulate_file(
    path = path,
    compartment = compartment
  ) %>%
    filter(
      sample_status == "measured",
      sample_date == OTHER_CARBON_DATE
    ) %>%
    left_join(
      design,
      by = "Mesocosm"
    ) %>%
    mutate(
      # The 22 May mesocosm-specific filtration volumes
      # are used for both particulate datasets, following
      # the existing processing workflow.
      volume_ml = volume_from_22_may_ml,
      
      conc_mg_L =
        mass_carbon_whole_filter_mg /
        volume_ml * 1000
    ) %>%
    select(
      Mesocosm,
      Water_type,
      ERW_level,
      fraction,
      conc_mg_L
    ) %>%
    pivot_wider(
      names_from = fraction,
      values_from = conc_mg_L,
      names_prefix = "conc_"
    ) %>%
    mutate(
      # PIC = total carbon - organic carbon
      PIC_conc = pmax(
        conc_TC - conc_POC,
        0
      )
    )
}


# 8. Prepare benthic and pelagic datasets ---------------------

benthic_22may <- prepare_particulate_22may(
  path = BENTHIC_FILE,
  compartment = "Benthic"
)

pelagic_22may <- prepare_particulate_22may(
  path = PELAGIC_FILE,
  compartment = "Pelagic"
)


benthic_long_22may <- benthic_22may %>%
  transmute(
    Mesocosm,
    Water_type,
    ERW_level,
    `Benthic POC` = conc_POC,
    `Benthic PIC` = PIC_conc
  ) %>%
  pivot_longer(
    cols = c(
      `Benthic POC`,
      `Benthic PIC`
    ),
    names_to = "carbon_pool",
    values_to = "value"
  )


pelagic_long_22may <- pelagic_22may %>%
  transmute(
    Mesocosm,
    Water_type,
    ERW_level,
    `Pelagic POC` = conc_POC,
    `Pelagic PIC` = PIC_conc
  ) %>%
  pivot_longer(
    cols = c(
      `Pelagic POC`,
      `Pelagic PIC`
    ),
    names_to = "carbon_pool",
    values_to = "value"
  )


# 9. Combine all six carbon pools ------------------------------

carbon_overview_raw <- bind_rows(
  ic_data_22may,
  doc_data_22may,
  benthic_long_22may,
  pelagic_long_22may
) %>%
  filter(
    !is.na(value),
    !is.na(Water_type),
    !is.na(ERW_level)
  ) %>%
  mutate(
    carbon_pool = factor(
      carbon_pool,
      levels = CARBON_POOL_LEVELS
    )
  )


# 10. Calculate mean +/- SE --------------------------------------

carbon_overview_summary <- carbon_overview_raw %>%
  group_by(
    carbon_pool,
    Water_type,
    ERW_level
  ) %>%
  summarise(
    n = sum(!is.na(value)),
    mean = mean(value, na.rm = TRUE),
    sd = sd(value, na.rm = TRUE),
    se = sd / sqrt(n),
    .groups = "drop"
  )


# Optional data check
carbon_overview_summary %>%
  arrange(
    carbon_pool,
    Water_type,
    ERW_level
  ) %>%
  print(n = Inf)


# 10b. Concentration ranges for text (dissolved carbon pools) ----
# Range of treatment-level means (across both water types and all
# six ERW doses) for DIC and DOC, for reporting in the results text.

carbon_pool_ranges <- carbon_overview_summary %>%
  filter(carbon_pool %in% c("DIC", "DOC")) %>%
  group_by(carbon_pool) %>%
  summarise(
    min_mean = min(mean, na.rm = TRUE),
    max_mean = max(mean, na.rm = TRUE),
    .groups = "drop"
  )

carbon_pool_ranges

# Formatted sentence fragments, e.g. "11.3 to 15.6"
dic_range <- carbon_pool_ranges %>%
  filter(carbon_pool == "DIC")

doc_range <- carbon_pool_ranges %>%
  filter(carbon_pool == "DOC")

cat(
  sprintf(
    "DIC: %.1f to %.1f mg C L-1\n",
    dic_range$min_mean,
    dic_range$max_mean
  ),
  sprintf(
    "DOC: %.1f to %.1f mg C L-1\n",
    doc_range$min_mean,
    doc_range$max_mean
  )
)

# 10c. Concentration ranges for text (particulate carbon pools) --
# POC (benthic + pelagic combined) and PIC (benthic + pelagic
# combined) reported separately, for the "particulate organic
# carbon was higher than particulate inorganic carbon" statement.

particulate_pool_ranges <- carbon_overview_summary %>%
  filter(
    carbon_pool %in% c(
      "Benthic POC", "Pelagic POC",
      "Benthic PIC", "Pelagic PIC"
    )
  ) %>%
  mutate(
    fraction = if_else(
      str_detect(carbon_pool, "POC"),
      "POC",
      "PIC"
    )
  ) %>%
  group_by(fraction) %>%
  summarise(
    min_mean = min(mean, na.rm = TRUE),
    max_mean = max(mean, na.rm = TRUE),
    .groups = "drop"
  )

particulate_pool_ranges

poc_range <- particulate_pool_ranges %>%
  filter(fraction == "POC")

pic_range <- particulate_pool_ranges %>%
  filter(fraction == "PIC")

cat(
  sprintf(
    "POC (benthic + pelagic): %.1f to %.1f mg C L-1\n",
    poc_range$min_mean,
    poc_range$max_mean
  ),
  sprintf(
    "PIC (benthic + pelagic): %.1f to %.1f mg C L-1\n",
    pic_range$min_mean,
    pic_range$max_mean
  )
)

# 11. Plot -------------------------------------------------------
# x = ERW dose, y = carbon concentration, colour = carbon pool,
# one panel each for groundwater and river water.

POOL_COLOURS <- c(
  "DIC"          = "#4E79A7",
  "DOC"          = "#F28E2B",
  "Benthic POC"  = "#59A14F",
  "Pelagic POC"  = "#B6992D",
  "Benthic PIC"  = "#c94733",
  "Pelagic PIC"  = "#B07AA1"
)

p_overview <- ggplot(
  carbon_overview_summary,
  aes(
    x = ERW_level,
    y = mean,
    colour = carbon_pool,
    fill = carbon_pool,
    group = carbon_pool
  )
) +
  geom_errorbar(
    aes(
      ymin = pmax(mean - se, 0),
      ymax = mean + se
    ),
    width = 0.2,
    linewidth = 0.5,
    alpha = 0.6
  ) +
  geom_line(
    linewidth = 0.6
  ) +
  geom_point(
    size = 1.5
  ) +
  facet_wrap(
    ~ Water_type,
    ncol = 2,
    labeller = as_labeller(c(Ground = "(a) Ground", River = "(b) River"))
  ) +
  scale_x_continuous(
    trans = scales::transform_sqrt(),
    breaks = ERW_LEVELS
  ) +
  scale_y_sqrt(
    breaks = c(0, 1, 2, 5, 10, 15, 20)
  ) +
  scale_colour_manual(
    values = POOL_COLOURS,
    name = "Carbon pool"
  ) +
  scale_fill_manual(
    values = POOL_COLOURS,
    name = "Carbon pool"
  ) +
  labs(
    x = expression("ERW application (t ha"^{-1}*")"),
    y = expression("Carbon concentration (mg C L"^{-1}*")"),
    title = "Overview of carbon pools following ERW application",
    subtitle = paste0(
      "DIC: 21 May 2025; all other carbon pools: 22 May 2025. ",
      "Points and error bars show mean \u00B1 SE."
    )
  ) +
  theme_classic(base_size = 11) +
  theme(
    plot.title = element_text(face = "bold", hjust = 0.5, size = 14),
    plot.subtitle = element_text(hjust = 0.5, size = 10),
    strip.background = element_rect(fill = "grey95", colour = "grey70"),
    strip.text = element_text(face = "bold", hjust = 0),
    axis.text = element_text(colour = "black"),
    legend.position = "right",
    legend.title = element_text(face = "bold")
  )

p_overview


# 12. Save the figure -----------------------------------------

OUTPUT_DIR <- "../outputs/overview"

dir.create(
  OUTPUT_DIR,
  recursive = TRUE,
  showWarnings = FALSE
)

ggsave(
  filename = file.path(
    OUTPUT_DIR,
    "carbon_pool_overview_two_panel.png"
  ),
  plot = p_overview,
  width = 11,
  height = 6,
  units = "in",
  dpi = 300,
  bg = "white"
)
