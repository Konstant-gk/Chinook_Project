import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import seaborn as snb
from sklearn.ensemble import RandomForestClassifier
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score
from sklearn.model_selection import cross_val_score, train_test_split, GridSearchCV
from sklearn.svm import SVC
from sklearn.tree import DecisionTreeClassifier

df = pd.read_csv('Rows_Query_Join_Tables_Chinook.csv')

print(df)
print(df.columns)
print(df['Employee_Age'].value_counts())

print(df['Employee_Role'].value_counts())

print(df['TotalRevenue'].describe())

# Convert 'Employee_HireDate' to a datetime object
df['Employee_HireDate'] = pd.to_datetime(df['Employee_HireDate'])

# Define the current date (use today's date or a specific date)
current_date = pd.Timestamp.now()  # Or replace with a specific date, e.g., pd.Timestamp('2025-01-01')

# Calculate tenure in years
df['Tenure'] = (current_date - df['Employee_HireDate']).dt.days / 365

# Display the dataset with the new 'Tenure' column
print(df[['Employee_HireDate', 'Tenure']].head())


# plt.hist(df['Employee_Age'], bins=20)
# plt.show()




















