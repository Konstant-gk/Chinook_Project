import pandas as pd
import matplotlib as plt
import numpy as np
import seaborn as snb
from sklearn.model_selection import cross_val_score, train_test_split, GridSearchCV
from sklearn.ensemble import RandomForestClassifier
from sklearn.tree import DecisionTreeClassifier
from sklearn.svm import SVC
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score

print("All libraries imported successfully!")

df = pd.read_csv('Query_Join_Tables_Chinook.csv')
df.fillna(0, inplace=True)
