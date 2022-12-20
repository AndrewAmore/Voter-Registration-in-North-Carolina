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
# df$AGEGROUP = as.numeric(df$AGEGROUP)

## field code conversion 
# (https://www.census.gov/data/developers/data-sets/popest-popproj/popest/popest-vars.html)

### AgeGroup (there is not an exact match between sources)
## 18-24, 25-44, 45-64, 65+
age_groups = c("23", "24", "25", "26")
df = df %>% filter(AGEGROUP %in% age_groups)

### Race 
## WhiteAlone, BlackAlone, AmericanIndianOrAlaskaNativeAlone, 
## AsianAlone, NativeHawaiianOrOtherPacificIslanderAlone, 
## TwoOrMoreRaces, SomeOtherRaceAlone
race_ = c("1", "2", "3", "4", "5", "6")
df %>% mutate(
  RACE = case_when(
    RACE == "1" ~ "WhiteAlone",
    RACE == "2" ~ "BlackAlone",
    RACE == "3" ~ "AmericanIndianOrAlaskaNativeAlone"
    
  )
)



### clean-up county name
df$NAME = gsub(" County, North Carolina", "", df$NAME)






## cache df local 