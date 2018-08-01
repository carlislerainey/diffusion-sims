
library(tidyverse)
library(magrittr)

filenames <- list.files("sims")

sims_df <- NULL
for (i in 1:length(filenames)) {
  cat(paste0("\nBinding simulations ", i, " of ", length(filenames), "\n"))
  sims_df %<>% 
    bind_rows(read_csv(paste0("sims/", filenames[i])))
}
write_csv(sims_df, "out/sims.csv")
