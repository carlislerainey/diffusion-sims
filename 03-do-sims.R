
# load packages
library(tidyverse)
library(magrittr)

# load simulation parameters
pars_df <- read_rds("out/pars.rds")

# load observed covariates (rescales)
x_df <- read_rds("out/x.rds") %>%  
  glimpse()

# do the simulations for each row in the pars df. 
for (k in 1:nrow(pars_df)) {
  cat(paste0("\nWorking on parameter combo ", k, " of ", nrow(pars_df), "\n"))
  # create data frame to hold simulations
  # -------------------------------------
  # note: pre-sizing this matrix is much faster, especially if the number of 
  # simulations is large than adding a row to a matrix, df, or vector
  # for each new simulation.
  sims_mat <- matrix(NA, ncol = 2, nrow = pars_df$n_sims[k]); colnames(sims_mat) <- c("slope", "intercept")
  prog <- progress_estimated(pars_df$n_sims[k], min_time = 0.1)  # create progress bar
  for (i in 1:pars_df$n_sims[k]) {  
    # create a data set for this iteration of the simulation
    df_i <- x_df %>%
      # keep the time period, group id, and one of the observed covariates (renamed "x")
      select(time_period, group_id, x = !!rlang::sym(pars_df$var[k])) %>%
      # add the probabilities of an event for each group-time
      mutate(p = pars_df$p_min[k] + (pars_df$p_max[k] - pars_df$p_min[k])*x)  %>%
      # shrink to proper size (according to simulation parameters)
      filter(group_id <= pars_df$n_groups[k]) %>%
      filter(time_period <= pars_df$n_groups[k]) %>%
      # simulate the full y for all groups and time periods
      mutate(y = rbinom(n(), size = 1, prob = p)) 
    # loop over each group and drop each time period after the first event
    for (j in 1:pars_df$n_groups[k]) {
      # find cases that should be dropped
      # ---------------------------------
      # note: find the first (min) time period where y = 1 in group j.
      # any events?
      time_of_first_event <- ifelse(sum(df_i$y[df_i$group_id == j]) > 0,  
                                    # if so
                                    min(df_i$time_period[df_i$y == 1 & df_i$group_id == j]), 
                                    # if not
                                    Inf)  
      # drop time periods after first event for group j
      df_i %<>%
        filter(!(group_id == j & time_period > time_of_first_event))
    } 
    fit <- lm(y ~ x, data = df_i)  # fit lpm
    sims_mat[i, "slope"] <- coef(fit)[2]  # store slope
    sims_mat[i, "intercept"] <- coef(fit)[1]  # store intercept
    prog$tick()$print()  # report progress/eta
  }
  
  # save simulations for paramater combination k
  sims_df  <- data.frame(slice(pars_df, k), 
                         intercept = sims_mat[, "intercept"],
                         slope = sims_mat[, "slope"]) %>%
    write_csv(paste0("sims/sims-pars-", k, ".csv"))
}

