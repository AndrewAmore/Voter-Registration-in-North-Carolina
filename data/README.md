## Data
Describes the data elements used in the analysis. The original assignment provided
processed flat files from the 2010 Census and 2016 voter registration records from
a North Carolina State Agency. Population estimates from the 2010 Census were shown
to be invalid for 2016 election and more recent estimates from the official Census
API were gathered. 

### Description of Contents
- ```./Census_API/```: new logic for processing Census API data for more accurate
population metrics
- ```./Census2010_long.txt```: initial flat file Census data source from 2010
- ```./voter_stats_20161108.txt```: initial voter registration file