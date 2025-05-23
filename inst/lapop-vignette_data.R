## ----setup, include=FALSE-----------------------------------------------------
#knitr::opts_chunk$set(echo = TRUE, message = FALSE, warning = FALSE)

## ----packages-----------------------------------------------------------------
library(lapop)
library(dplyr)

## ----filter data, evaluate=F, include=F---------------------------------------

# GRAND-MERGE
# # -----------------------------------------------------------------------
#gm <- lpr_data("C:/Users/rob/Box/LAPOP Shared/2_Projects/2023 AB/Core_Regional/Data Processing/GM/Grand Merge 2004-2023 LAPOP AmericasBarometer (v1.1s).dta") # grand-merge v1.1 wealth variable fix

# Filter Countries and Variables
#gm23 <- gm %>% filter(!(pais %in% c(16, 25, 26, 27, 28, 30, 40, 41)))
#gm23 <- gm23 %>% select("aoj11", "ing4", "b13", "b21", "b31", "b12", "q14f",
#                        "wave", "pais_lab", "pais", "year")

#qs::qsave(gm23, paste0(Sys.getenv("HOME"), "\\GitHub\\lapop\\data\\gm23.qs", preset = "high"))

#saveRDS(gm, file=paste0(Sys.getenv("HOME"), "\\GitHub\\lapop\\data\\gm23.rds"))
#save(gm23, file=paste0(Sys.getenv("HOME"), "\\GitHub\\lapop\\data\\gm23.rda"))


# YEAR-MERGE
# # -----------------------------------------------------------------------
ym <- lpr_data("C:/Users/rob/Box/LAPOP Shared/2_Projects/2023 AB/Core_Regional/Data Processing/YM/Merge 2023 LAPOP AmericasBarometer (v1.0s).dta") # year-merge
ym23 <- ym %>% filter(!(pais %in% c(26, 40, 41)))
ym23 <- ym23 %>% select("wave", "pais_lab", "pais", "year",
                        "ing4", "b12", "b18", "pn4", "vb21n", "q14f", "d4",
                        "edre", "wealth", "q1tc_r")

#saveRDS(ym, file=paste0(Sys.getenv("HOME"), "\\GitHub\\lapop\\data\\ym23.rds"))
save(ym23, file=paste0(Sys.getenv("HOME"), "\\GitHub\\lapop\\data\\ym23.rda"))

# COUNTRY-MERGE
# # -----------------------------------------------------------------------
cm <- readstata13::read.dta13("C:/Users/rob/Box/LAPOP Shared/2_Projects/2023 AB/BRA/Data Processing/BRA merge 2007-2023 LAPOP AmericasBarometer (v1.0s).dta",
                              generate.factors = T)
cm23 <- cm %>% select("aoj11", "ing4", "b13", "b21", "b31", "b12",
                        "wave", "pais", "year")

save(cm23, file=paste0(Sys.getenv("HOME"), "\\GitHub\\lapop\\data\\cm23.rda"))

## ----load data, evaluate=F, include=F-----------------------------------------

# COMPRESS TO XZ FOR BEST FILESIZE
tools::resaveRdaFiles("data/", compress = "xz")
tools::checkRdaFiles("data/")

#gm23 <- load(paste0(Sys.getenv("HOME"), "\\GitHub\\lapop\\data\\gm23.RDS"))
#ym23 <- load(paste0(Sys.getenv("HOME"), "\\GitHub\\lapop\\data\\ym23.RDS"))
#cm23 <- load(paste0(Sys.getenv("HOME"), "\\GitHub\\lapop\\data\\cm23.RDS"))
#rm(list=ls()); gc()
