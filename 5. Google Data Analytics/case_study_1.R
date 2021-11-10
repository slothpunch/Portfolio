
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
# 1. Add ride_days, ride_time, day_of_week
#

# bikes %>%
#   difftime(started_at, ended_at, units = 'mins') # not working

View(difftime(bikes$started_at, bikes$ended_at, units = 'mins'))

bikes <- bikes %>% mutate(ride_time = round(difftime(bikes$ended_at, bikes$started_at, units = 'mins')),2 )


# substr (x, start, stop)
# substring (x, start:start, stop:stop)
substr(bikes$ride_time[1], 1, 1)
substr(bikes$ride_time[1], 1, 1:3)
substring(bikes$ride_time[1], 1:3, 1:3) # e.g. 9.67 -> 1:3 (9 . 6)
?substr
summary(bikes)

substr(bikes$ride_time, -1, 1:3)

# bikes %>% mutate(time = str_split(bikes$ride_time, ' mins') %>% View())
# mutate(time = str_split(bikes$ride_time, ' mins') %>% View()
str_split(bikes$ride_time, ' mins')
       
# View(bikes)
# hour(bikes$started_at)
# minute(bikes$started_at)


# https://www.statmethods.net/input/dates.html
mutate(bikes, date = as.Date(bikes$started_at))

mutate(bikes, year = format(as.Date(bikes$started_at), '%Y')) # %y = 20, %Y = 2020
mutate(bikes, month = format(as.Date(bikes$started_at), '%m')) # 11
mutate(bikes, day = format(as.Date(bikes$started_at), '%d'))

# Add date (YYYY-MM-DD)
bikes$date <- as.Date(bikes$started_at)
















