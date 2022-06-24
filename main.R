# Check if need to install rvest` library
require(rvest)

url <- "https://en.wikipedia.org/wiki/List_of_bicycle-sharing_systems"


#making GET request andparse website into xml document
root_node <- read_html(url)


table_nodes <- html_elements(root_node, "table")

df <- html_table(table_nodes[[2]])

write.csv(df ,"data\\raw_bike_sharing_systems.csv")


# Check if need to install rvest` library
require("httr")

library(httr)

# URL for Current Weather API
current_weather_url <- 'https://api.openweathermap.org/data/2.5/weather'



# need to be replaced by your real API key
your_api_key <- "e4614d8005296e56cff6675eefd7f6df"
# Input `q` is the city name
# Input `appid` is your API KEY, 
# Input `units` are preferred units such as Metric or Imperial
current_query <- list(q = "Seoul", appid = your_api_key, units="metric")

response <- GET(current_weather_url, query=current_query)

http_type(response)

json_result <- content(response, as="parsed")



# Create some empty vectors to hold data temporarily
weather <- c()
visibility <- c()
temp <- c()
temp_min <- c()
temp_max <- c()
pressure <- c()
humidity <- c()
wind_speed <- c()
wind_deg <- c()


# $weather is also a list with one element, its $main element indicates the weather status such as clear or rain
weather <- c(weather, json_result$weather[[1]]$main)
# Get Visibility
visibility <- c(visibility, json_result$visibility)
# Get current temperature 
temp <- c(temp, json_result$main$temp)
# Get min temperature 
temp_min <- c(temp_min, json_result$main$temp_min)
# Get max temperature 
temp_max <- c(temp_max, json_result$main$temp_max)
# Get pressure
pressure <- c(pressure, json_result$main$pressure)
# Get humidity
humidity <- c(humidity, json_result$main$humidity)
# Get wind speed
wind_speed <- c(wind_speed, json_result$wind$speed)
# Get wind direction
wind_deg <- c(wind_deg, json_result$wind$deg)


weather_data_frame <- data.frame(weather=weather, 
                                 visibility=visibility, 
                                 temp=temp, 
                                 temp_min=temp_min, 
                                 temp_max=temp_max, 
                                 pressure=pressure, 
                                 humidity=humidity, 
                                 wind_speed=wind_speed, 
                                 wind_deg=wind_deg)


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
forecast_datetime <- c()
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
                for(result in json_result) {
                        city <- c(city, city_name)
                        weather <- c(weather,json_result$weather[[1]]$main)
                        temp <- c(temp, json_result$main$temp)
                        temp_min <- c(temp_min, json_result$main$temp_min)
                        temp_max <- c(temp_max, json_result$main$temp_max)
                        pressure <- c(pressure, json_result$main$pressure)
                        humidity <- c(humidity, json_result$main$humidity)
                        wind_speed <- c(wind_speed, json_result$wind$speed)
                        wind_deg <- c(wind_deg, json_result$wind$deg)
                        forecast_datetime <- c(forecast_datetime, as.Date.POSIXct(json_result$dt))
                }
                
                # Add the R Lists into a data frame
        }
        
        # Return a data frame
        return(df)
        
}

cities_weather_df <- get_weather_forecaset_by_cities(cities)