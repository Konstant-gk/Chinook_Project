import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import seaborn as sns
from sklearn.ensemble import RandomForestClassifier
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score, confusion_matrix, f1_score, precision_score, recall_score
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder
from sklearn.svm import SVC
from sklearn.tree import DecisionTreeClassifier

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
#
# # Perform Grid Search for Random Forest
# param_grid = {'n_estimators': [50, 100, 200]}
# grid = GridSearchCV(RandomForestClassifier(random_state=42), param_grid, cv=5)
# grid.fit(X_train, y_train)
#
# # Display the best parameters from GridSearchCV
# print("Best Parameters from GridSearchCV:", grid.best_params_)
#
# # Evaluate the best estimator
# best_rf = grid.best_estimator_
# y_pred_best_rf = best_rf.predict(X_test)
#
# evaluate_model("Optimized Random Forest", y_test, y_pred_best_rf)
#
# # Feature importance of the best Random Forest model
# importance = best_rf.feature_importances_
# for feature, imp in zip(X.columns, importance):
#     print(f"{feature}: {imp:.4f}")
#
# # Plot feature importance
# sns.barplot(x=importance, y=X.columns)
# plt.title('Feature Importance (Optimized Random Forest)')
# plt.xlabel('Importance')
# plt.ylabel('Features')
# plt.show()
#
# # Cross-validation for both models
# models = {"Random Forest": random_forest, "Decision Tree": decision_tree}
# print("\nCross-validation Scores:")
# for name, model in models.items():
#     scores = cross_val_score(model, X, y, cv=5)
#     print(f"{name}: {scores.mean():.4f}")
