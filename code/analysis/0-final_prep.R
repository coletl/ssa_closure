## -----------------------------------
rm(list = ls())


## ----sub setup, include=FALSE-------
knitr::opts_chunk$set(echo = TRUE, fig.width = 7, fig.height = 5)
knitr::opts_knit$set(root.dir = rprojroot::find_rstudio_root_file())


## -----------------------------------
cutoff <- 
  function(x, threshold = 0.5, levels = 0:1) 
    factor(as.numeric(as.character(x) > threshold), levels = levels)



## -----------------------------------
demog <- readRDS("data/demograph_service.rds") %>% as.data.table() 
closure <- readRDS("data/office_closures.rds") %>% as.data.table()


## -----------------------------------
offices <- merge(closure, demog, all = TRUE, by = c("office", "year"))


## -----------------------------------
offcompl <- offices[complete.cases(offices)]

offcompl[ , .(closures = sum(closed), 
              still_open = .N - sum(closed)),
          by = year]


## -----------------------------------
offcompl$closed <- as.factor(offcompl$closed)


## -----------------------------------
offcompl <- offcompl[year %in% as.character(2000:2014)]


## -----------------------------------
absolute <- offcompl

vars_absolute <- 
  c("white", "black", "english_imp", "income", "income_publass",
    "income_ss", "poverty", "seniors", "educ_hsgrad", 
    "pop",
    
    "total_comp17", "no_comp17", "total_internet17",
    
    "area", "nn_dist", "num_tracts"
    )


## -----------------------------------
if(offcompl[ , cor(income_ss, income_publass) > 0.95])
  
  vars_absolute <- setdiff(vars_absolute, "income_publass")

form_absolute <- reformulate(termlabels = vars_absolute, response = "closed")


## -----------------------------------
percap <- copy(offcompl)


# Variables not to divide by population
vars_nopc <- c("pop", "nn_dist", "prop_area", "prop_num_tracts")


set_cols(percap, j = setdiff(vars_absolute, vars_nopc), 
         FUN = function(x) x / percap[["pop"]])

setnames(percap, 
         setdiff(vars_absolute, vars_nopc), 
         paste0("prop_", setdiff(vars_absolute, vars_nopc)))


## -----------------------------------
vars_percap <- paste0("prop_", setdiff(vars_absolute, vars_nopc)) %>%
  c("pop")

form_percap <- reformulate(termlabels = vars_percap, response = "closed")


## -----------------------------------
percap <- percap[pop > 0]


## -----------------------------------
set_cols(absolute, j = vars_absolute, FUN = scale)

