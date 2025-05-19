## ----setup, include=FALSE-----------------------------------------------------
#knitr::opts_chunk$set(echo = TRUE, message = FALSE, warning = FALSE)

## ----packages-----------------------------------------------------------------
library(lapop)
library(dplyr)

## ----filter data, evaluate=F, include=F---------------------------------------
ym23 <- lpr_data("C:/Users/rob/Box/LAPOP Shared/2_Projects/2023 AB/Core_Regional/Data Processing/YM/Merge 2023 LAPOP AmericasBarometer (v1.0s).dta") # year-merge
gm23 <- lpr_data("C:/Users/rob/Box/LAPOP Shared/2_Projects/2023 AB/Core_Regional/Data Processing/GM/Grand Merge 2004-2023 LAPOP AmericasBarometer (v1.1s).dta") # grand-merge v1.1 wealth variable fix

## Filter Countries and Variables
gm <- gm23 %>% filter(!(pais %in% c(16, 25, 26, 27, 28, 30, 40, 41)))
gm <- gm %>% select("aoj11", "ing4", "b13", "b21", "b31", "b12", "wave", "pais_lab", "pais",
                    "year", "b18", "pn4", "edre", "wealth", "q1tc_r", "vb21n", "q14f")
#saveRDS(gm, file=paste0(Sys.getenv("HOME"), "\\GitHub\\lapop\\data\\gm23.RDS"))
save(gm, file=paste0(Sys.getenv("HOME"), "\\GitHub\\lapop\\data\\gm23.rda"))


ym <- ym23 %>% filter(!(pais %in% c(26, 40, 41)))
ym <- ym %>% select("aoj11", "ing4", "b13", "b21", "b31", "b12", "wave", "pais_lab", "pais",
                    "year", "b18", "pn4", "edre", "wealth", "q1tc_r", "vb21n", "q14f")
#saveRDS(ym, file=paste0(Sys.getenv("HOME"), "\\GitHub\\lapop\\data\\ym23.RDS"))
save(ym, file=paste0(Sys.getenv("HOME"), "\\GitHub\\lapop\\data\\ym23.rda"))

## ----load data, evaluate=F, include=F-----------------------------------------
#gm23 <- readRDS(paste0(Sys.getenv("HOME"), "\\GitHub\\lapop\\data\\gm23.RDS"))
#ym23 <- readRDS(paste0(Sys.getenv("HOME"), "\\GitHub\\lapop\\data\\ym23.RDS"))

