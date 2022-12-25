
# helper functions to remove code "bloat" from markdown document

## DATA CLEANING
# census data
load_census_df = function(){
  census = read.table(file="./data/Census2010_long.txt", header = TRUE)
  
  ## combine NativeHawaiianOrOtherPacificIslanderAlone and SomeOtherRaceAlone to match voter_stats
  census = census %>% 
    filter(Race %in% c("NativeHawaiianOrOtherPacificIslanderAlone", 
                       "SomeOtherRaceAlone")) %>%
    group_by(Geography, Age, Gender, Hispanic) %>% 
    summarise(freq_sum = sum(Freq)) %>% 
    mutate(Race = "SomeOtherRaceAlone") %>% 
    inner_join(census, by= c("Geography")) %>%
    distinct(Geography, Age.x, Gender.x, Hispanic.x, Race.x, freq_sum, 
             TotalCountyPopulation) %>%
    rename("Age" = "Age.x", "Gender" = "Gender.x", "Hispanic" = "Hispanic.x", 
           "Race" = "Race.x", "Freq" = "freq_sum") %>%
    relocate(Freq, .after = Race) %>%
    union(census %>% filter(!Race %in% 
                              c("NativeHawaiianOrOtherPacificIslanderAlone", 
                                "SomeOtherRaceAlone"))) %>%
    ungroup()
  return(census)
}

# voter registration data
load_voter_df = function(){
  voter_stats = read.table(file="./data/voter_stats_20161108.txt", 
                           header = TRUE, na.strings=c("", " ", NA))
  ## democrat, libertarian, republican, unaffiliated
  
  voter_stats = voter_stats %>% 
    # reformat age to match
    mutate(Age = case_when(
      age == "Age 18 - 25" ~ "18-25",
      age == "Age 26 - 40" ~ "26-40",
      age == "Age 41 - 65" ~ "41-65",
      TRUE ~ "66+")) %>%
    # rename county to match
    rename("Geography" = "county_desc") %>%
    # reformat ethnicity
    mutate(Hispanic = case_when(
      ethnic_code == "NL" ~ "NotHispanic",
      ethnic_code == "HL" ~ "Hispanic",
      TRUE ~ "Undesignated")) %>%
    ## one unmatched field between sources (NativeHawaiianOrOtherPacificIslanderAlone)
    mutate(Race = case_when(
      race_code == "W" ~ "WhiteAlone",
      race_code == "B" ~ "BlackAlone",
      race_code == "O" ~ "SomeOtherRaceAlone",
      race_code == "U" ~ "Undesignated",
      race_code == "I" ~ "AmericanIndianOrAlaskaNativeAlone",
      race_code == "A" ~ "AsianAlone",
      race_code == "M" ~ "TwoOrMoreRaces",
      TRUE ~ "Undesignated")) %>%
    ## one unmatched field (U)
    mutate(Gender = case_when(
      sex_code == "F" ~ "Female",
      sex_code == "M" ~ "Male",
      TRUE ~ "Unknown")) %>% 
    dplyr::select(-age, -ethnic_code, -race_code, -sex_code) %>%
    ## aggregate by county
    group_by(Geography, party_cd, Age, Gender, Hispanic, Race) %>%
    summarise(VoterFreq = sum(total_voters)) %>%
    ungroup()
  return(voter_stats)
}


## END CLEANING FUNCTIONS




# given predictions, build a result df
return_pred_df = function(test_df, model_1, model_2, model_3){
  ## get predictions
  predictions = predict(model_1, newdata = test_df, allow_new_levels=TRUE)
  predictions2 = predict(model_2, newdata = test_df, allow_new_levels=TRUE)
  predictions3 = predict(model_3, newdata = test_df, allow_new_levels=TRUE)
  
  ## build final df
  results1 = cbind(test_df, predictions, Model = "Model I")
  results1$index = rownames(results1)
  results2 = cbind(test_df, predictions2, Model = "Model II")
  results2$index = rownames(results2)
  results3 = cbind(test_df, predictions3, Model = "Model III")
  results3$index = rownames(results3)
  results1$abs_diff = results1$VoterFreq - results1$Estimate
  results2$abs_diff = results2$VoterFreq - results2$Estimate
  results3$abs_diff = results3$VoterFreq - results3$Estimate
  
  results = rbind(results1, results2, results3)
  
  ## compute CR flag
  results = results %>% mutate(within_region = case_when(
    VoterFreq >= Q2.5 & VoterFreq <= Q97.5 ~ 1,
    TRUE ~0
    ))
  return(results)
}



# given a dataframe of categorical variables compute the correlation matrix
compute_corr = function(sample){
  dim = ncol(sample)
  corr_matrix = matrix(nrow = dim, ncol = dim)
  rownames(corr_matrix) = colnames(sample)
  colnames(corr_matrix) = colnames(sample)
  
  for(i in 1:dim){
    for(j in 1:dim){
      corr_matrix[i,j] = cramerV(table(as.matrix(sample[,i]), as.matrix(sample[,j])))
    }
  }
  
  return(corr_matrix)
}


# format fixed effects estimates for interval plotting
compute_fixed_effect_intervals = function(model, model_num){
  model_fxed = data.frame(fixef(model), Model=model_num)
  model_fxed$parameter = rownames(model_fxed)
  model_fxed = model_fxed %>% mutate(parameter = case_when(
    parameter == "PartyCdLIB" ~ "party_cdLIB",
    parameter == "PartyCdREP" ~ "party_cdREP",
    parameter == "PartyCdUNA" ~ "party_cdUNA",
    TRUE ~ parameter
  ))
  model_fxed = model_fxed[2:nrow(model_fxed),]
  rownames(model_fxed) = NULL
  return(model_fxed)
}

# extract legend from ggplot
get_legend = function(myplot){
  tmp = ggplot_gtable(ggplot_build(myplot))
  leg = which(sapply(tmp$grobs, function(x) x$name) == "guide-box")
  legend = tmp$grobs[[leg]]
  return(legend)
}

## try and extract legend
### extract legend elements from each individual table and combine into mega legend
# tmp = ggplot_gtable(ggplot_build(p1))
# tmp2 = ggplot_gtable(ggplot_build(p2))
# leg = which(sapply(tmp$grobs, function(x) x$name) == "guide-box")
# leg2 = which(sapply(tmp2$grobs, function(x) x$name) == "guide-box")
# legend = tmp$grobs[[leg]]
# legend2 = tmp2$grobs[[leg2]]
# p2_legend = get_legend(p2)
# grid.arrange(
#   arrangeGrob(p1 + theme(legend.position="none"), p2 + theme(legend.position="none"), nrow=2), 
#              p2_legend, 
#              nrow=2, heights=c(5, 1))