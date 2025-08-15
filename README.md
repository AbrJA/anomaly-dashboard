# 📈 Time-Series Anomaly Detection Dashboard

This project is a Shiny web application designed for training and testing a time-series model to detect outliers. The app leverages a Fourier Transform-based time-series linear model (tslm) to forecast future values and identify anomalies. It's a powerful tool for analyzing univariate time-series data, making it ideal for monitoring sensor data, stock prices, or any other sequential data.

## 🚀 Getting Started

To run this application, you'll need Docker. If you don't have it, you can download it from the official Docker website.

**Clone the Repository**: First, clone the project from its repository.

    git clone <repository_url>
    cd <repository_name>

**Build the Docker Image**: Navigate to the project directory in your terminal and build the Docker image. This process might take a few minutes as it downloads and installs all the necessary dependencies.

    docker build -t sensor-app .

**Run the Docker Container**: Once the image is built, run the application as a Docker container.

    docker run -p 8000:8000 sensor-app

**Access the App**: Open your web browser and navigate to http://localhost:8000 to access the application.

## 📊 Features

The application is divided into two main sections: Train and Test.

### 🤖 Train Tab

This section allows you to train the forecasting model.

- Dataset Upload: Upload a .csv file containing your training data. The file should have timestamp and value columns.

- K-parameter: Use the slider to adjust the K parameter, which determines the number of Fourier components used in the tslm model. A higher K value captures more complex seasonal patterns.

- Train Button: Click "Train!" to run the model on your uploaded data.

- Views:

    - Summary: Provides a summary table of the training data, including count, mean, median, standard deviation, and a count of missing values. It also displays a table of model metrics after training, such as MAE, MSE, and RMSE, to evaluate the model's performance.

    - Table: Shows a paginated view of the raw training data.

    - Plot: Displays a line plot of the training data to give you a quick visual overview.

### 🧪 Test Tab

This section allows you to test the trained model on new data and detect outliers.

- Dataset Upload: Upload a .csv file for testing. This file should also have timestamp and value columns.

- Confidence: Select a confidence level for the prediction interval (e.g., 95% confidence). This determines the width of the band used for outlier detection.

- Epsilon: Adjust the epsilon slider to create a buffer around the confidence interval. Values outside of this buffer are flagged as outliers. A larger epsilon makes the outlier detection less sensitive.

- Test Button: Click "Test!" to run the trained model on your test data.

- Views:

    - Plot: A dynamic plotly chart that visualizes the test data, the model's prediction, the confidence interval, and highlights detected anomalies. Normal values are shown in green, while anomalies are marked in red.

    - Table: Displays a table of the test data, including a new outlier column (TRUE/FALSE) to indicate whether each data point was flagged. The table also supports exporting the data to a CSV file.

## 🛠️ Dependencies

The application relies on several key R packages:

- shiny: The core framework for building the web application.

- data.table: Used for efficient data manipulation and processing.

- bslib: Provides modern Bootstrap themes for the user interface.

- DT: Renders interactive data tables.

- plotly: Creates interactive, professional-looking plots.

- anomalyr: A custom package that contains the Metric and Model classes used for the time-series forecasting logic a direct fork from occmundial/healthr package.
