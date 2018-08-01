
# load packages
library(tidyverse)
library(haven)

# load observed explanatory variables
x_raw_df <- read_dta("data/InternalDeterminants.dta") %>%
  # do a bit of aesthetic renaming
  rename(state = statename,
         year = year4dig) %>%
  select(-number) %>%
  # create integers indexing groups and time periods
  mutate(group_id = as.numeric(factor(state)),
         time_period = year - min(year) + 1) %>%
  glimpse()


# rescale each explanatory variable to range from 0 to 1
# ------------------------------------------------------
# note: this is just computationally convenient (i.e., )
# 0s and 1s are each to work with given p_min and p_max.
x_df <- x_raw_df %>%
  mutate_at(vars(starts_with("x")), funs((. - min(.))/(max(.) - min(.)))) %>%
  glimpse()

# write data frame to file
saveRDS(x_df, "out/x.rds")
