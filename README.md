# Bike sharing demand analysis


This project analyzes how weather would affect bike-sharing demand in urban areas. It uses the Seoul bike sharing demand data set.
My tasks include:

    1. Collecting and understanding data from multiple sources
    2. Performing data wrangling and preparation with regular expressions and Tidyverse
    3. Performing exploratory data analysis with SQL and visualization using Tidyverse and ggplot2
    4. Performing modelling the data with linear regressions using Tidymodels
    5. Building an interactive dashboard using R Shiny


I will use these data sets to build a linear regression model of the number of bikes rented each hour, based on the weather.



TASK 1: Collect data from multiple sources.
        
        OpenWeather (JASON data) ----> http requests -------> Weather data by city (csv)
        
        Wikipedia pages (HTML)   ----> Webscraping   -------> bike sharing system (csv)
        
        IBM cloud storage (tabular data in csv) ----> file download ----> historical bike demand (csv)
        

TASK 2: Data Wrangling


2.1 Data wrangling with stringr and regular expressions 

    TASK: Standardize column names for all collected datasets
    TASK: Remove undesired reference links using regular expressions
    TASK: Extract numeric values using regular expressions

2.2. Data wrangling with dplyr 

    TASK: Detect and handle missing values
    TASK: Create indicator (dummy) variables for categorical variables
    TASK: Normalize data
    

TASK 3: EDA with tidyverse and ggpl2


TASK 4: Designing a model for prediction o Rented Bikes

4.1 Predict Hourly Rented Bike Count using Basic Linear Regression Models

        TASK: Split data into training and testing datasets
        TASK: Build a linear regression model using only the weather variables
        TASK: Build a linear regression model using both weather and date/time variables
        TASK: Evaluate the models and identify important variables
        TASK: Refine the Baseline Regression Models (120 mins):


4.2 Refine the Baseline Regression Models
      
       TASK: Add higher order terms
       TASK: Add interection terms
       TASK: Add regularization
       



#################################


Shiny app



    TASK: Add a basic max bike prediction overview map
    TASK: Add a select input (dropdown) to select a specific city




        