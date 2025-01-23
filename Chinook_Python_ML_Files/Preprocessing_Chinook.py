import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import seaborn as snb
from sklearn.model_selection import train_test_split
from sklearn.tree import DecisionTreeClassifier
from sklearn.preprocessing import LabelEncoder
from sklearn.ensemble import RandomForestClassifier
from sklearn.tree import DecisionTreeClassifier
from sklearn.svm import SVC
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score
from sklearn.model_selection import cross_val_score
from sklearn.model_selection import GridSearchCV

# Load the data
df = pd.read_csv('Chinook_Employee_Joins_Aggregated_Nums.csv')

# Inspect data
print(df.head(), "\n")
print(df.columns, "\n")

# Convert 'Employee_HireDate' to a datetime object
df['Employee_HireDate'] = pd.to_datetime(df['Employee_HireDate'])

# Calculate tenure in years
current_date = pd.Timestamp.now()
df['Tenure'] = (current_date - df['Employee_HireDate']).dt.days / 365

# Fill missing values for relevant columns
df['TotalRevenue'] = df['TotalRevenue'].fillna(df.groupby('Sex')['TotalRevenue'].transform('min'))
df['AvgRevenue'] = df['AvgRevenue'].fillna(df.groupby('Sex')['AvgRevenue'].transform('min'))
df['TotalInvoices'] = df['TotalInvoices'].where(df['TotalInvoices'] != 0, df.groupby('Sex')['TotalInvoices'].transform('mean'))

# Create a new DataFrame with only the required features
features = ['EmployeeId', 'Employee_Role', 'Sex', 'Employee_BirthDate', 'Employee_Age', 'Employee_HireDate', 'Tenure',
            'TotalInvoices', 'TotalRevenue', 'AvgRevenue']
df_filtered = df[features]

# Display the first few rows of the new DataFrame
print(df_filtered.head())

# Remove samples where 'Employee_Role' is not 'Sales Support Agent'
df_final = df_filtered[df_filtered['Employee_Role'] == 'Sales Support Agent'].copy()

# Display the first few rows of the filtered DataFrame
print(df_final.head())

# Define performance labels based on quantiles of 'TotalRevenue'
quantile_labels = ['Low Performer', 'Average Performer', 'High Performer']
df_final['Performance_Label'] = pd.qcut(df_final['TotalRevenue'], q=3, labels=quantile_labels)


# Encode the performance labels
label_encoder = LabelEncoder()
df_final['Performance_Label_Encoded'] = label_encoder.fit_transform(df_final['Performance_Label'])

# Display the first few rows of the filtered DataFrame with the new labels
print(df_final[['EmployeeId', 'TotalRevenue', 'Performance_Label']].head())



# Define X (features) and y (target)
X = df_final[['Tenure', 'Employee_Age', 'TotalInvoices', 'TotalRevenue', 'AvgRevenue']]
y = df_final['Performance_Label_Encoded']

# Split data into training (80%) and test (20%) sets
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Initialize models
random_forest = RandomForestClassifier(random_state=42)
decision_tree = DecisionTreeClassifier(random_state=42)

# Train models
random_forest.fit(X_train, y_train)
decision_tree.fit(X_train, y_train)

# Make predictions
y_pred_rf = random_forest.predict(X_test)
y_pred_dt= decision_tree.predict(X_test)

# Evaluate models
def evaluate_model(name, y_test, y_pred):
    accuracy = accuracy_score(y_test, y_pred)
    precision = precision_score(y_test, y_pred, average='weighted')
    recall = recall_score(y_test, y_pred, average='weighted')
    f1 = f1_score(y_test, y_pred, average='weighted')
    print(f"{name} Model Metrics:")
    print(f"Accuracy: {accuracy:.2f}")
    print(f"Precision: {precision:.2f}")
    print(f"Recall: {recall:.2f}")
    print(f"F1 Score: {f1:.2f}")
    print()

    # Confusion matrix
    cm = confusion_matrix(y_test, y_pred)
    sns.heatmap(cm, annot=True, fmt='d', cmap='Blues', xticklabels=quantile_labels, yticklabels=quantile_labels)
    plt.title(f"{name} Confusion Matrix")
    plt.xlabel("Predicted Labels")
    plt.ylabel("True Labels")
    plt.show()

# Evaluate Random Forest
evaluate_model("Random Forest", y_test, y_pred_rf)

# Evaluate Decision Tree
evaluate_model("Decision Tree", y_test, y_pred_dt)








# bin_edges = 1                                                        # Initialize bin_edges to avoid NameError
# try:
#     df['PerformanceCategory'] = pd.qcut(                                # Attempt to categorize using quantiles
#     df['TotalRevenue'],
#     q=3,                                                                # Quartiles (3 categories)
#     labels=['Low Performer', 'Average Performer', 'High Performer'],
#     duplicates='drop',                                                   # Handle duplicate edges
#     retbins=True                                                         # Return bin edges for inspection
#     )
#     df['PerformanceCategory'], bin_edges = bins                         # Assign categories and get bin edges
#     print(f"Bin edges: {bin_edges}\n")
# except ValueError as e:
#     print(f"An error occurred: {e}")
#
#
# if len(bin_edges) - 1 != len(['Low Performer', 'Average Performer', 'High Performer']):     # Dynamically adjust labels if bins are reduced
#     num_bins = len(bin_edges) - 1
#     labels = [f'Category {i+1}' for i in range(num_bins)]  # Adjust labels dynamically
#     df['PerformanceCategory'] = pd.qcut(df['TotalRevenue'], q=num_bins, labels=labels)
#


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



