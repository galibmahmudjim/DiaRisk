import joblib
import pandas as pd
import numpy as np
from sklearn.calibration import CalibratedClassifierCV
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.ensemble import RandomForestClassifier
import pickle
import xgboost as xgb
import lightgbm as lgb
from sklearn.ensemble import GradientBoostingClassifier
from sklearn.linear_model import LogisticRegression
from sklearn.ensemble import VotingClassifier

import os
from pathlib import Path

# Set random seed for reproducibility
np.random.seed(42)

def create_ensemble_model(X_train, y_train):
    # Initialize base models
    xgb_model = xgb.XGBClassifier(
        n_estimators=100,
        learning_rate=0.1,
        max_depth=5,
        random_state=42
    )
    
    lgb_model = lgb.LGBMClassifier(
        n_estimators=100,
        learning_rate=0.1,
        max_depth=5,
        random_state=42
    )
    
    rf_model = RandomForestClassifier(
        n_estimators=100,
        max_depth=5,
        random_state=42
    )
    
    gb_model = GradientBoostingClassifier(
        n_estimators=100,
        learning_rate=0.1,
        max_depth=5,
        random_state=42
    )
    
    lr_model = LogisticRegression(
        C=1.0,
        max_iter=1000,
        random_state=42
    )
    
    # Create voting classifier
    ensemble = VotingClassifier(
        estimators=[
            ('xgboost', xgb_model),
            ('lightgbm', lgb_model),
            ('random_forest', rf_model),
            ('gradient_boosting', gb_model),
            ('logistic_regression', lr_model)
        ],
        voting='soft'  
    )
    
    
    return ensemble

def load_data():
    data_path = "./datasets/processed/diabetes_012_health_indicators.csv"
    
    df = pd.read_csv(data_path)
    
    # Separate features and target
    X = df[['BMI', 'Stroke', 'HeartDiseaseorAttack', 'Sex', 'Age']]
    y = df['Diabetes_012']
    
    return X, y

def train_model():
    print("Loading data...")
    X, y = load_data()
    
    # Scale the features
    scaler = StandardScaler()
    X_train_scaled = scaler.fit_transform(X)
    X_train_scaled = pd.DataFrame(X_train_scaled, columns=X.columns)
    print(X_train_scaled.columns)
    ensemble_model = create_ensemble_model(X_train_scaled, y)
    ensemble_model.fit(X_train_scaled, y)
    ensemble_model_data = {
        'model': ensemble_model,
        'scaler': scaler,
        'feature_names': list(X.columns)
    }
    
    # Calculate and print training accuracy
    train_accuracy = ensemble_model_data['model'].score(X_train_scaled, y)
    print(f"Training accuracy: {train_accuracy:.4f}")
    
    # Save the model and scaler
    model_dir = Path(__file__).parent / "models"
    model_dir.mkdir(exist_ok=True)
    model_path = model_dir / "diaHealth_012.joblib"
    
    print(f"Saving model to {model_path}...")
    with open(model_path, 'wb') as f:
        joblib.dump(ensemble_model_data, f, protocol=4)
    print("Model saved successfully!")

if __name__ == "__main__":
    train_model()


# from pydoc import cli
# from statistics import variance
# import pandas as pd
# import numpy as np
# import pandas as pd
# import numpy as np
# import seaborn as sns
# from sklearn.calibration import LabelEncoder
# import xgboost as xgb
# import lightgbm as lgb
# from sklearn.model_selection import train_test_split, GridSearchCV, RandomizedSearchCV, StratifiedKFold
# from sklearn.preprocessing import OneHotEncoder, StandardScaler, MinMaxScaler
# from sklearn.impute import KNNImputer, SimpleImputer
# from sklearn.tree import DecisionTreeClassifier
# from sklearn.decomposition import PCA
# from sklearn.feature_selection import RFE, VarianceThreshold
# from sklearn.ensemble import RandomForestClassifier, GradientBoostingClassifier, AdaBoostClassifier, VotingClassifier
# from sklearn.linear_model import Lasso, LogisticRegression
# from sklearn.svm import SVC
# import joblib
# import os


# data = "diabetes_012_health_indicators.csv"




# def evaluate_model(model, X, y):
#     skf = StratifiedKFold(n_splits=5)
#     accuracy, precision, recall, f1, roc_auc, mcc = [], [], [], [], [], []
    
#     mean_fpr = np.linspace(0, 1, 100)  # To interpolate ROC curve

#     tprs = []  # Store true positive rates for each fold

#     for train_index, test_index in skf.split(X, y):
#         X_train, X_test = X[train_index], X[test_index]
#         y_train, y_test = y[train_index], y[test_index]
        
#         model.fit(X_train, y_train)
        
#         y_pred = model.predict(X_test)
#         y_prob = model.predict_proba(X_test)[:, 1]

#         # Compute evaluation metrics
#         accuracy.append(accuracy_score(y_test, y_pred))
#         precision.append(precision_score(y_test, y_pred))
#         recall.append(recall_score(y_test, y_pred))
#         f1.append(f1_score(y_test, y_pred))
#         mcc.append(matthews_corrcoef(y_test, y_pred))
        
#         # Compute ROC and AUC
#         fpr, tpr, _ = roc_curve(y_test, y_prob)
#         roc_auc.append(auc(fpr, tpr))

#         # Interpolate tpr and store it
#         tprs.append(np.interp(mean_fpr, fpr, tpr))
#         tprs[-1][0] = 0.0

#     # Plotting the ROC curve
    
#     mean_tpr = np.mean(tprs, axis=0)
#     mean_tpr[-1] = 1.0
#     mean_auc = auc(mean_fpr, mean_tpr)


#     prettytable = PrettyTable(['Accuracy', 'Precision', 'Recall', 'AUC'])
#     prettytable.add_row([np.mean(accuracy), np.mean(precision), np.mean(recall), np.mean(roc_auc)])
#     print(prettytable)
    
#     cm = conf(y_test, y_pred)
#     disp = cmd(confusion_matrix=cm)
#     disp.plot()
    
#     return [str(model), np.mean(accuracy), np.mean(precision), np.mean(recall), np.mean(roc_auc)]


# def label_encode(data):
#     label_encoder = LabelEncoder()
#     for col in data.columns:
#         if data[col].dtype == 'object':
#             data[col] = label_encoder.fit_transform(data[col])
#             mapping = dict(zip(label_encoder.classes_, label_encoder.transform(label_encoder.classes_)))
#     return data

# def create_ensemble_model(X_train, y_train):
#     # Initialize base models
#     xgb_model = xgb.XGBClassifier(
#         n_estimators=100,
#         learning_rate=0.1,
#         max_depth=5,
#         random_state=42
#     )
    
#     lgb_model = lgb.LGBMClassifier(
#         n_estimators=100,
#         learning_rate=0.1,
#         max_depth=5,
#         random_state=42
#     )
    
#     rf_model = RandomForestClassifier(
#         n_estimators=100,
#         max_depth=5,
#         random_state=42
#     )
    
#     gb_model = GradientBoostingClassifier(
#         n_estimators=100,
#         learning_rate=0.1,
#         max_depth=5,
#         random_state=42
#     )
    
#     lr_model = LogisticRegression(
#         C=1.0,
#         max_iter=1000,
#         random_state=42
#     )
    
#     # Create voting classifier
#     ensemble = VotingClassifier(
#         estimators=[
#             ('xgboost', xgb_model),
#             ('lightgbm', lgb_model),
#             ('random_forest', rf_model),
#             ('gradient_boosting', gb_model),
#             ('logistic_regression', lr_model)
#         ],
#         voting='soft'  
#     )
    
#     ensemble.fit(X_train, y_train)
#     if not os.path.exists('models'):
#         os.makedirs('models')
    
#     print("\nSaving the trained model...")
#     joblib.dump(ensemble, 'models/diaHealth_012.joblib')
    
#     return ensemble


# if __name__ == "__main__":
    
#       data_set = pd.read_csv(data)
#       X = data_set[['BMI', 'Stroke', 'HeartDiseaseorAttack', 'Sex', 'Age']]
#       y = data_set['Diabetes_012']
#       scaler = StandardScaler()
#       X = scaler.fit_transform(X)

#       model = create_ensemble_model(X, y)
# # age,gender,bmi,cardiovascular_disease,stroke,diabetic



# # BMI,Stroke,HeartDiseaseorAttack,Sex,Age,Diabetes_012




