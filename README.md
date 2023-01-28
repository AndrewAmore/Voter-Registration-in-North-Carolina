# Voter-Registration-in-North-Carolina
This repository contains code used for the report [NC-Voter-Case-Study.pdf](Who-VotesNC-Case-Study.pdf), 

## Abstract
Political candidates are often interested in understanding factors influencing
voter registration across different demographic categories and how overall registration
probability varies. Understanding these aspects can enhance informed decision
making for campaign staffs on election related decisions, like where to focus limited
advertising budgets to sway voters. Official voter registration records and census
population estimates for counties in North Carolina were collected and analyzed 
using Bayesian hierarchical modeling strategies. The large number of demographic 
combinations limit the analysis to a random sample of just 30% of all counties. 
The final models suggest demographic attributes, like age and race, have significant
impacts on registration rates as well as significant rate differences across geographies.
To explore predictive power of multilevel models, out-of-sample predictions on 
registration rates were computed and compared to the true values using MSE. Overall,
the fitted models display similar behavior and have high predictive accuracy for
a majority of observations. 

## Description of Contents
- ```./data/```: raw data directory and data processing scripts
- ```./models/```: fitted model objects
- ```./Who-VotesNC-Case-Study.Rmd```: main logic for analysis
- ```./utilities.R```: helper function definitions


## Acknowledgements
This report was developed for STA 610 (_Hierarchical Modeling_) at Duke, taught 
by professor David Dunson.
