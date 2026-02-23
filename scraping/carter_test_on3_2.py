import pandas as pd
import joblib
import re

# ------------------------
# LOAD SAVED MODEL
# ------------------------

model = joblib.load("to_school_model_2.pkl")
model_columns = joblib.load("model_columns_2.pkl")

# ------------------------
# CREATE TEST PLAYER
# ------------------------

# ,,Position,Year/Class,,Date Entered Portal,From Team,,Rating,High School,

new_player = {
    "Position": "QB",
    "Year/Class": "SO",
    "Date Entered Portal": "2/23/2026",
    "From Team": "Notre Dame",
    "Rating": 94.00,
    "High School": "Saline",
}

df = pd.DataFrame([new_player])

# ------------------------
# CLEAN DATA SAME WAY
# ------------------------

# # Convert height
# def convert_height(h):
#     match = re.match(r"(\d+)'(\d+)", h)
#     if match:
#         return int(match.group(1)) * 12 + int(match.group(2))
#     return None

# df["height"] = df["height"].apply(convert_height)

# # Convert weight
# df["weight"] = df["weight"].str.replace(" lbs", "")
# df["weight"] = pd.to_numeric(df["weight"], errors="coerce")

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

top3_idx = np.argsort(probabilities[0])[-5:][::-1]
top3_schools = model.classes_[top3_idx]
top3_probs = probabilities[0][top3_idx]

print("\nTop 3 Predictions:")
for school, prob in zip(top3_schools, top3_probs):
    print(f"{school}: {prob:.2%}")
