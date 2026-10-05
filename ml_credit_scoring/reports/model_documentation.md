# Model Documentation — Home Credit Default Risk Scorecard

*Model validation summary (SR 11-7 / OSFI E-23 style). Author: Mahmoud Elboghdady. Every number below comes from the notebooks in `notebooks/` and the files in `reports/`.*

## 1. Purpose

The model estimates the probability that a consumer-loan applicant will have **payment difficulties** (`TARGET = 1`), using only information available when the application is made. It supports the **approve / refer / decline** decision for new cash and revolving loans. It does not predict fraud, loss amounts (LGD) or macroeconomic shocks.

## 2. Data

| | |
|---|---|
| Source | Kaggle *Home Credit Default Risk* — `application_train.csv` (307,511 applications, 122 columns) and `bureau.csv` (1.7M external credit lines) |
| Target | 8.07% default rate (imbalance 1 : 11.4) |
| Period | Not stated in the data: every date is a day offset relative to the application, so there is no calendar period |
| Split | 80/20 stratified random split, seed 42 — 246,008 train / 61,503 test, the same in every notebook |
| Data hash | SHA-256 of `application_train.csv`: `52e96b89…d784f5f` (full value in `reports/artifact_hashes.csv`) |

**Data quality handled:** `DAYS_EMPLOYED = 365243` placeholder for 55,374 pensioners/unemployed (18%) → missing + flag; 67 columns with missing values (41 above 50%), mostly housing fields → median/mode imputation fitted on training rows, plus 58 missingness flags; no duplicate applicants; 4 rows with gender `XNA` (irrelevant, gender is not an input).

## 3. Methodology

**Features.**
- 8 application features (`src/features.py`): credit/income, annuity/income, annuity/credit (`CREDIT_TERM`), employment/age ratio, income per family member, mean and std of the three external bureau scores, age.
- 4 bureau aggregates + a no-history flag (research model only): number of credit lines, active lines, average credit age, worst overdue amount.
- Encoding: ordinal (education), one-hot (< 10 levels), frequency (`OCCUPATION_TYPE`, `ORGANIZATION_TYPE`). 223 model features.
- **Excluded on purpose:** `CODE_GENDER` (prohibited ground; kept aside only to test fairness) and `SK_ID_CURR` (an ID).

**Models compared** (test set, same split):

| Model | AUROC | Gini | KS | AUPRC | 5-fold CV AUROC |
|---|---|---|---|---|---|
| Logistic Regression (C = 0.1), baseline | 0.751 | 0.502 | 0.376 | 0.236 | 0.748 ± 0.002 |
| Random Forest (200 trees, depth 10) | 0.744 | 0.488 | 0.366 | 0.223 | 0.739 ± 0.002 |
| Gradient Boosting (untuned) | 0.767 | 0.535 | 0.400 | 0.260 | 0.762 ± 0.002 |
| **Gradient Boosting (tuned) — research model** | **0.770** | **0.541** | **0.404** | **0.262** | **0.765 ± 0.001** |

All models use `class_weight="balanced"`. Tuning: `RandomizedSearchCV`, 50 configurations × 3 folds on AUROC. Chosen: `learning_rate 0.059, max_iter 234, max_leaf_nodes 35, min_samples_leaf 92, l2_regularization 8.57`. Tuning added +0.003 AUROC on the test set.

**Production model** (`models/credit_scoring_pipeline.pkl`): one scikit-learn `Pipeline` — feature step → `ColumnTransformer` (numeric: median imputer with missing flags + `StandardScaler`; categorical: most-frequent imputer + `OneHotEncoder(handle_unknown="ignore")`) → `HistGradientBoostingClassifier` with the tuned parameters. It takes **raw** application rows and is fitted on the 246,008 training rows.

## 4. Performance (shipped pipeline, 61,503 test applications)

| Metric | Value | 95% bootstrap CI | Benchmark |
|---|---|---|---|
| AUROC | **0.768** | 0.761 – 0.775 | minimum 0.72 · baseline LR 0.751 |
| Gini | 0.536 | 0.522 – 0.549 | typical retail 0.40 – 0.60 |
| KS | 0.401 | | acceptable > 0.30 |
| AUPRC | 0.257 | | random = 0.081 |

- **Stable:** 5-fold CV AUROC 0.765 ± 0.001 on the training rows, close to the test score, so no sign of overfitting.
- **Research vs production:** 0.770 (engineered matrix incl. bureau) vs 0.768 (raw rows, no bureau aggregates).
- **Calibration:** the raw score is a ranking score (inflated by class weighting). An isotonic calibrator (`models/pd_calibrator.pkl`), fitted on a hold-out slice of the training rows, gives a mean PD of 8.16% vs 8.07% observed. Riskiest decile defaults at 28.3%, safest at 1.0%.

## 5. Explainability

Top 10 features by mean |SHAP| (TreeExplainer, 1,000 test applicants): `EXT_SOURCE_MEAN`, `CREDIT_TERM`, `AMT_GOODS_PRICE`, `NAME_EDUCATION_TYPE`, `AMT_ANNUITY`, `EXT_SOURCE_1_MISSING`, `BUREAU_RECORD_COUNT`, `DAYS_EMPLOYED`, `BUREAU_ACTIVE_COUNT`, `AMT_CREDIT`. Five of the ten were engineered in this project.

Sample adverse action notice (notebook 05), top 4 reasons from the high-risk applicant's SHAP values:
1. ID document issued 331 days ago (repaid applicants typically ~9 years)
2. 2 people in the applicant's social circle were 60+ days overdue (typically 0)
3. Yearly payment 34,205 (typically 24,876)
4. Short employment relative to age (ratio 0.03 vs 0.09)

## 6. Limitations and known weaknesses

1. **No calendar dates** → no true out-of-time test. An ID-ordered proxy shows AUROC within 0.761–0.774, but performance in a recession or after a policy change is unknown.
2. **Heavy dependence on external bureau scores** (`EXT_SOURCE_*`): if that feed fails or is re-scaled, accuracy drops sharply. It must be monitored first.
3. **Bureau aggregates are not in the production pipeline** — they need a second table at scoring time (a feature-store lookup on `SK_ID_CURR`).
4. **Weaker ranking for older applicants**: AUROC 0.735 for ages 60–70 and 0.738 for pensioners (still above 0.72).
5. **Fairness:** age four-fifths ratio 0.82 at a 10% decline rate — passes, but close to the 0.80 line. Gender ratio 0.95. Proxies for protected attributes may exist.
6. **Business assumptions:** LGD 45% and margin 3% are assumptions (no recovery data); results are shown across a sensitivity grid.
7. **Only 2 of 7 tables used**; previous applications, instalments and card balances are not yet used.

## 7. Monitoring plan

| What | How often | Trigger |
|---|---|---|
| PSI on the score and on the top-10 SHAP features | monthly | > 0.10 investigate, **> 0.25 review / retrain** |
| AUROC, Gini, KS on loans that reached 12 months | quarterly | AUROC < 0.72 or a drop of > 0.03 |
| Calibration (predicted vs actual default by decile) | quarterly | mean PD off by > 20% relative |
| Approval rate and four-fifths ratios (gender, age) | monthly | ratio < 0.80 |
| Missing rate of `EXT_SOURCE_*` and other key inputs | daily | sudden jump (feed outage) |

Scheduled full redevelopment every 12 months, or earlier on any trigger.

## 8. Reproducibility

Code in git; `requirements.txt` pinned; seed 42 everywhere; the same 80/20 split in every notebook; 10 unit tests (`pytest`); data and model SHA-256 in `reports/artifact_hashes.csv`.
