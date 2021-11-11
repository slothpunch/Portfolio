
getwd()

readClipboard()

setwd('C:\\Users\\GIS\\Documents\\A.Udemy\\Python\\Coursera')
getwd()

library(tidyverse)
library(lubridate)

# bikes <- read.csv('Divvy_Trips_202010_202109.csv')
bikes <- read.csv('202011-divvy-tripdata.csv')


# show the first six rows. Python = head()
head(bikes)

# congruent with / akin to / similar to glimpse()
str(bikes)

# show the columns, dtypes and some values. Python = info() ? 
# number of rows/columns
glimpse(bikes) # rows = 259,176, cols = 13

# show statistical summary. Python = describe() 
summary(bikes)

# show columns. Python = columns()
names(bikes)

#  Python = value_counts()?
table(bikes$member_casual)
table(bikes$start_station_name)

# Python = unique()
unique(bikes$member_casual)

# change casual -> subscriber 
mutate(bikes, subscriber = recode(member_casual, 'casual' = 'subscriber'))


# exclude started_at
bikes %>% select(-c(started_at))


# change started_at and ended_at into date format
mutate(bikes, ride_id = as.character(ride_id)) # work
bikes %>% mutate(ride_id = as.character(ride_id)) # work

mutate(bikes$ride_id = as.character(ride_id)) # error


# Q. How do annual members and casual riders use Cyclistic bikes differently?

#
# 1. Add ride_days, day_of_week, riding_time
#

# https://www.statmethods.net/input/dates.html
mutate(bikes, date = as.Date(bikes$started_at))

mutate(bikes, year = format(as.Date(bikes$started_at), '%Y')) # %y = 20, %Y = 2020
mutate(bikes, month = format(as.Date(bikes$started_at), '%m')) # 11
mutate(bikes, day = format(as.Date(bikes$started_at), '%d')) # date
mutate(bikes, day = format(as.Date(bikes$started_at), '%A')) # day_of_week Monday - Sunday

bikes$date <- as.Date(bikes$started_at) # date (YYYY-MM-DD) e.g. 2020-01-01
bikes$year <- format(as.Date(bikes$started_at), '%Y') # %y = 20, %Y = 2020
bikes$month <-  format(as.Date(bikes$started_at), '%m') # 11
bikes$day <- format(as.Date(bikes$started_at), '%d') # date
bikes$day_of_week <- format(as.Date(bikes$started_at), '%A') # day_of_week Monday - Sunday

str(bikes)

# Add riding_time in seconds
bikes$riding_time <- difftime(bikes$ended_at, bikes$started_at)
# bikes <- bikes %>% mutate(riding_time = as.integer(round(difftime(bikes$ended_at, bikes$started_at, units = 'secs'))))

# bikes %>%
#   difftime(started_at, ended_at, units = 'mins') # not working

str(bikes)
View(bikes)

# bikes %>% arrange(bikes$riding_time, desc(riding_time)) # nor working for difftime 
# bikes <- bikes %>% select(-c(riding_time)) # the other columns except rid_time column

as.character(bikes$riding_time) # string
as.numeric(bikes$riding_time) # double

as.numeric(as.character(bikes$riding_time)) # Why uses character and then numeric?
typeof(as.numeric(as.character(bikes$riding_time)))

# Found the wrong started_at and ended_at inputs. Some riding_time data are negative.
bikes$riding_time <- as.numeric(as.character(bikes$riding_time))
View(bikes)

# https://www.datasciencemadesimple.com/delete-or-drop-rows-in-r-with-conditions-2/


#
# Not run
#

# How many bad data: 813 rows
bikes %>% filter(riding_time < 0) 

bikes[!(bikes$riding_time > 0)] # not working without a comma 

# bikes[!(bikes$start_station_id == 'STH' | bikes$riding_time < 0),]
dim(bikes[!(bikes$riding_time < 0),])   # contains 0 as well
dim(bikes %>% filter(riding_time >= 0)) 

#
# Not run End
#

# Create bikes_v2 storing data without the bad data
bikes_v2 <- bikes %>% filter(riding_time >= 0) 

View(bikes_v2)

#=======================================
# 4. Conduct Descriptive Analysis
#=======================================

# 4-1. Find min, max, avg, median of riding_time

min(bikes_v2$riding_time)
max(bikes_v2$riding_time)
mean(bikes_v2$riding_time)
median(bikes_v2$riding_time)

# Or
summary(bikes_v2$riding_time)

# For casual riders and members

aggregate(bikes_v2$riding_time ~ bikes_v2$member_casual, FUN = min)
aggregate(bikes_v2$riding_time ~ bikes_v2$member_casual, FUN = max)
aggregate(bikes_v2$riding_time ~ bikes_v2$member_casual, FUN = mean)
aggregate(bikes_v2$riding_time ~ bikes_v2$member_casual, FUN = median)





#







# substr (x, start, stop)
# substring (x, start:start, stop:stop)
substr(bikes$riding_time[1], 1, 1)
substr(bikes$riding_time[1], 1, 1:3)
substring(bikes$riding_time[1], 1:3, 1:3) # e.g. 9.67 -> 1:3 (9 . 6)
?substr
summary(bikes)

substr(bikes$riding_time, -1, 1:3)

# View(bikes)
# hour(bikes$started_at)
# minute(bikes$started_at)















