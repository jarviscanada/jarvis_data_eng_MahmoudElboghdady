# Home Credit Default Risk — Credit Scoring Model

Module 1 capstone (Jarvis ML stream) · Mahmoud Elboghdady

An end-to-end credit scoring project on the Kaggle Home Credit dataset: from raw loan applications to a saved scikit-learn pipeline that predicts which applicants will have payment difficulties, with SHAP explanations, adverse action reasons, PSI monitoring and model documentation.

## Results

Test set: 61,503 applications the model never saw (8.07% default rate).

| Model | AUROC | Gini | KS | AUPRC | 5-fold CV AUROC |
|---|---|---|---|---|---|
| Logistic Regression (baseline) | 0.751 | 0.502 | 0.376 | 0.236 | 0.747 ± 0.002 |
| Random Forest | 0.744 | 0.488 | 0.365 | 0.223 | 0.739 ± 0.002 |
| Gradient Boosting | 0.768 | 0.536 | 0.401 | 0.259 | 0.762 ± 0.002 |
| **Gradient Boosting (tuned)** | **0.771** | **0.541** | **0.407** | **0.263** | **0.765 ± 0.001** |
| Production pipeline (raw CSV in) | 0.768 | 0.536 | 0.402 | 0.257 | |

Required minimum AUROC: 0.72 ✔

## Project structure

```
ml_credit_scoring/
├── data/                  Kaggle CSVs go here (not committed, see data/README.md)
├── notebooks/
│   ├── 01_eda.ipynb                  Exploration and visualization
│   ├── 02_preprocessing.ipynb        Sentinel fixes, missing indicators, imputation
│   ├── 03_feature_engineering.ipynb  Engineered + bureau features, encoding, clustering
│   ├── 04_modeling.ipynb             3 models, comparison, CV, hyperparameter tuning
│   ├── 05_explainability.ipynb       Metrics, SHAP, adverse action, PSI monitoring
│   └── 06_pipeline.ipynb             Production Pipeline on raw data, save, hash
├── src/
│   ├── features.py        Sentinel fix, application features, bureau aggregates
│   └── metrics.py         AUROC / Gini / KS / AUPRC / F1, PSI
├── models/                best_model.pkl, credit_scoring_pipeline.pkl, shap_values.npy
├── reports/               model_documentation.md, tuned_params.json, artifact_hashes.csv
└── requirements.txt
```

## How to reproduce

**1. Install** (Python 3.10+)

```bash
python -m venv .venv
source .venv/bin/activate          # Windows: .venv\Scripts\activate
pip install -r requirements.txt
```

**2. Get the data.** Download from [Kaggle](https://www.kaggle.com/c/home-credit-default-risk/data) (accept the competition rules first) and put `application_train.csv` and `bureau.csv` in `data/`:

```bash
kaggle competitions download -c home-credit-default-risk -p data/
unzip data/home-credit-default-risk.zip -d data/
```

**3. Run the notebooks in order** (01 → 06). Each one reads what the previous one saved. From the command line:

```bash
cd notebooks
for nb in 0*.ipynb; do jupyter nbconvert --to notebook --execute --inplace "$nb" --ExecutePreprocessor.timeout=-1; done
```

Notebook 04 (randomized search, 150 fits) takes about an hour; the rest run in a few minutes.

## Use the saved model

Run from the project root so `src/` can be imported (the pipeline's feature step lives there):

```python
import joblib, pandas as pd

pipeline = joblib.load("models/credit_scoring_pipeline.pkl")
applications = pd.read_csv("data/application_train.csv", nrows=5).drop(columns="TARGET")
pipeline.predict_proba(applications)[:, 1]     # default risk score
```

The pipeline takes raw application rows (missing values, placeholder values and text included) and ignores `SK_ID_CURR` and `CODE_GENDER`. Scores are risk rankings: `class_weight="balanced"` inflates them, so they are not calibrated probabilities.

## Key decisions

- **Same split everywhere** (80/20, stratified, seed 42); fill values and frequency maps are learned on the training rows only.
- **`DAYS_EMPLOYED = 365243`** is a code for pensioners/unemployed → missing + flag. The one income of 117,000,000 is treated as a data error → missing.
- **Nothing dropped for being missing.** Missing indicators alone reach AUROC 0.586, so they stay as features.
- **Sex is not a model input** (prohibited ground for credit decisions).
- **One definition of each feature** (`src/features.py`) used by both the research model and the production pipeline.

## Limitations

No application dates (no out-of-time test) · heavy reliance on external bureau scores · bureau aggregates not in the production pipeline yet · scores are not calibrated probabilities. Details in [`reports/model_documentation.md`](reports/model_documentation.md).
