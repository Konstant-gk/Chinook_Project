import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import seaborn as sns
from sklearn.ensemble import RandomForestClassifier
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score, confusion_matrix, f1_score, precision_score, recall_score
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder
from sklearn.preprocessing import StandardScaler
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


# Format AvgRevenue to 2 decimal places
df['AvgRevenue'] = df['AvgRevenue'].round(2)


# Fill any remaining NaN values with 0
df[['TotalRevenue', 'AvgRevenue', 'ReportsTo']] = df[['TotalRevenue', 'AvgRevenue', 'ReportsTo']].fillna(0)

# Calculate the total average per year (TotalRevenue / Tenure)
df['AnnualRevenue'] = (df['TotalRevenue'] / df['Tenure']).round(2)

# Round tenure to the nearest integer
df[['Tenure', 'ReportsTo']] = df[['Tenure', 'ReportsTo']].round().astype(int)

# Ensure all rows are displayed
# pd.set_option('display.max_rows', None)
# Sort 'TotalInvoices' in ascending order
# sorted_total_invoices = df['TotalInvoices'].sort_values(ascending=True)
# Print the sorted column
# print(sorted_total_invoices)

print(df.head(), "\n")

# Create a new DataFrame with only the required features
features = ['EmployeeId', 'Employee_Role', 'Sex', 'Employee_BirthDate', 'Employee_Age', 'Employee_HireDate', 'Tenure',
            'TotalInvoices', 'TotalRevenue', 'AvgRevenue', 'AnnualRevenue']

df_filtered = df[features]

# Display the first few rows of the new DataFrame
print(df_filtered.head())

# Remove outliers where 'Employee_Role' is not 'Sales Support Agent' and employeeId is 3,4,5
df_filtered2 = df_filtered[df_filtered['Employee_Role'] == 'Sales Support Agent']
df_final = df_filtered2[~df_filtered2['EmployeeId'].isin([3, 4, 5])]


# Display the first few rows of the filtered DataFrame
print(df_final.head())

# Define performance labels based on quantiles of 'TotalRevenue'
quantile_labels = ['Low Performer', 'Average Performer', 'High Performer']
df_final.loc[:,'Performance_Label'] = pd.qcut(df_final['TotalRevenue'], q=3, labels=quantile_labels)

# Create a dictionary to map labels to desired numbers
label_mapping = {'Low Performer': 0, 'Average Performer': 1, 'High Performer': 2}

# Map labels to numbers
df_final['Performance_Label_Encoded'] = df_final['Performance_Label'].map(label_mapping)

# Display the first few rows of the filtered DataFrame with the new labels
print(df_final[['EmployeeId', 'TotalRevenue', 'Performance_Label']].head(), "\n")


# Define X (features) and y (target)
X = df_final[['Employee_Age', 'TotalInvoices', 'AvgRevenue', 'AnnualRevenue']]
y = df_final['Performance_Label_Encoded']

# Normalize/standardize the features using StandardScaler
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

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
print(y_pred_rf)
print(y_pred_dt)

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

pd.get_dummies(df_final['Sex'],"\n")
pd.get_dummies(df_final)