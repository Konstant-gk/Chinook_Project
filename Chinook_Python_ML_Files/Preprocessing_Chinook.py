import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import seaborn as snb
from sklearn.model_selection import train_test_split
from sklearn.tree import DecisionTreeClassifier
from sklearn.ensemble import RandomForestClassifier
from sklearn.tree import DecisionTreeClassifier
from sklearn.svm import SVC
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score
from sklearn.model_selection import cross_val_score
from sklearn.model_selection import GridSearchCV


df = pd.read_csv('Chinook_Employee_Joins_Aggregated_Nums.csv')
                                                                      #df.fillna(0, inplace=True),"\n"
print(df.head(),"\n")                                                 # Display the first few rows to inspect the data
print(df.columns,"\n")
print(df['Employee_Age'].value_counts(),"\n")
print(df['TotalRevenue'].describe(),"\n")
print(df,"\n")
print(df['Employee_Role'].value_counts(),"\n")

df['Employee_HireDate'] = pd.to_datetime(df['Employee_HireDate'])       # Convert 'Employee_HireDate' to a datetime object
current_date = pd.Timestamp.now()                                       # Define the current date (use today's date or a specific date)
df['Tenure'] = (current_date - df['Employee_HireDate']).dt.days / 365   # Calculate tenure in years
print(df[['Employee_HireDate', 'Tenure']].head(),"\n")                  # Display the dataset with the new 'Tenure' column

print(df.groupby('Employee_Age')['TotalInvoices'].median(),"\n")
print(df.groupby('Sex')['TotalRevenue'].median(),"\n")
df['TotalRevenue'] = df['TotalRevenue'].fillna(df.groupby('Sex')['TotalRevenue'].transform('min'))
df['AvgRevenue'] = df['AvgRevenue'].fillna(df.groupby('Sex')['AvgRevenue'].transform('min'))
print(df['TotalRevenue'],"\n")
print(df['TotalRevenue'].describe(),"\n")                               # Check descriptive statistics for revenue


















bin_edges = 1                                                        # Initialize bin_edges to avoid NameError
try:
    df['PerformanceCategory'] = pd.qcut(                                # Attempt to categorize using quantiles
    df['TotalRevenue'],
    q=3,                                                                # Quartiles (3 categories)
    labels=['Low Performer', 'Average Performer', 'High Performer'],
    duplicates='drop',                                                   # Handle duplicate edges
    retbins=True                                                         # Return bin edges for inspection
    )
    df['PerformanceCategory'], bin_edges = bins                         # Assign categories and get bin edges
    print(f"Bin edges: {bin_edges}\n")
except ValueError as e:
    print(f"An error occurred: {e}")


if len(bin_edges) - 1 != len(['Low Performer', 'Average Performer', 'High Performer']):     # Dynamically adjust labels if bins are reduced
    num_bins = len(bin_edges) - 1
    labels = [f'Category {i+1}' for i in range(num_bins)]  # Adjust labels dynamically
    df['PerformanceCategory'] = pd.qcut(df['TotalRevenue'], q=num_bins, labels=labels)



# df['PerformanceCategory'] = pd.qcut(
#     df['TotalRevenue'],
#     q=[0, 0.33, 0.66, 1],
#     labels=['Low Performer', 'Average Performer', 'High Performer']
# )
#
#
# X = df[['TotalInvoices', 'TotalRevenue', 'AvgRevenuePerCustomer', 'Tenure']]
# y = df['PerformanceCategory']
# X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
#
# print("\n")
#
# models = {
#     'Random Forest': RandomForestClassifier(),
#     'Decision Tree': DecisionTreeClassifier(),
#     'SVM': SVC(),
#     'Logistic Regression': LogisticRegression()
# }
#
# print("\n")
#
# for name, model in models.items():
#     model.fit(X_train, y_train)
#     predictions = model.predict(X_test)
#     print(f"{name}: {accuracy_score(y_test, predictions)}")
#
# print("\n")
#
#
# for name, model in models.items():
#     scores = cross_val_score(model, X, y, cv=5)
#     print(f"{name}: {scores.mean():.4f}")
#
#
# print("\n")
#
#
# param_grid = {'n_estimators': [50, 100, 200]}
# grid = GridSearchCV(RandomForestClassifier(), param_grid, cv=5)
# grid.fit(X_train, y_train)
# print(grid.best_params_)
#
# importance = grid.best_estimator_.feature_importances_
# for feature, importance in zip(X.columns, importance):
#     print(f"{feature}: {importance:.4f}")
#
# print("\n")
#
#
# sns.barplot(x=importance, y=X.columns)
# plt.title('Feature Importance')
# plt.show()



