# Bike sharing demand analysis


This project analyzes how weather would affect bike-sharing demand in urban areas. It uses the Soul bike sharing demand data set.
My tasks include:

    Collecting and understanding data from multiple sources
    Performing data wrangling and preparation with regular expressions and Tidyverse
    Performing exploratory data analysis with SQL and visualization using Tidyverse and ggplot2
    Performing modelling the data with linear regressions using Tidymodels
    Building an interactive dashboard using R Shiny


I will use this dataset to build a linear regression model of the number of bikes rented each hour, based on the weather.



TASK 1: Collect data from multiple sources.
        
        OpenWeather (JASON data) ----> http requests -------> Weather data by city (csv)
        
        Wikipedia pages (HTML)   ----> Webscraping   -------> bike sharing system (csv)
        
        IBM cloud storage (tabular data in csv) ----> file download ----> historical bike demand (csv)
        