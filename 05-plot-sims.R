
# load packages
library(tidyverse)
library(boot)

# load simulations
sims_df <- read_csv("out/sims.csv") %>%
  glimpse()

sum_df <- sims_df %>%
  gather(quantity, estimate, slope, intercept) %>%
  glimpse() %>%
  group_by(quantity, var, p_min, p_max) %>%
  summarize(expected_value = mean(estimate), 
            n = n(),
            se = sd(estimate)/sqrt(n()), 
            ci_lwr = t.test(estimate, conf.int = TRUE)$conf.int[1],
            ci_upr = t.test(estimate, conf.int = TRUE)$conf.int[2]) %>%
  mutate(true = ifelse(quantity == "intercept", p_min, p_max - p_min)) %>%
  glimpse()

ggplot(sum_df, aes(x = true, 
                   y = expected_value, 
                   ymin = ci_lwr,
                   ymax = ci_upr,
                   color = var)) + 
  geom_point(alpha = 0.5) + 
  geom_errorbar(width = 0, alpha = 0.5) + 
  facet_wrap(~ quantity, scales = "free_x") + 
  geom_abline(slope = 1, intercept = 0) + 
  theme_bw()


ggsave("plot-sims.png", height = 5, width = 8)