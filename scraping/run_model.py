import pandas as pd
import sys
import joblib
import re

# ------------------------
# LOAD SAVED MODEL
# ------------------------

model = joblib.load("to_school_model.pkl")
model_columns = joblib.load("model_columns.pkl")

# ------------------------
# CREATE TEST PLAYER
# ------------------------

SEASON = str(sys.argv[1])

POSITION = str(sys.argv[2])

TEMP = str(sys.argv[3])
HEIGHT = TEMP[0] + "'" + TEMP[2] + "\""

WEIGHT = str(sys.argv[4]) + "lbs"

STARS = str(sys.argv[5])

RATING = str(sys.argv[6])

FROM_SCHOOL = " ".join(sys.argv[7:])

new_player = {
    "season": SEASON,
    "position": POSITION,
    "height": HEIGHT,
    "weight": WEIGHT,
    "stars": STARS,
    "rating": RATING,
    "from_school": FROM_SCHOOL
}

df = pd.DataFrame([new_player])

# ------------------------
# CLEAN DATA SAME WAY
# ------------------------

# Convert height
def convert_height(h):
    match = re.match(r"(\d+)'(\d+)", h)
    if match:
        return int(match.group(1)) * 12 + int(match.group(2))
    return None

df["height"] = df["height"].apply(convert_height)

# Convert weight
df["weight"] = df["weight"].str.replace(" lbs", "")
df["weight"] = pd.to_numeric(df["weight"], errors="coerce")

# One-hot encode
df = pd.get_dummies(df)

# ------------------------
# MATCH TRAINING COLUMNS
# ------------------------

# for col in model_columns:
#     if col not in df.columns:
#         df[col] = 0
df = df.reindex(columns=model_columns, fill_value=0)

df = df[model_columns]

# ------------------------
# MAKE PREDICTION
# ------------------------

prediction = model.predict(df)
probabilities = model.predict_proba(df)

print("Predicted School:", prediction[0])

# Top 3 schools
import numpy as np

top3_idx = np.argsort(probabilities[0])[-3:][::-1]
top3_schools = model.classes_[top3_idx]
top3_probs = probabilities[0][top3_idx]

print("\nTop 3 Predictions:")
for school, prob in zip(top3_schools, top3_probs):
    print(f"{school}: {prob:.2%}")
