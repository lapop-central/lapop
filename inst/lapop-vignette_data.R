## ----setup, include=FALSE-----------------------------------------------------
#knitr::opts_chunk$set(echo = TRUE, message = FALSE, warning = FALSE)
rm(list=ls()); gc()
## ----packages-----------------------------------------------------------------
library(lapop)
library(dplyr)

## ----filter data, evaluate=F, include=F---------------------------------------

# # -----------------------------------------------------------------------
# GRAND-MERGE (TOO LARGE FOR R PACKAGE)
# # -----------------------------------------------------------------------
#gm <- lpr_data("C:/Users/rob/Box/LAPOP Shared/2_Projects/2023 AB/Core_Regional/Data Processing/GM/Grand Merge 2004-2023 LAPOP AmericasBarometer (v1.1s).dta") # grand-merge v1.1 wealth variable fix

# Filter Countries and Variables
#gm23 <- gm %>% filter(!(pais %in% c(16, 25, 26, 27, 28, 30, 40, 41)))
#gm23 <- gm23 %>% select("aoj11", "ing4", "b13", "b21", "b31", "b12", "q14f",
#                        "wave", "pais_lab", "pais", "year")

#qs::qsave(gm23, paste0(Sys.getenv("HOME"), "\\GitHub\\lapop\\data\\gm23.qs", preset = "high"))

#saveRDS(gm, file=paste0(Sys.getenv("HOME"), "\\GitHub\\lapop\\data\\gm23.rds"))
#save(gm23, file=paste0(Sys.getenv("HOME"), "\\GitHub\\lapop\\data\\gm23.rda"))

# # -----------------------------------------------------------------------
# BRAZIL SINGLE-COUNTRY SINGLE-YEAR MERGE
# # -----------------------------------------------------------------------
bra <- readstata13::read.dta13("C:/Users/rob/Box/LAPOP Shared/2_Projects/2023 AB/BRA/Data Processing/BRA merge 2007-2023 LAPOP AmericasBarometer (v1.0s).dta",
                               generate.factors = TRUE)
bra23 <- bra %>% select("aoj11", "ing4", "b13", "b21", "b31", "b12",
                        "wave", "pais", "year", "upm", "strata", "wt") %>%
                                                        filter(wave==2023)
#ra23<-lpr_data(bra23, wt = TRUE)

bra23

# rda
save(bra23, file=paste0(Sys.getenv("HOME"), "\\GitHub\\lapop\\data\\bra23.rda"))
# dta
readstata13::save.dta13(bra23, file = "~/GitHub/lapop/data/bra23.dta",
                        convert.factors = "label")

# # -----------------------------------------------------------------------
# BRAZIL SINGLE-COUNTRY MULTI-YEAR MERGE
# # -----------------------------------------------------------------------
cm <- readstata13::read.dta13("C:/Users/rob/Box/LAPOP Shared/2_Projects/2023 AB/BRA/Data Processing/BRA merge 2007-2023 LAPOP AmericasBarometer (v1.0s).dta",
                              generate.factors = TRUE)
cm23 <- cm %>% select("aoj11", "ing4", "b13", "b21", "b31", "b12",
                        "wave", "pais", "year", "upm", "strata", "wt", "weight1500")

cm23<-lpr_data(cm23)

cm23

# rda
save(cm23, file=paste0(Sys.getenv("HOME"), "\\GitHub\\lapop\\data\\cm23.rda"))
# dta
readstata13::save.dta13(cm23, file = "~/GitHub/lapop/data/cm23.dta",
                        convert.factors = "label")

# # -----------------------------------------------------------------------
# MULTI-COUNTRY SINGLE-YEAR AB 2023 MERGE
# # -----------------------------------------------------------------------
ym <- readstata13::read.dta13("C:/Users/rob/Box/LAPOP Shared/2_Projects/2023 AB/Core_Regional/Data Processing/YM/Merge 2023 LAPOP AmericasBarometer (v1.0s).dta",
               generate.factors = TRUE) # year-merge
ym23 <- ym %>% filter(!(pais %in% c(26, 40, 41))) # Excluding
ym23 <- ym23 %>% select("wave", "pais", "year",
                        "ing4", "b12", "b18", "pn4", "vb21n", "q14f", "d4",
                        "edre", "wealth", "q1tc_r", "upm", "strata", "weight1500")

ym23<-lpr_data(ym23)

ym23

#rda
save(ym23, file=paste0(Sys.getenv("HOME"), "\\GitHub\\lapop\\data\\ym23.rda"))
# dta
readstata13::save.dta13(ym23, file = "~/GitHub/lapop/data/ym23.dta",
                        convert.factors = "label")

# CHECK FILES SIZE
tools::checkRdaFiles("data/")

# COMPRESS TO XZ FOR BEST FILESIZE
tools::resaveRdaFiles("data/", compress = "xz")
tools::checkRdaFiles("data/")
