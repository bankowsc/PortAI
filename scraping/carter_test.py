import pandas as pd
import glob
import joblib
import re

from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score

# ------------------------
# LOAD MULTIPLE CSV FILES
# ------------------------

files = glob.glob("transfer_247_data/transfer_portal_247_20*.csv")
df_list = [pd.read_csv(file) for file in files]
data = pd.concat(df_list, ignore_index=True)

# ------------------------
# CLEAN DATA
# ------------------------

# Remove useless columns
data = data.drop(columns=["institution_key","profile_url", "name", "status"])

# Convert rating
data["rating"] = data["rating"].replace("( N/A )", None)
data["rating"] = pd.to_numeric(data["rating"], errors="coerce")

# Convert height
def convert_height(h):
    if pd.isna(h):
        return None
    match = re.match(r"(\d+)'(\d+)", h)
    if match:
        feet = int(match.group(1))
        inches = int(match.group(2))
        return feet * 12 + inches
    return None

data["height"] = data["height"].apply(convert_height)

# Convert weight
data["weight"] = data["weight"].str.replace(" lbs", "")
data["weight"] = pd.to_numeric(data["weight"], errors="coerce")

# Remove rows with missing values
data = data.dropna()

# ------------------------
# SET TARGET
# ------------------------

TARGET_COLUMN = "to_school"

y = data[TARGET_COLUMN]
X = data.drop(TARGET_COLUMN, axis=1)

# ⚠️ Prevent leakage
# If team == to_school in your dataset, drop it
if "team" in X.columns:
    X = X.drop(columns=["team"])

# Convert categorical variables
X = pd.get_dummies(X, drop_first=True)

# ------------------------
# TRAIN TEST SPLIT
# ------------------------

X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42
)

# ------------------------
# TRAIN MODEL
# ------------------------

model = RandomForestClassifier(
    n_estimators=300,
    max_depth=None,
    random_state=42
)

model.fit(X_train, y_train)

# ------------------------
# EVALUATE
# ------------------------

y_pred = model.predict(X_test)
accuracy = accuracy_score(y_test, y_pred)

print("Model Accuracy:", accuracy)

# ------------------------
# SAVE MODEL
# ------------------------

joblib.dump(model, "to_school_model.pkl")
joblib.dump(X.columns.tolist(), "model_columns.pkl")

print("Model saved successfully!")
