library(httr)
library(jsonlite)
library(tidyverse)

## process more recent census API data in same format as initial data

resp = GET("https://api.census.gov/data/2019/pep/charagegroups?get=NAME,AGEGROUP,RACE,SEX,HISP,POP&for=county:*&in=state:37")
df = as.data.frame(fromJSON(rawToChar(resp$content)))

## add field names
colnames(df) = df[1,]
df = df[-1,]

## cast relevant fields
df$POP = as.numeric(df$POP)
df$AGEGROUP = as.numeric(df$AGEGROUP)

## field code conversion 
## 18-25, 26-40, 41-65, 65+
age_groups = c()
# (https://www.census.gov/data/developers/data-sets/popest-popproj/popest/popest-vars.html)
df %>% mutate(
  
)




## cache df local 