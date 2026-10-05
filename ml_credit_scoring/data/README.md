# data/

The Kaggle CSVs are **not** committed (several are over GitHub's 100 MB limit).

Download them from <https://www.kaggle.com/c/home-credit-default-risk/data> and put these two here:

| File | Used for |
|---|---|
| `application_train.csv` | one row per loan application + `TARGET` |
| `bureau.csv` | other credit lines per applicant, aggregated in notebook 03 |

The other five tables are not used yet.

Check: `pd.read_csv("data/application_train.csv").shape` should be `(307511, 122)`.

## Files the notebooks create here (git-ignored, regenerable)

| File | Written by |
|---|---|
| `cleaned_application_train.csv` | 02 — sentinel fixed, missing flags, imputed |
| `preprocessed_train.csv` | 03 — final model matrix (223 features + `SK_ID_CURR`, `TARGET`) |
