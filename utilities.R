
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