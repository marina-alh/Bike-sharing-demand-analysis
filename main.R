# # Check if need to install rvest` library
# require(rvest)
# 
# url <- "https://en.wikipedia.org/wiki/List_of_bicycle-sharing_systems"
# 
# 
# #making GET request andparse website into xml document
# root_node <- read_html(url)
# 
# 
# table_nodes <- html_elements(root_node, "table")
# 
# df <- html_table(table_nodes[[2]])
# 
# write.csv(df ,"data\\raw_bike_sharing_systems.csv")

#+++++++++++++++++++++++++++++++++++++++++++#



# Check if need to install rvest` library
require("httr")

library(httr)

# URL for Current Weather API
# current_weather_url <- 'https://api.openweathermap.org/data/2.5/weather'
# 
# 
# 
# # need to be replaced by your real API key
# your_api_key <- "e4614d8005296e56cff6675eefd7f6df"
# # Input `q` is the city name
# # Input `appid` is your API KEY, 
# # Input `units` are preferred units such as Metric or Imperial
# current_query <- list(q = "Seoul", appid = your_api_key, units="metric")
# 
# response <- GET(current_weather_url, query=current_query)
# 
# http_type(response)
# 
# json_result <- content(response, as="parsed")
# 
# 
# 
# # Create some empty vectors to hold data temporarily
# weather <- c()
# visibility <- c()
# temp <- c()
# temp_min <- c()
# temp_max <- c()
# pressure <- c()
# humidity <- c()
# wind_speed <- c()
# wind_deg <- c()

# 
# # $weather is also a list with one element, its $main element indicates the weather status such as clear or rain
# weather <- c(weather, json_result$weather[[1]]$main)
# # Get Visibility
# visibility <- c(visibility, json_result$visibility)
# # Get current temperature 
# temp <- c(temp, json_result$main$temp)
# # Get min temperature 
# temp_min <- c(temp_min, json_result$main$temp_min)
# # Get max temperature 
# temp_max <- c(temp_max, json_result$main$temp_max)
# # Get pressure
# pressure <- c(pressure, json_result$main$pressure)
# # Get humidity
# humidity <- c(humidity, json_result$main$humidity)
# # Get wind speed
# wind_speed <- c(wind_speed, json_result$wind$speed)
# # Get wind direction
# wind_deg <- c(wind_deg, json_result$wind$deg)
# 
# 
# weather_data_frame <- data.frame(weather=weather, 
#                                  visibility=visibility, 
#                                  temp=temp, 
#                                  temp_min=temp_min, 
#                                  temp_max=temp_max, 
#                                  pressure=pressure, 
#                                  humidity=humidity, 
#                                  wind_speed=wind_speed, 
#                                  wind_deg=wind_deg)


# Create some empty vectors to hold data temporarily

# City name column
city <- c()
# Weather column, rainy or cloudy, etc
weather <- c()
# Sky visibility column
visibility <- c()
# Current temperature column
temp <- c()
# Max temperature column
temp_min <- c()
# Min temperature column
temp_max <- c()
# Pressure column
pressure <- c()
# Humidity column
humidity <- c()
# Wind speed column
wind_speed <- c()
# Wind direction column
wind_deg <- c()
# Forecast timestamp
forecast_datetime <- Date()
# Season column
# Note that for season, you can hard code a season value from levels Spring, Summer, Autumn, and Winter based on your current month.
season <- c()
cities <- c("Seoul", "Washington, D.C.", "Paris", "Suzhou")

# Get forecast data for a given city list
get_weather_forecaset_by_cities <- function(city_names){
        df <- data.frame()
        for (city_name in city_names){
                # Forecast API URL
                forecast_url <- 'https://api.openweathermap.org/data/2.5/forecast'
                # Create query parameters
                forecast_query <- list(q = city_name, appid = "e4614d8005296e56cff6675eefd7f6df", units="metric")
                # Make HTTP GET call for the given city
                response <- GET(forecast_url, query=forecast_query)
                # Note that the 5-day forecast JSON result is a list of lists. You can print the reponse to check the results
                # results <- json_list$list
                json_result <- content(response, as="parsed")
                # Loop the json result
                for(i in 1:40) {
                        
                        city <- c(city, city_name)
                        weather <- c(weather,json_result$list[[i]]$weather[[1]]$main)
                        temp <- c(temp, json_result$list[[i]]$main$temp)
                        temp_min <- c(temp_min, json_result$list[[i]]$main$temp_min)
                        temp_max <- c(temp_max, json_result$list[[i]]$main$temp_max)
                        pressure <- c(pressure, json_result$list[[i]]$main$pressure)
                        humidity <- c(humidity, json_result$list[[i]]$main$humidity)
                        wind_speed <- c(wind_speed, json_result$list[[i]]$wind$speed)
                        wind_deg <- c(wind_deg, json_result$list[[i]]$wind$deg)
                        forecast_datetime <- c(forecast_datetime, as.Date.POSIXct(json_result$list[[i]]$dt))
                        season <- c(season, time2season(as.Date.POSIXct(json_result$list[[i]]$dt),out.fmt = "seasons") )
                        
                }
                
        }
        
        # Add the R Lists into a data frame
        df = rbind(df,data.frame(city,weather,temp,temp_min,temp_max,pressure,humidity,wind_speed,wind_deg,forecast_datetime, season))
        
        
        # Return a data frame
        return(df)
        
}


# debug(get_weather_forecaset_by_cities)



cities_weather_df <- get_weather_forecaset_by_cities(cities)

# undebug(get_weather_forecaset_by_cities)

write.csv(cities_weather_df, "data\\cities_weather_forecast.csv", row.names=FALSE)

# Download several datasets

# Download some general city information such as name and locations
url <- "https://cf-courses-data.s3.us.cloud-object-storage.appdomain.cloud/IBMDeveloperSkillsNetwork-RP0321EN-SkillsNetwork/labs/datasets/raw_worldcities.csv"
# download the file
download.file(url, destfile = "data\\raw_worldcities.csv")

# Download a specific hourly Seoul bike sharing demand dataset
url <- "https://cf-courses-data.s3.us.cloud-object-storage.appdomain.cloud/IBMDeveloperSkillsNetwork-RP0321EN-SkillsNetwork/labs/datasets/raw_seoul_bike_sharing.csv"
# download the file
download.file(url, destfile = "data\\raw_seoul_bike_sharing.csv")


#+++++++++++++++++++++++++ DATA WRANGLING +++++++++++++++++++++++++++


ds_list <- c('raw_bike_sharing_systems.csv', 'raw_seoul_bike_sharing.csv', 'raw_cities_weather_forecast.csv', 'raw_worldcities.csv')

foo <- function(dataset_list){
        
        
        for (dataset_name in dataset_list){
        
        # Read dataset
        dataset <- read_csv(paste('data\\',dataset_name,sep=''))
        
        # Standardized its columns:
        # Convert all column names to uppercase
        
        names(dataset) = toupper(names(dataset))
        
        
        # Replace any white space separators by underscores, using the str_replace_all function
        str_replace_all(names(dataset), ' ', '_')
        
        # Save the dataset 
        write.csv(dataset,paste('data\\',dataset_name,sep=''), row.names=FALSE)
        }

}

# debug(foo)

foo(ds_list)

# undebug(foo)

# First load the dataset
bike_sharing_df <- read.csv("data\\raw_bike_sharing_systems.csv")


# In this project, let's only focus on processing the following revelant columns (feel free to process the other columns for more practice):
# 
#     COUNTRY: Country name
#     CITY: City name
#     SYSTEM: Bike-sharing system name
#     BICYCLES: Total number of bikes in the system



# Select the four columns
sub_bike_sharing_df <- bike_sharing_df %>% select(COUNTRY, CITY, SYSTEM, BICYCLES)


sub_bike_sharing_df %>% 
        summarize_all(class) %>%
        gather(variable, class)

# grepl searches a string for non-digital characters, and returns TRUE or FALSE
# if it finds any non-digital characters, then the bicyle column is not purely numeric
find_character <- function(strings) grepl("[^0-9]", strings)

sub_bike_sharing_df %>% 
        select(BICYCLES) %>% 
        filter(find_character(BICYCLES)) %>%
        slice(0:10)

# Define a 'reference link' character class, 
# `[A-z0-9]` means at least one character 
# `\\[` and `\\]` means the character is wrapped by [], such as for [12] or [abc]
ref_pattern <- "\\[[A-z0-9]+\\]"
find_reference_pattern <- function(strings) grepl(ref_pattern, strings)

# Check whether the COUNTRY column has any reference links
sub_bike_sharing_df %>% 
        select(COUNTRY) %>% 
        filter(find_reference_pattern(COUNTRY)) %>%
        slice(0:10)
# Check whether the CITY column has any reference links
sub_bike_sharing_df %>% 
        select(CITY) %>% 
        filter(find_reference_pattern(CITY)) %>%
        slice(0:10)

# Check whether the System column has any reference links
sub_bike_sharing_df %>% 
        select(SYSTEM) %>% 
        filter(find_reference_pattern(SYSTEM)) %>%
        slice(0:10)

# remove reference link
remove_ref <- function(strings) {
        ref_pattern <- "\\[[A-z0-9]+\\]"
        # Replace all matched substrings with a empty space using str_replace_all()
        result = str_replace_all(strings, ref_pattern, '')
        
        # Trim the reslt if you want
        
        return(result)
        
}


debug(remove_ref)
undebug(remove_ref)


sub_bike_sharing_df  <- sub_bike_sharing_df %>% mutate(SYSTEM=remove_ref(SYSTEM), 
                               CITY=remove_ref(CITY),
                               BICYCLES=remove_ref(BICYCLES))

sub_bike_sharing_df %>% 
        select(CITY, SYSTEM, BICYCLES) %>% 
        filter(find_reference_pattern(CITY) | find_reference_pattern(SYSTEM) | find_reference_pattern(BICYCLES))


# Extract the first number
extract_num <- function(columns){
        # Define a digital pattern
        digitals_pattern <- "\\d+"
        # Find the first match using str_extract
        
         result = str_extract(columns,digitals_pattern)
        
        # Convert the result to numeric using the as.numeric() function
         
         result = as.numeric(result)
         
         return(result)
         
         
}

debug(extract_num)
undebug(extract_num)




sub_bike_sharing_df  <- sub_bike_sharing_df %>% mutate(BICYCLES=extract_num(BICYCLES))

summary(sub_bike_sharing_df$BICYCLES)

result = str_extract(columns,digitals_pattern)

# Write dataset to `bike_sharing_systems.csv`

write.csv(sub_bike_sharing_df,paste('data\\',"bike_sharing_systems.csv",sep=''), row.names=FALSE)



# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++##

bike_sharing_df <- read.csv("data//raw_seoul_bike_sharing.csv")

summary(bike_sharing_df)


# Drop rows with `RENTED_BIKE_COUNT` column == NA
# we normally can not allow missing values for the response variable, so missing values for 
# response variable must be either dropped or imputed properly.
# We can see that `RENTED_BIKE_COUNT` only has about 3% missing values (295 / 8760).

bike_sharing_df = bike_sharing_df %>% drop_na(RENTED_BIKE_COUNT)


# Print the dataset dimension again after those rows are dropped

dim(bike_sharing_df)

#  We could simply remove the rows but it's better to impute them because 
# TEMPERATURE should be relatively easy and reliable to estimate statistically.

bike_sharing_df %>% 
        filter(is.na(TEMPERATURE))

bike_sharing_df = bike_sharing_df %>% 
        filter(SEASONS == "Summer") %>%  #subsetting rows using column values
        # select(TEMPERATURE) %>% # Subset columns using their names and types
        mutate(TEMPERATURE = replace_na(TEMPERATURE, mean(TEMPERATURE, na.rm = TRUE)))



# Print the summary of the dataset again to make sure no missing values in all columns

summary(bike_sharing_df)

# Save the dataset as `seoul_bike_sharing.csv`

write.csv(bike_sharing_df,paste('data\\',"seoul_bike_sharing.csv",sep=''), row.names=FALSE)



#++++++++++ Create indicator (dummy) variables for categorical variables ++++++++++++


# Using mutate() function to convert HOUR column into character type

sub_bike_sharing_df = sub_bike_sharing_df %>% 
        mutate(HOUR = as.character(HOUR))