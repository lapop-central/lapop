# # -----------------------------------------------------------------------
#
#
#
#
#
# # -----------------------------------------------------------------------

devtools::install_github("lapop-central/lapop", force = T) # Get latest version

library(lapop) # hellow world!
ym23 <- lpr_data("C:/Users/rob/Box/LAPOP Shared/2_Projects/2023 AB/Core_Regional/Data Processing/YM/Merge 2023 LAPOP AmericasBarometer (v1.0s).dta")
gm23 <- lpr_data("C:/Users/rob/Box/LAPOP Shared/2_Projects/2023 AB/Core_Regional/Data Processing/GM/Grand Merge 2004-2023 LAPOP AmericasBarometer (v1.1s).dta") # v1.1 wealth variable fix

# In this guide, we will recreate figures from the AB Report Pulse of Democracy (2023):
# browseURL("https://www.vanderbilt.edu/lapop/ab2023/AB2023-Pulse-of-Democracy-final-20240604.pdf")

# Filtering countries
# # -----------------------------------------------------------------------
require(dplyr)
gm <- gm23 %>%
  filter(!(pais %in% c(16, 25, 26, 27, 28, 30, 40, 41))) # ! negation operator
ym <- ym23 %>%
  filter(!(pais %in% c(26, 40, 41)))

# Rescale variables and/or reverse the labels
### lpr_resc()
gm$variables$aoj11r <- lpr_resc(gm$variables$aoj11, reverse = TRUE, map = TRUE)

# Wrangling and plotting figures
# # -----------------------------------------------------------------------

# First, run the function to get LAPOP Lab standard fonts
lapop_fonts()

# TIME SERIES - Figure 1.1 lpr_ts()
fig1.1_data <- lpr_ts(gm,
                 outcome = "ing4",
                 rec = c(5, 7),
                 use_wave = TRUE); print(fig1.1_data)

# lapop_ts()
fig1.1 <- lapop_ts(fig1.1_data,
                   ymin = 50,
                   ymax = 80,
                   main_title = "Support for democracy decline a decade ago and remains comparatively low",
                   subtitle = "% who support democracy"); fig1.1

# CROSS-COUNTRY - fig 1.2 lpr_cc()
fig1.2_data <- lpr_cc(ym,
                      outcome = "ing4",
                      rec = c(5, 7)); fig1.2_data

# lapop_cc()
fig1.2 <- lapop_cc(fig1.2_data,
                   main_title = "In many countries, only about one in two adults support democracy",
                   subtitle = "% who support democracy"); fig1.2


# MLINE - fig 2.1 trust in various institutions lpr_mline()
# lpr_mline() can also be used to show multiple outcome variables across time
fig2.1_data <- lpr_mline(gm,
                            outcome = c("b13", "b21", "b31"),
                         rec = c(5, 7),
                         rec2 = c(5, 7),
                         rec3 = c(5, 7)); fig2.1_data

fig2.1 <- lapop_mline(fig2.1_data,
            main_title = "Trust in executives has declined to a level similar to other political institutions",
            subtitle = "% who trust..."); fig2.1

# LABELS RETURNING IN SPANISH, NEED TO CHANGE LABEL LANGUAGE ACCORDING TO LANG

# No example of this in the report, but let's say we are interested in
# trust in the judicial system (aoj11) across time, roken down by
# crime victims vs. non-victims (vic1ext)
mline_data <- lpr_mline(gm,
                        outcome = "aoj11",
                        xvar = "vic1ext",
                        rec = c(1, 2)); print(mline_data)

mline_fig <- lapop_mline(mline_data,
                         main_title = "A minority trust the judicial system in Latin America",
                         subtitle = "% who trust the judicial system"); mline_fig


# CC with Multiple Variables - fig 2.3 lpr_ccm()
fig2.3_data = lpr_ccm(ym,
                      outcome_vars = c("b12", "b18"),
                      rec1 = c(5, 7),
                      rec2 = c(5, 7)); print(fig2.3_data)

### LPR_CCM TAKE VARIABLE LABEL INSTEAD OF VARIABLE CODE
########################################## TBDDDDDDDDDDDDD

# Recode to char labels
fig2.3_data$var <- ifelse(fig2.3_data$var == "b12", "Armed Forces", "National Police")

fig2.3<-lapop_ccm(fig2.3_data,
          main_title = "The public typically reports more trust in the armed forces than the police, but levels vary",
          subtitle = "% who trust..."); fig2.3_data

# Mover - figure spotlight satisfaction with democracy (p.30) aka 'broken down'

# First we need to recode the variables
ym$variables <- ym$variables %>%
  mutate(edrer = case_when(
    edre <= 2 ~ "None/Primary",
    edre == 3 | edre == 4 ~ "Secondary",
    edre > 4 ~ "Superior",
    TRUE ~ NA_character_
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
                        rec = c(1, 2)); fig2.3_data

# Adjust the name in the dataframe created by lpr when you want to change it just for one fig only
fig2.3_data$varlabel <- ifelse(fig2.3_data$varlabel == "edrer",
                               "Education", fig2.3_data$varlabel)

fig2.3 <- lapop_mover(fig2.3_data,
            main_title = "Satisfaction with democracy is significantly lower among women, 26-45-year-olds,
            \nthose with higher educational attainment, and the middle class",
            subtitle = "% who are satisfied with democracy"); fig2.3

# Histogram - spotlight "Citizens’ Views" p. 32 lpr_hist()
spot32_data <- lpr_hist(ym,
                        outcome = "vb21n"); spot32_data

spot32_data$cat <- c("Vote", "Run for\noffice", "Protest", "Participate\nin local orgs.",
                     "Other", "Change is\nimpossible")

spot32 <- lapop_hist(spot32_data,
                     main_title = "On average in the LAC region, one in three say voting is the best way to influence change",
                     subtitle = "In what way do you believe you can have the most influence to change things in the country?"); spot32

# Dumbell - fig 3.5 lpr_dumb()
fig3.5_data <- lpr_dumb(gm23,
                      outcome = "q14f",
                      rec = c(1, 1),
                      over = c(2018, 2023),
                      xvar = "pais_lab",
                      ttest = TRUE); fig3.5_data

fig3.5_data<-fig3.5_data[1:6,]


fig3.5 <- lapop_dumb(fig3.5_data,
                    main_title = "Among those with emigration intentions, the percentage who say they are very likely \nto emigrate increased in Nicaragua and Guatemala",
                     subtitle = "% who say it is very likely they will emigrate"); fig3.5


# Stack lpr_Stack()
# no example of this in the help file, but say we wanted to see perceptions
# of electoral integrity (COUNTFAIR*) in 2023
stack_data <- lpr_stack(ym,
                        outcome = c("countfair1", "countfair3")); stack_data

stack_ex <- lapop_stack(stack_data,
                        main_title = "Most in the LAC region have doubts about electoral integrity"); stack_ex


# stack - figure 3.8
# you can also use stack_ to show one variable broken down by a second, using "by"
# for simplicity, I'm not actually making the migration index from 3.8, just
# showing migration likelihood (q14f)

CONTINUE HERE CONTINUE HERE CONTINUE HERE CONTINUE HERE CONTINUE HERE CONTINUE HERE

fig3.8_data <- lpr_stack(ym,
                        outcome = "q14f",
                        #by = "pais",
                        order = 'hi-lo'); fig3.8_data

fig3.8 <- lapop_stack(fig3.8_data,
            main_title = "Nicaragua has the highest percentage of individuals with emigration intentions who also\nhave a high level of readiness to leave, while Haiti has the lowest"); fig3.8
