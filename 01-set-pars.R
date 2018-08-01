
# load packages 
library(tidyverse)
library(magrittr)

# set simulation parameters and store in a list
sim_pars_list <- list(
  max_periods = 3,  # must be <= 50; number of repeated-observation periods possible (i.e., years)
  n_groups = 50,  # must be <= 50; number of cases (i.e., states)
  var = paste0("x", 1),
  p_min = seq(0.01, 0.10, length.out = 25),  # probability of event when x = min(x)
  p_max = seq(0.01, 0.50, length.out = 25), #seq(0.4, 0.6, length.out = 25),  # probability of event when x = max(x)
  n_sims = 500  # number of monte carlo simulatios
)

# create a data frame with all possible combinations of parameters
pars_df <- expand.grid(sim_pars_list) %>%
  # drop combinations where p_min > p_max
  filter(p_min <= p_max) %>% 
  # change var from factor to character
  mutate(var = as.character(var)) %>%
  glimpse()

# randomly select combinations
pars_df %<>% 
  sample_n(size = 10) %>%
  glimpse()

# save list
write_rds(pars_df, "out/pars.rds")



