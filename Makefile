
# Note that I use *s below when I number the .R files in case the numbering
# changes. (I use numbers so I can remember the proper order when running)
# them individually.

# all
all: plot-sims.png

# set simulation parameters
out/pars.rds: *-set-pars.R
	Rscript $<
	
# create dataframe of observed variables
out/x.rds: *-create-x.R data/InternalDeterminants.dta
	Rscript $<
	
# do simulations (one csv per combo) and then bind them all together
out/sims.csv: *-do-sims.R *-bind-sims.R out/pars.rds out/x.rds
	rm -f sims/*   
	Rscript *-do-sims.R
	Rscript *-bind-sims.R
	
# plot simulations
plot-sims.png: *-plot-sims.R  out/sims.csv
	Rscript $<

clean: 
	rm -f out/* 
	rm -f sims/* 
	rm plot-sims.png