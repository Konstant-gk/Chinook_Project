import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import seaborn as sns
from sklearn.ensemble import RandomForestClassifier
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import classification_report, accuracy_score, confusion_matrix, f1_score, precision_score, recall_score
from sklearn.model_selection import train_test_split, StratifiedKFold, GridSearchCV
from sklearn.preprocessing import LabelEncoder
from sklearn.preprocessing import StandardScaler
from sklearn.svm import SVC
from sklearn.tree import DecisionTreeClassifier
from sklearn.neighbors import KNeighborsClassifier
import warnings


# Load the data
df = pd.read_csv('Chinook_Employee_Joins_Aggregated_Nums.csv')

# Inspect data
print(df.columns, "\n")

# Convert 'Employee_HireDate' to a datetime object
df['Employee_HireDate'] = pd.to_datetime(df['Employee_HireDate'])

# Calculate tenure in years
current_date = pd.Timestamp.now()
df['Tenure'] = (current_date - df['Employee_HireDate']).dt.days / 365

# Format AvgRevenue to 2 decimal places
df['AvgRevenue'] = df['AvgRevenue'].round(2)

# Fill any remaining NaN values with 0
df[['TotalRevenue', 'AvgRevenue', 'ReportsTo']] = df[['TotalRevenue', 'AvgRevenue', 'ReportsTo']].fillna(0)

# Calculate the total average per year (TotalRevenue / Tenure)
df['AnnualRevenue'] = (df['TotalRevenue'] / df['Tenure']).round(2)

# Round tenure to the nearest integer
df[['Tenure', 'ReportsTo']] = df[['Tenure', 'ReportsTo']].round().astype(int)

# Remove outliers where 'Employee_Role' is not 'Sales Support Agent' and employeeId is 3,4,5
df2 = df[df['Employee_Role'] == 'Sales Support Agent']
df3 = df2[~df2['EmployeeId'].isin([3, 4, 5])]

# Create a new DataFrame with only the required features
features = ['EmployeeId', 'Employee_Role', 'Sex', 'Employee_Age', 'Tenure',
            'TotalInvoices', 'TotalRevenue', 'AvgRevenue', 'AnnualRevenue']

df4 = df3[features]

# Ensure df_final is a proper copy of the DataFrame
print(df4['TotalRevenue'].value_counts())
df_final = df4.copy()

# Define performance labels based on quantiles of 'TotalRevenue'
quantile_labels = ['Low Performer', 'Average Performer', 'High Performer']
df_final['Performance_Label'] = pd.qcut(df_final['TotalRevenue'], q=3, labels=quantile_labels, duplicates='drop')

# Create a dictionary to map labels to desired numbers
label_mapping = {'Low Performer': 0, 'Average Performer': 1, 'High Performer': 2}

# Map labels to numbers
df_final['Performance_Label_Encoded'] = df_final['Performance_Label'].map(label_mapping)

# Display the first few rows of the filtered DataFrame
print(df_final.head())

# Define X (features) and y (target)
X = df_final[['Employee_Age', 'TotalInvoices', 'AvgRevenue', 'AnnualRevenue']]
y = df_final['Performance_Label_Encoded']

# Normalize the features using StandardScaler
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

# Stratified K-Fold Cross-Validation with GridSearchCV
models = {
    "SVM": (SVC(random_state=42), {'C': [0.1, 1, 10], 'kernel': ['linear', 'rbf']}),
    "Logistic Regression": (LogisticRegression(random_state=42), {'C': [0.1, 1, 10]}),
    "Decision Tree": (DecisionTreeClassifier(random_state=42), {'max_depth': [None, 10, 20]}),
    "Random Forest": (RandomForestClassifier(random_state=42), {'n_estimators': [50, 100, 200]}),
    "KNN": (KNeighborsClassifier(), {'n_neighbors': [3, 5, 7]})
}

skf = StratifiedKFold(n_splits=5, shuffle=True, random_state=42)
best_estimators = {}

for model_name, (model, param_grid) in models.items():
    print(f"Performing GridSearchCV for {model_name}...")
    grid_search = GridSearchCV(model, param_grid, scoring='accuracy', cv=skf, n_jobs=-1)
    grid_search.fit(X_scaled, y)
    best_estimators[model_name] = grid_search.best_estimator_
    print(f"Best parameters for {model_name}: {grid_search.best_params_}")

# Train-Test-Validation Split (80%-10%-10%)
X_train, X_temp, y_train, y_temp = train_test_split(X_scaled, y, test_size=0.2, stratify=y, random_state=42)
X_val, X_test, y_val, y_test = train_test_split(X_temp, y_temp, test_size=0.5, stratify=y_temp, random_state=42)

# Train and Evaluate Models
for model_name, model in best_estimators.items():
    print(f"\nEvaluating {model_name}...")
    model.fit(X_train, y_train)
    y_pred = model.predict(X_test)

# Metrics
accuracy = accuracy_score(y_test, y_pred)
precision = precision_score(y_test, y_pred, average='weighted')
recall = recall_score(y_test, y_pred, average='weighted')
f1 = f1_score(y_test, y_pred, average='weighted')

# Print metrics
print("\n"f"Accuracy: {accuracy:.3f}")
print(f"Precision: {precision:.3f}")
print(f"Recall: {recall:.3f}")
print(f"F1 Score: {f1:.3f}")

# Classification Report
print("\nClassification Report:")
print(classification_report(y_test, y_pred))

# Confusion Matrix
cm = confusion_matrix(y_test, y_pred)
plt.figure(figsize=(6, 4))
sns.heatmap(cm, annot=True, fmt='d', cmap='Blues', xticklabels=quantile_labels, yticklabels=quantile_labels)
plt.title(f"Confusion Matrix for {model_name}")
plt.xlabel("Predicted")
plt.ylabel("Actual")
plt.show()

# Feature Importance (for tree-based models)
if hasattr(model, "feature_importances_"):
    feature_importances = model.feature_importances_
    plt.figure(figsize=(8, 6))
    sns.barplot(x=feature_importances, y=X.columns)
    plt.title(f"Feature Importance for {model_name}")
    plt.xlabel("Importance")
    plt.ylabel("Feature")
    plt.show()


