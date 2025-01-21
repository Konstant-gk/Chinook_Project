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

print(df['Employee_Age'].value_counts())

print(df['Employee_Role'].value_counts())

print(df['TotalRevenue'].describe())

plt.hist(df['Employee_Age'], bins=20)
plt.show()
























