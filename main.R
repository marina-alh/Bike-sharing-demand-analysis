



# call requiered packets 


library(tidyverse) 
library(rvest)
library(httr)

#++++++++++++++++++++++++++++++++++++++++++++++++++
# WEBSCRAPING from Wikipedia

url <- "https://en.wikipedia.org/wiki/List_of_bicycle-sharing_systems"

#making GET request and parse website into xml document
root_node <- read_html(url)


table_nodes <- html_elements(root_node, "table")

df <- html_table(table_nodes[[2]])

write.csv(df ,"data\\raw_bike_sharing_systems.csv")

#+++++++++++++++++++++++++++++++++++++++++++#

# Getting data from open weather with API and JASON

# URL for Current Weather API
current_weather_url <- 'https://api.openweathermap.org/data/2.5/weather'



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





cities_weather_df <- get_weather_forecaset_by_cities(cities)

# Writing csv File 

write.csv(cities_weather_df, "data\\cities_weather_forecast.csv", row.names=FALSE)

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#+
#+ DOWNLOADING CSV FILE FROM URL

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



# Tidy_files:
# input <- dataset file name
# Converts all columns names of the file to uppercase
# Replace any white space separators by underscores, using the str_replace_all function
# Saves the new csv file
# output -> 0

tidy_files <- function(dataset_list){
        
        
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


tidy_files(ds_list)

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#+ Removing reference links and numeric values
#+
#+
# First load the dataset
bike_sharing_df <- read.csv("data\\raw_bike_sharing_systems.csv")


# In this project, let's only focus on processing the following relevant columns:
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

# Check whethe!♥r the System column has any reference links
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










# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Data wrangling part 2:


# Detecting and handling missing values with dplyr

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

summer_avg_temp = bike_sharing_df %>% 
        filter(SEASONS == "Summer") %>%  #subsetting rows using column values
        select(TEMPERATURE)  # Subset columns using their names and types
        
summer_avg_temp = mean(summer_avg_temp$TEMPERATURE, na.rm = TRUE)
        
bike_sharing_df = bike_sharing_df %>% 
        mutate(TEMPERATURE = replace_na(TEMPERATURE,summer_avg_temp))



# Print the summary of the dataset again to make sure no missing values in all columns

summary(bike_sharing_df)

# Save the dataset as `seoul_bike_sharing.csv`

write.csv(bike_sharing_df,paste('data\\',"seoul_bike_sharing.csv",sep=''), row.names=FALSE)



#++++++++++ Create indicator (dummy) variables for categorical variables ++++++++++++
bike_sharing_df <- read.csv("data//seoul_bike_sharing.csv")

require(fastDummies)
# Using mutate() function to convert HOUR column into character type

bike_sharing_df = bike_sharing_df %>% 
        mutate(HOUR = as.character(HOUR))


bike_sharing_df = bike_sharing_df %>% 
        dummy_columns(c("SEASONS","HOLIDAY","HOUR"),remove_selected_columns = TRUE)


# Save the dataset as `seoul_bike_sharing_converted.csv`

write.csv(bike_sharing_df, "data\\seoul_bike_sharing_converted.csv", row.names=FALSE)




#++++ Normalazing data

# Use the `mutate()` function to apply min-max normalization on columns 


l = c("RENTED_BIKE_COUNT", "TEMPERATURE", "HUMIDITY", "WIND_SPEED", "VISIBILITY", "DEW_POINT_TEMPERATURE", "SOLAR_RADIATION", "RAINFALL", "SNOWFALL")nMinMax = function(column){
        
        a = (column - min(column)) / (max(column)-min(column))
        
        return(a)
        
} 

debug(nMinMax)



seoul_bike_sharing_converted_normalized = as.data.frame(sapply(bike_sharing_df[2:10], nMinMax))


seoul_bike_sharing_converted_normalized$DATE = bike_sharing_df$DATE

df = seoul_bike_sharing_converted_normalized %>% 
        select(c("DATE","RENTED_BIKE_COUNT", "TEMPERATURE", "HUMIDITY", "WIND_SPEED", "VISIBILITY", "DEW_POINT_TEMPERATURE", "SOLAR_RADIATION", "RAINFALL", "SNOWFALL"))


df2 = bike_sharing_df[11:41]

df3= cbind(df,df2)

# undebug(nMinMax)
 
summary(df3)
 
write_csv(df3, "data\\seoul_bike_sharing_converted_normalized.csv")



# Dataset list
dataset_list <- c('seoul_bike_sharing.csv', 'seoul_bike_sharing_converted.csv', 'seoul_bike_sharing_converted_normalized.csv')

for (dataset_name in dataset_list){
        # Read dataset
        dataset <- read.csv(paste('data\\',dataset_name,sep=''))
        # Standardized its columns:
        # Convert all columns names to uppercase
        names(dataset) <- toupper(names(dataset))
        # Replace any white space separators by underscore, using str_replace_all function
        names(dataset) <- str_replace_all(names(dataset), " ", "_")
        # Save the dataset back
        write.csv(dataset, paste('data\\',dataset_name,sep=''), row.names=FALSE)
}




#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#+
#+
#Exploratory Data Analysis with tidyverse and ggplot2
#+
#+





bike_sharing_df <- read.csv("data//seoul_bike_sharing.csv")



bike_sharing_df = bike_sharing_df %>% 
        mutate(DATE = as.Date(DATE, format = "%d/%m/%Y" ))

bike_sharing_df = bike_sharing_df %>% 
        mutate(HOUR = as.factor(HOUR), SEASONS = as.factor(SEASONS), 
               HOLIDAY = as.factor(HOLIDAY), FUNCTIONING_DAY = as.factor(FUNCTIONING_DAY)) 
str(bike_sharing_df)
sum(is.na(bike_sharing_df))
summary(bike_sharing_df)


n_holidays = sum(bike_sharing_df$HOLIDAY == "Holiday")

n_records = 8465

perc_records =(n_holidays/n_records) * 100


records = 365*24

summary(bike_sharing_df)


# checking the total rainfall and snowfall

bike_sharing_df %>% 
        group_by(SEASONS) %>% 
        summarise(TOTAL_RAINFALL = sum(RAINFALL), TOTAL_SNOWFALL = sum(SNOWFALL))

# Scatter plot of RENTED BIKE COUNT  vs DATE


p1 <- ggplot(bike_sharing_df, aes(x=DATE, y=RENTED_BIKE_COUNT, color=HOUR)) +
        geom_point(alpha = 1/10) +
        labs( x = "Date", y = "Rented bike count",
              title = "Bike rent depending on the de day and time"
              
        )
p1

#Description: Peaks of bike rent mostly in the evenings of Summer and Autumn


p2 <- ggplot(bike_sharing_df, aes(x = RENTED_BIKE_COUNT)) +
        geom_histogram(aes(y=..density..),binwidth = 150,color = 1, fill = "white")+
        geom_density(col = "red",lwd = 1.2,fill = 2, alpha = 0.25)+
        labs( x = "Rented bike count", y = " ",
              title = "Number of rents density curve"
      
        )
        
p2

p3 <- ggplot(bike_sharing_df, aes(x=TEMPERATURE, y=RENTED_BIKE_COUNT, color=SEASONS)) +
        geom_point(alpha = 1/10) +
        labs( x = "Temperature in ºC", y = "Rented bike count",
              title ="Seasonal bike rent"
      )

p3 # temperature has to be between 20 and 30 for max rents


p4 <- ggplot(bike_sharing_df, aes(x=HOUR, y=RENTED_BIKE_COUNT, facets=SEASONS)) +
        geom_boxplot()+  
        facet_wrap(~ SEASONS, ncol = 2)+
        labs( x = "Hour of the day", y = "Rented bike count",
        title = "Daily bike rent by Season"
        )
p4


aux = bike_sharing_df %>% 
        group_by(DATE) %>% 
        summarise(TOTAL_RAINFALL = sum(RAINFALL), TOTAL_SNOWFALL = sum(SNOWFALL),counts = n()) 
   
p5 <- ggplot(aux) +
        geom_bar(aes(x = DATE, y = TOTAL_RAINFALL),stat = "identity", fill = "blue")+
        geom_bar(aes(x = DATE, y = TOTAL_SNOWFALL),stat = "identity", fill = "red")+
        labs( x = "date", y = "Rainfall/SnowFall (mm)",
                 title = "Daily Rainfall/Snowfall")+
p5

sum(aux$TOTAL_SNOWFALL != 0)



# HOURLY BIKE SHARING COUNT

# Predict Hourly Rented Bike Count using Basic Linear Regression Models:
#         
# TASK: Split data into training and testing data sets

# The main data for this task is going to be the seoul_bike_sharing_converted_normalized.csv

# loading the data

bike_sharing_df <- read.csv("data\\seoul_bike_sharing_converted_normalized.csv")
# bike_sharing_df <- read.csv("data\\seoul_bike_sharing_converted.csv")
bike_sharing_df = as_tibble(bike_sharing_df)



# discard DATE and FUNCTIONIN_DAY columns as they'll not be used

bike_sharing_df <- bike_sharing_df %>% 
        select(-DATE, -FUNCTIONING_DAY)

# With seed 1234
set.seed(1234)

# prop = 3/4
bike_sharing_df_split <- initial_split(bike_sharing_df, prop = 3/4)
# train_data 
train_data <- training(bike_sharing_df_split)
# test_data
test_data <- testing(bike_sharing_df_split)


# TASK: Build a linear regression model using only the weather variables

# TEMPERATURE - Temperature in Celsius
# HUMIDITY - Unit is %
# WIND_SPEED - Unit is m/s
# VISIBILITY - Multiplied by 10m
# DEW_POINT_TEMPERATURE - The temperature to which the air would have to cool down in order to reach saturation, unit is Celsius
# SOLAR_RADIATION - MJ/m2
# RAINFALL - mm
# SNOWFALL - cm


lm_model_weather <- linear_reg() %>% 
                        set_engine(engine = "lm") %>% 
                        set_mode(mode = "regression")
        

# Fit the model called `lm_model_weather`
# RENTED_BIKE_COUNT ~ TEMPERATURE + HUMIDITY + WIND_SPEED + VISIBILITY + DEW_POINT_TEMPERATURE + SOLAR_RADIATION + RAINFALL + SNOWFALL,  with the training data

train_fit <- lm_model_weather %>% 
                fit(RENTED_BIKE_COUNT ~ TEMPERATURE + HUMIDITY + WIND_SPEED + VISIBILITY + DEW_POINT_TEMPERATURE + SOLAR_RADIATION + RAINFALL + SNOWFALL,
                    data = train_data)

train_results <- train_fit %>% 
        # Make the predictions and save predicted values
        predict(new_data = train_data) %>% 
        # Create a new column to sabe the true values
        mutate(.truth = train_data$RENTED_BIKE_COUNT)




# TASK: Build a linear regression model using both weather and date/time variables


lm_model_all <- linear_reg() %>% 
        set_engine(engine = "lm") %>% 
        set_mode(mode = "regression")

train_fit_all <- lm_model_all %>% 
                fit(RENTED_BIKE_COUNT ~ .,
                    data = train_data)
        
train_results_all <- train_fit_all %>% 
                predict(new_data = train_data) %>% 
                mutate(.truth = train_data$RENTED_BIKE_COUNT)


# TASK: Evaluate the models and identify important variables

# metrics used to evaluate the models
# 1. R^2 / R-squared
# 2. Root Mean Squared Error (RMSE)

# Use predict() function to generate test results for `lm_model_weather` and `lm_model_all`
# and generate two test results dataframe with a truth column:

# test_results_weather for lm_model_weather model

# Testing the model

test_results <- train_fit %>% 
        # Make the predictions and saber the predicted values
        predict(new_data = test_data) %>% 
        # Create a new column to sabe the trie values
        mutate(.truth = test_data$RENTED_BIKE_COUNT)



# test_results_all for lm_model_all


test_results_all <- train_fit_all %>% 
        predict(new_data = test_data) %>% 
        mutate(.truth = test_data$RENTED_BIKE_COUNT)



#Calculating metrics 
rsq_weather_train <- rsq(train_results, truth = .truth,
                   estimate = .pred)
rsq_weather_test <- rsq(test_results, truth = .truth,
                        estimate = .pred)



rsq_all_train <- rsq(train_results_all, truth = .truth,
                estimate = .pred)
rsq_all_test <- rsq(test_results_all, truth = .truth,
                estimate = .pred)



rmse_weather_train <- rmse(train_results, truth = .truth,
                     estimate = .pred)
rmse_weather_test <- rmse(test_results, truth = .truth,
                     estimate = .pred)

rmse_all_train <- rmse(train_results_all, truth = .truth,
                     estimate = .pred)
rmse_all_test <- rmse(test_results_all, truth = .truth,
                     estimate = .pred)

# Plot to visualize how all the model predicts RENTED BIKE COUNT
test_results_all %>%
        mutate(train = "testing") %>%
        bind_rows(train_results_all %>% mutate(train = "training")) %>%
        ggplot(aes(.truth, .pred)) +
        geom_abline(lty = 2, color = "orange", 
                    size = 1.5) +
        geom_point(color = '#006EA1', 
                   alpha = 0.5) +
        facet_wrap(~train) +
        labs(x = "Truth", 
             y = "Rented bike count - All Variables")

## all variables model has rsq and rmse better

## Next step is to check what variables influence the most in the results

sort_coefi <-abs(train_fit_all$fit$coefficients)

sort_coefi

df <- tibble(VAR = names(sort_coefi), coefs = unname(sort_coefi))

df = na.omit(df)

p1 = ggplot(df, aes(x = reorder(VAR,coefs), y = coefs)) +
        geom_bar(stat='identity') +
        coord_flip()+
        xlab("Variables")+
        ylab("Coefficients")+
        labs(title = "Top-ranked variables by coeficient")
            
# Top-ranked variables by coefficient

p1



# LAB: Refine the Baseline Regression Models:

# TASK: Add higher order terms
library("tidymodels")
library("tidyverse")
library("stringr")

bike_sharing_df <- read.csv("data//seoul_bike_sharing_converted_normalized.csv")

bike_sharing_df <- bike_sharing_df %>% 
        select(-DATE, -FUNCTIONING_DAY)

lm_spec <- linear_reg() %>%
        set_engine("lm") %>% 
        set_mode("regression")


set.seed(1234)
data_split <- initial_split(bike_sharing_df, prop = 4/5)
train_data <- training(data_split)
test_data <- testing(data_split)

# TASK: Add interaction terms

# plot to verify that the correlation between RENTED BIKE COUNT and TEMPERATURE does not look linear
ggplot(data = train_data, aes(RENTED_BIKE_COUNT, TEMPERATURE)) + 
        geom_point() 

# Plot the higher order polynomial fits
ggplot(data=train_data, aes(RENTED_BIKE_COUNT, TEMPERATURE)) + 
        geom_point() + 
        geom_smooth(method = "lm", formula = y ~ x, color="red") + 
        geom_smooth(method = "lm", formula = y ~ poly(x, 2), color="yellow") + 
        geom_smooth(method = "lm", formula = y ~ poly(x, 4), color="green") + 
        geom_smooth(method = "lm", formula = y ~ poly(x, 6), color="blue")

# Fit a linear model with higher order polynomial on some important variables 

# #HINT: Use poly function to build polynomial terms, lm_poly <- RENTED_BIKE_COUNT ~ poly(TEMPERATURE, 6) + poly(HUMIDITY, 4) .....

lm_poly_fit <- lm_spec %>% 
        fit(RENTED_BIKE_COUNT ~ poly(TEMPERATURE, 6) + poly(HUMIDITY, 4)+., 
                  data = train_data)

summary(lm_poly_fit$fit)


test_results_poly_fit = lm_poly_fit %>% 
                predict(new_data = test_data) %>% 
                mutate(.truth = test_data$RENTED_BIKE_COUNT)


# it is not possible to have negative bike counts so:
test_results_poly_fit[test_results_poly_fit<0] <- 0



rsq_lm_poly <- rsq(test_results_poly_fit, truth = .truth, estimate = .pred)
rmse_lm_poly<- rmse(test_results_poly_fit, truth = .truth, estimate = .pred)



# Add interaction terms to the poly regression built in previous step

# HINT: You could use `*` operator to create interaction terms such as HUMIDITY*TEMPERATURE and make the formula look like:
# RENTED_BIKE_COUNT ~ RAINFALL*HUMIDITY ...

lm_poly_int_fit <- lm_spec %>% 
                fit(RENTED_BIKE_COUNT ~ poly(TEMPERATURE, 6) + poly(HUMIDITY, 4)+(RAINFALL * HUMIDITY)+., 
              data = train_data)


summary(lm_poly_int_fit$fit)

test_results_int = lm_poly_int_fit %>% 
                        predict(new_data = test_data) %>% 
                        mutate(.truth = test_data$RENTED_BIKE_COUNT)


test_results_int[test_results_int<0] <- 0


rsq_lm_poly_int <- rsq(test_results_int, truth = .truth, estimate = .pred)
rmse_lm_poly_int <- rmse(test_results_int, truth = .truth, estimate = .pred)

# TASK: Add regularization

# HINT: Use linear_reg() function with two parameters: penalty and mixture
# - penalty controls the intensity of model regularization
# - mixture controls the trade off between L1 and L2 regularization
# L1 - 1 lasso reduce number of features
# L2 - 0 Ridge don't reduce number of features


linreg_reg_spec <- 
        linear_reg(penalty = 0.001, mixture = 1) %>% 
        set_engine("glmnet")

lm_glmnet <- linreg_reg_spec %>% 
        fit(RENTED_BIKE_COUNT ~ poly(TEMPERATURE, 6) + poly(HUMIDITY, 4)+(RAINFALL * HUMIDITY)+., 
        data = train_data)

test_results_glmnet <- lm_glmnet %>% 
                predict(new_data = test_data) %>% 
                mutate(.truth = test_data$RENTED_BIKE_COUNT)



        
        
rsq_lm_poly_glmnet <- rsq(test_results_glmnet, truth = .truth, estimate = .pred)
rmse_lm_poly_glmnet <- rmse(test_results_glmnet, truth = .truth, estimate = .pred)

# You could manually try different parameter combinations or use grid search to find optimal combinations




tune_spec <- linear_reg(penalty = tune(), mixture = 1) %>% 
        set_engine("glmnet")

lambda_grid <- grid_regular(levels = 50,
                            penalty(range = c(-3,0.3)))

bike_cvfolds <- vfold_cv(train_data)

lasso_grid <- tune_grid(tune_spec,RENTED_BIKE_COUNT ~ poly(TEMPERATURE, 6) + poly(HUMIDITY, 4)+(RAINFALL * HUMIDITY)+.,
                        resamples = bike_cvfolds, grid = lambda_grid)

show_best(lasso_grid, metric = "rsq")


lasso_grid %>%
        collect_metrics() %>%
        filter(.metric == "rsq") %>%
        ggplot(aes(penalty, mean)) +
        geom_line(size=1, color="red") +
        scale_x_log10() +
        ggtitle("RSQ")




# TASK: Experiment to find the best performed model



test_results_int %>%  ggplot() +
        stat_qq(aes(sample=.truth), color='green') +
        stat_qq(aes(sample=.pred), color='red')



