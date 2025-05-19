## ----setup, include=FALSE-----------------------------------------------------
knitr::opts_chunk$set(echo = TRUE, message = FALSE, warning = FALSE)
knitr::opts_chunk$set(fig.width=8, fig.height=5)

## ----packages-----------------------------------------------------------------
library(lapop)
library(dplyr)

## ----load data----------------------------------------------------------------
# Grand Merge (only a subset of countries)
data(gm23)

# 2023 Year Merge (only a subset of countries)
data(ym23)

## ----rescale------------------------------------------------------------------
ym23$variables$d4r <- lpr_resc(ym23$variables$d4, reverse = TRUE, map = TRUE)

## ----lapop fonts--------------------------------------------------------------
lapop_fonts()

## ----time series--------------------------------------------------------------
fig1.1_data <- lpr_ts(gm23, outcome = "ing4", rec = c(5, 7), use_wave = TRUE)
lapop_ts(fig1.1_data,
         ymin = 50,
         ymax = 80,
         main_title = "Support for democracy decline a decade ago and remains comparatively low",
         subtitle = "% who support democracy")

## ----cross country------------------------------------------------------------
fig1.2_data <- lpr_cc(ym23, outcome = "ing4", rec = c(5, 7))
lapop_cc(fig1.2_data,
         main_title = "In many countries, only about one in two adults support democracy",
         subtitle = "% who support democracy")

## ----mline--------------------------------------------------------------------
fig2.1_data <- lpr_mline(gm23,
                         outcome = c("b13", "b21", "b31"),
                         rec = c(5, 7), rec2 = c(5, 7), rec3 = c(5, 7))
lapop_mline(fig2.1_data,
            main_title = "Trust in executives has declined to a level similar to other political institutions",
            subtitle = "% who trust...")

## ----ccm----------------------------------------------------------------------
fig2.3_data <- lpr_ccm(ym23,
                       outcome_vars = c("b12", "b18"),
                       rec1 = c(5, 7),
                       rec2 = c(5, 7))
fig2.3_data$var <- ifelse(fig2.3_data$var == "b12", "Armed Forces", "National Police")
lapop_ccm(fig2.3_data,
          main_title = "The public typically reports more trust in the armed forces than the police, but levels vary",
          subtitle = "% who trust...")

## ----mover--------------------------------------------------------------------
ym23$variables <- ym23$variables %>%
  mutate(edrer = case_when(
    edre <= 2 ~ "None/Primary",
    edre %in% c(3, 4) ~ "Secondary",
    edre > 4 ~ "Superior",
    TRUE ~ NA_character_
  ),
  q1tc_r = ifelse(q1tc_r == 3, NA, q1tc_r)) %>%
  mutate(q1tc_r = case_when(
    q1tc_r == 1 ~ "Men",
    q1tc_r == 2 ~ "Women",
     TRUE ~ NA_character_
  ))

attributes(ym23$variables$wealth)$label <- "Wealth"

fig_mover <- lpr_mover(ym23,
                       outcome = "pn4",
                       grouping_vars = c("q1tc_r", "edrer", "wealth"),
                       rec = c(1, 2))

fig_mover$varlabel <- ifelse(fig_mover$varlabel == "edrer", "Education", fig_mover$varlabel)

lapop_mover(fig_mover,
            main_title = "Satisfaction with democracy is significantly lower among women, 26–45-year-olds,\nthose with higher educational attainment, and the middle class",
            subtitle = "% who are satisfied with democracy")

## ----histogram----------------------------------------------------------------
spot32_data <- lpr_hist(ym23, outcome = "vb21n")
spot32_data$cat <- c("Vote", "Run for\noffice", "Protest", "Participate\nin local orgs.",
                     "Other", "Change is\nimpossible")

lapop_hist(spot32_data,
           main_title = "On average in the LAC region, one in three say voting is the best way to influence change",
           subtitle = "How do you believe you can best influence change?")

## ----dumbell------------------------------------------------------------------
fig3.5_data <- lpr_dumb(gm23,
                        outcome = "q14f",
                        rec = c(1, 1),
                        over = c(2018, 2023),
                        xvar = "pais_lab",
                        ttest = TRUE)
fig3.5_data <- fig3.5_data[1:6, ]

lapop_dumb(fig3.5_data,
           main_title = "Among those with emigration intentions, the percentage who say they are very likely\nto emigrate increased in Nicaragua and Guatemala",
           subtitle = "% who say it is very likely they will emigrate")

## ----stack--------------------------------------------------------------------
fig3.8_data <- lpr_stack(ym23,
                         outcome = "q14f",
                         xvar = "pais",
                         order = "hi-lo")

lapop_stack(fig3.8_data,
            xvar = "xvar_label",
            source = ", AmericasBarometer 2023",
            main_title = "Nicaragua has the highest percentage of individuals with migration likelihood,\nwhile Haiti has the lowest")

