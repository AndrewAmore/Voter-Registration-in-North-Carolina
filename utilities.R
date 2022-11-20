
### script file with helper functions


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
  
  model_fxed = data.frame(fixef(model), model=model_num)
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