# devtools::install_github("lapop-central/lapop")
#install.packages("dplyr")

library(lapop)
library(dplyr) # common package used for dataset manipulation (e.g., recoding)

lapop_fonts() # load this every time to get LAPOP-standard founds

ym23 <- lpr_data("C:/Users/plutowl/Box/LAPOP Shared/2_Projects/2023 AB/Core_Regional/Data Processing/YM/Merge 2023 LAPOP AmericasBarometer (v1.0s).dta")
gm23 <- lpr_data("C:/Users/plutowl/Box/LAPOP Shared/2_Projects/2023 AB/Core_Regional/Data Processing/GM/Grand Merge 2004-2023 LAPOP AmericasBarometer (v1.0s).dta")

# I'm recreating figures from Regional Report (2023):
# https://www.vanderbilt.edu/lapop/ab2023/AB2023-Pulse-of-Democracy-final-20240604.pdf

gm <- gm23 %>%
  filter(!(pais %in% c(16, 25, 26, 27, 28, 30, 40, 41)))
ym <- ym23 %>%
  filter(!(pais %in% c(26, 40, 41)))

# to rescale variables and/or reverse the labels, use lpr_resc
gm$variables$aoj11r <- lpr_resc(gm$variables$aoj11, reverse = TRUE, map = TRUE)


# ts - fig 1.1
fig1.1_data <- lpr_ts(gm,
                 outcome = "ing4",
                 rec = c(5, 7),
                 use_wave = TRUE)

fig1.1 <- lapop_ts(fig1.1_data,
                   ymin = 50,
                   ymax = 80,
                   main_title = "Support for democracy decline a decade ago and remains comparatively low",
                   subtitle = "% who support democracy")


# cc - fig 1.2
fig1.2_data <- lpr_cc(ym,
                      outcome = "ing4",
                      rec = c(5, 7))

fig1.2 <- lapop_cc(fig1.2_data,
                   main_title = "In many countries, only about one in two adults support democracy",
                   subtitle = "% who support democracy")

# mline
# No example of this in the regional report, but let's say we wanted to see
# trust in the judicial system across time, broken down by crime victims vs. non-victims
mline_data <- lpr_mline(gm,
                      outcome = "aoj11",
                      xvar = "vic1ext",
                      rec = c(1, 2))

mline_fig <- lapop_mline(mline_data)


#mline can also be used to show multiple outcome variables across time
# for example, fig 2.1 trust in various institutions
fig2.1_data <- lpr_mline(gm,
                            outcome = c("b13", "b21", "b31"),
                         rec = c(5, 7),
                         rec2 = c(5, 7),
                         rec3 = c(5, 7))


fig2.1 <- lapop_mline(fig2.1_data,
            main_title = "Trust in executives has declined to a level similar to other political institutions",
            subtitle = "% who trust...")

#ccm - fig 2.3
fig2.3_data = lpr_ccm(ym,
                      outcome_vars = c("b12", "b18"),
                      rec1 = c(5, 7),
                      rec2 = c(5, 7))

fig2.3_data$var <- ifelse(fig2.3_data$var == "b12", "Armed Forces", "National Police")

lapop_ccm(fig2.3_data,
          main_title = "The public typically reports more trust in the armed forces than the police, but levels vary",
          subtitle = "% who trust...")

# mover - figure spotlight satisfaction with democracy (pg. 30)
# first we should recode the variables
ym$variables <- ym$variables %>%
  mutate(edrer = case_when(
    edre <= 2 ~ "None/Primary",
    edre == 3 | edre == 4 ~ "Secondary",
    edre > 4 ~ "Superior",
    TRUE ~ edre
  ))

ym$variables <- ym$variables %>%
  mutate(q1tc_r = case_when(
    q1tc_r == 3 ~ NA,
    TRUE ~ q1tc_r
  ))

#one way to change variable labels... change the label name in the dataset
attributes(ym$variables$wealth)$label <- "Wealth"


fig2.3_data <- lpr_mover(ym,
                        outcome = "pn4",
                        grouping_vars = c("q1tc_r", "edad", "edrer", "wealth"),
                        rec = c(1, 2))

#another way to change variable labels when you want to change it just for one figure
# Adjust the name in the dataframe created by lpr_
fig2.3_data$varlabel <- ifelse(fig2.3_data$varlabel == "edrer", "Education", fig2.3_data$varlabel)


fig2.3 <- lapop_mover(fig2.3_data,
            main_title = "Satisfaction with democracy is significantly lower among women, 26-45-year-olds,
            \nthose with higher educational attainment, and the middle class",
            subtitle = "% who are satisfied with democracy")

# hist - spotlight "Citizens’ Views" p. 32
spot32_data <- lpr_hist(ym,
                        outcome = "vb21n")
spot32_data$cat <- c("Vote", "Run for\noffice", "Protest", "Participate\nin local orgs.",
                     "Other", "Change is\nimpossible")

spot32 <- lapop_hist(spot32_data,
                     main_title = "On average in the LAC region, one in three say voting is the best way to influence change",
                     subtitle = "In what way do you believe you can have the most influence to change things in the country?")

# dumb - fig 3.5
fig3.5_data <- lpr_dumb(gm23,
                      outcome = "q14f",
                      rec = c(1, 1),
                      over = c(2018, 2023),
                      xvar = "pais_lab",
                      ttest = TRUE)


fig3.5 <- lapop_dumb(fig3.5_data,
                    main_title = "Among those with emigration intentions, the percentage who say they are very likely to\n
                    emigrate increased in Nicaragua and Guatemala",
                     subtitle = "% who say it is very likely they will emigrate")


#stack
# no example of this in the help file, but say we wanted to see perceptions
# of electoral integrity (COUNTFAIR*) in 2023
stack_data <- lpr_stack(ym,
                        outcome = c("countfair1", "countfair3"))

stack_ex <- lapop_stack(stack_data,
                        main_title = "Most in the LAC region have doubts about electoral integrity")


# stack - figure 3.8
# you can also use stack_ to show one variable broken down by a second, using "by"
# for simplicity, I'm not actually making the migration index from 3.8, just
# showing migration likelihood (q14f)
fig3.8_data <- lpr_stack(ym,
                        outcome = "q14f",
                        by = "pais",
                        order = 'hi-lo')


fig3.8 <- lapop_stack(fig3.8_data,
            main_title = "Nicaragua has the highest percentage of individuals with emigration intentions who also\nhave a high level of readiness to leave, while Haiti has the lowest")
