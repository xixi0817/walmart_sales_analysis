#================================================
#title: STA9750 Final Project - Walmart Retail Sales
#Group: Group11 Xixi Lin
#date:  05/06/2026
#================================================
#install.packages("forecast")

#--------------------------------------------------------------------
# Step 1: Data Loading
#--------------------------------------------------------------------
# Load required library
library(regclass)
library(ggplot2)

# Load Data
walmart <- read.csv("Walmart.csv")

# Load Data and check number of the coloums and rows etc...
nrow(walmart)
ncol(walmart)
dim(walmart)
head(walmart, 4)

#--------------------------------------------------------------------
# Step 2: Data Clean
#--------------------------------------------------------------------

# Data Cleaning_Check missing values
colSums(is.na(walmart))

# Check summary of the data
summary(walmart)

# Data Cleaning_Convert variable types

walmart$Holiday_Flag <- as.factor(walmart$Holiday_Flag)
walmart$Store <- as.factor(walmart$Store)

# Check result
str(walmart)

# Remove the one row with negative Temperature (-2.06)
walmart <- walmart[walmart$Temperature >= 0, ]

# Confirm removal
nrow(walmart)

# Check distribution of Weekly_Sales
par(mfrow = c(1,2))
hist(walmart$Weekly_Sales,
     breaks = 30,
     main = "Distribution of Weekly Sales",
     xlab = "Weekly Sales",
     col = "lightblue",
     border = "white")
qq(walmart$Weekly_Sales)
par(mfrow = c(1,1))

#--------------------------------------------------------------------
# Step 3a: Association Analysis
#--------------------------------------------------------------------
# Plot 1: Temperature vs Weekly_Sales (Scatterplot)
plot(walmart$Temperature, walmart$Weekly_Sales,
     xlab = "Temperature",
     ylab = "Weekly Sales",
     main = "Temperature vs Weekly Sales",
     col = "blue",
     pch = 1)

# Plot 2: Fuel_Price vs Weekly_Sales (Scatterplot)
plot(walmart$Fuel_Price, walmart$Weekly_Sales,
     xlab = "Fuel Price",
     ylab = "Weekly Sales",
     main = "Fuel Price vs Weekly Sales",
     col = "red",
     pch = 1)

# Plot 3: CPI vs Weekly_Sales (Scatterplot)
plot(walmart$CPI, walmart$Weekly_Sales,
     xlab = "CPI",
     ylab = "Weekly Sales",
     main = "CPI vs Weekly Sales",
     col = "darkgreen",
     pch = 1)

# Plot 4: Unemployment vs Weekly_Sales (Scatterplot) with abline
plot(walmart$Unemployment, walmart$Weekly_Sales,
     xlab = "Unemployment Rate",
     ylab = "Weekly Sales",
     main = "Unemployment vs Weekly Sales",
     col = "purple",
     pch = 1)
###abline(model_unemployment, col = "red", lwd = 2)



# Plot 5: Holiday_Flag vs Weekly_Sales (Boxplot)
boxplot(Weekly_Sales ~ Holiday_Flag,
        data = walmart,
        xlab = "Holiday Flag (0 = Non-Holiday, 1 = Holiday)",
        ylab = "Weekly Sales",
        main = "Holiday Flag vs Weekly Sales",
        col = c("lightblue", "orange"))

#--------------------------------------------------------------------
# Step 3b: Statistical Tests
#--------------------------------------------------------------------

# Correlation matrix
all_correlations(walmart[, c("Weekly_Sales", "Temperature", 
                             "Fuel_Price", "CPI", "Unemployment")],
                 sorted = "strength")

# Test 1: Temperature vs Weekly_Sales
associate(Weekly_Sales ~ Temperature, data = walmart, seed = 298)

# Test 2: Fuel_Price vs Weekly_Sales
associate(Weekly_Sales ~ Fuel_Price, data = walmart, seed = 298)

# Test 3: Consumer Price Index vs Weekly_Sales
associate(Weekly_Sales ~ CPI, data = walmart, seed = 298)

# Test 4: Unemployment vs Weekly_Sales
associate(Weekly_Sales ~ Unemployment, data = walmart, seed = 298)

# Test 5: Holiday_Flag vs Weekly_Sales
associate(Weekly_Sales ~ Holiday_Flag, data = walmart, seed = 298)

#--------------------------------------------------------------------
# Step 4: Regression Model
#--------------------------------------------------------------------

# Model 1: Simple Linear Regression - Unemployment only
model_unemployment <- lm(Weekly_Sales ~ Unemployment, data = walmart)
summary(model_unemployment)

# Model 2: Multiple Regression - All variables
model_all <- lm(Weekly_Sales ~ Temperature + Fuel_Price + 
                  CPI + Unemployment + Holiday_Flag, 
                data = walmart)
summary(model_all)

# Model 3: Reduced Model - Significant variables only
model_reduced <- lm(Weekly_Sales ~ CPI + Unemployment + Holiday_Flag,
                    data = walmart)
summary(model_reduced)

# Confidence intervals for model_reduced
confint(model_reduced, level = 0.95)

#--------------------------------------------------------------------
# Step 5: Other Techniques 
#--------------------------------------------------------------------

# Recreate Sales_Level variable
walmart$Sales_Level <- ifelse(walmart$Weekly_Sales > 
                                median(walmart$Weekly_Sales), 
                              "High", "Low")
walmart$Sales_Level <- as.factor(walmart$Sales_Level)

# Mosaic Plot: Holiday_Flag vs Sales_Level
mosaicplot(table(walmart$Holiday_Flag, walmart$Sales_Level),
           xlab = "Holiday Flag (0=Non-Holiday, 1=Holiday)",
           ylab = "Sales Level",
           main = "Holiday Flag vs Sales Level",
           col = c("lightblue", "orange"))

chisq.test(table(walmart$Holiday_Flag, walmart$Sales_Level))


# ggplot: Unemployment vs Weekly Sales
ggplot(walmart, aes(x = Unemployment, y = Weekly_Sales)) +
  geom_point(color = "purple", alpha = 0.3, size = 1) +
  geom_smooth(method = "lm", color = "red", se = FALSE) +
  xlab("Unemployment Rate") +
  ylab("Weekly Sales") +
  ggtitle("Unemployment vs Weekly Sales")

#--------------------------------------------------------------------
# Step 5b: Other Techniques - Lasso & Ridge Regression
#--------------------------------------------------------------------

library(glmnet)

# Prepare matrix for glmnet (requires numeric matrix, no factors)
walmart_model <- model.matrix(Weekly_Sales ~ Temperature + Fuel_Price + 
                                CPI + Unemployment + Holiday_Flag, 
                              data = walmart)[, -1]
y <- walmart$Weekly_Sales

# Fit Ridge (alpha = 0)
ridge_model <- cv.glmnet(walmart_model, y, alpha = 0)

# Fit Lasso (alpha = 1)
lasso_model <- cv.glmnet(walmart_model, y, alpha = 1)

# Predict and get RMSE
ridge_preds <- predict(ridge_model, newx = walmart_model, s = "lambda.min")
lasso_preds <- predict(lasso_model, newx = walmart_model, s = "lambda.min")

cat("Ridge RMSE:", sqrt(mean((y - ridge_preds)^2)), "\n")
cat("Lasso RMSE:", sqrt(mean((y - lasso_preds)^2)), "\n")

# R² for Ridge and Lasso
ridge_r2 <- cor(y, ridge_preds)^2
lasso_r2 <- cor(y, lasso_preds)^2

cat("Ridge R²:", ridge_r2, "\n")
cat("Lasso R²:", lasso_r2, "\n")

# Plot cross-validation curves
par(mfrow = c(1, 2))
plot(ridge_model, main = "Ridge CV")
plot(lasso_model, main = "Lasso CV")
par(mfrow = c(1, 1))

#--------------------------------------------------------------------
# Step 5c: Other Techniques - Time Series Plot
#--------------------------------------------------------------------

# Convert Date column to Date type
walmart$Date <- as.Date(walmart$Date, format = "%d-%m-%Y")

# Aggregate: average weekly sales across all stores by date
sales_by_date <- aggregate(Weekly_Sales ~ Date, data = walmart, FUN = mean)

# Sort by date
sales_by_date <- sales_by_date[order(sales_by_date$Date), ]

# Plot time series
ggplot(sales_by_date, aes(x = Date, y = Weekly_Sales)) +
  geom_line(color = "steelblue", size = 0.8) +
  geom_smooth(method = "loess", color = "red", se = TRUE) +
  xlab("Date") +
  ylab("Average Weekly Sales") +
  ggtitle("Walmart Average Weekly Sales Over Time (2010-2012)") +
  theme_minimal()

#--------------------------------------------------------------------
# Step 5e: Other Techniques - Time Series (ARIMA)
#--------------------------------------------------------------------

library(forecast)

# Aggregate average weekly sales by date
sales_ts <- aggregate(Weekly_Sales ~ Date, data = walmart, FUN = mean)
sales_ts <- sales_ts[order(sales_ts$Date), ]

# Convert to time series object (weekly data, frequency = 52)
walmart_ts <- ts(sales_ts$Weekly_Sales, frequency = 52)

# Auto ARIMA - automatically finds best model
arima_model <- auto.arima(walmart_ts)
print(arima_model)

# Plot forecast with colors
plot(forecast_result,
     main = "Walmart Weekly Sales Forecast (Next 12 Weeks)",
     xlab = "Month",
     ylab = "Average Weekly Sales",
     col = "steelblue",       
     fcol = "red",            
     shadecols = c("lightpink", "mistyrose"),  
     flwd = 2,                 
     xaxt = "n")

# month
axis(1, 
     at = seq(1, 4, by = 3/12), 
     labels = c("Jan'10","Apr'10","Jul'10","Oct'10",
                "Jan'11","Apr'11","Jul'11","Oct'11",
                "Jan'12","Apr'12","Jul'12","Oct'12",
                "Jan'13"),
     cex.axis = 0.7,
     las = 2)

# picture
legend("topleft",
       legend = c("Historical", "Forecast", "95% CI", "80% CI"),
       col = c("steelblue", "red", "mistyrose", "lightpink"),
       lty = c(1, 1, NA, NA),
       pch = c(NA, NA, 15, 15),
       bty = "n")

# Accuracy metrics
cat("ARIMA Model Accuracy:\n")
print(accuracy(arima_model))


#------------------------------------------------
# Step 6: Conclusion - Model Comparison
#------------------------------------------------

# R² for each model
cat("Model 1 R²:", summary(model_unemployment)$r.squared, "\n")
cat("Model 2 R²:", summary(model_all)$r.squared, "\n")
cat("Model 3 R²:", summary(model_reduced)$r.squared, "\n")

# RMSE for each model
rmse <- function(model) sqrt(mean(residuals(model)^2))
cat("Model 1 RMSE:", rmse(model_unemployment), "\n")
cat("Model 2 RMSE:", rmse(model_all), "\n")
cat("Model 3 RMSE:", rmse(model_reduced), "\n")

# AIC comparison
AIC(model_unemployment, model_all, model_reduced)


