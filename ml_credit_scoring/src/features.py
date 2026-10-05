"""Feature engineering used by notebook 03 and by the shipped pipeline (notebook 06).

One definition, imported everywhere, so the research matrix and the production
pipeline can never build a feature two different ways.
"""

import numpy as np
import pandas as pd

SENTINEL = 365243  # DAYS_EMPLOYED placeholder for "unemployed / retired"

EXT_SOURCES = ["EXT_SOURCE_1", "EXT_SOURCE_2", "EXT_SOURCE_3"]

APPLICATION_FEATURES = [
    "AGE", "CREDIT_INCOME_RATIO", "ANNUITY_INCOME_RATIO", "CREDIT_TERM",
    "DAYS_EMPLOYED_RATIO", "INCOME_PER_PERSON", "EXT_SOURCE_MEAN", "EXT_SOURCE_STD",
]

BUREAU_FEATURES = [
    "BUREAU_RECORD_COUNT", "BUREAU_ACTIVE_COUNT", "BUREAU_DAYS_CREDIT_MEAN",
    "BUREAU_OVERDUE_MAX",
]


def fix_sentinels(df: pd.DataFrame) -> pd.DataFrame:
    """DAYS_EMPLOYED = 365243 means unemployed/retired, not 1,000 years of work."""
    return df.assign(DAYS_EMPLOYED=df["DAYS_EMPLOYED"].replace(SENTINEL, np.nan))


def add_application_features(df: pd.DataFrame) -> pd.DataFrame:
    """Add the 8 application-level features. Safe on raw rows (fixes the sentinel first).

    Denominators are clipped at 1 so a zero income or credit never produces inf.
    """
    df = fix_sentinels(df)
    ext = df[EXT_SOURCES]
    return df.assign(
        AGE=-df["DAYS_BIRTH"] / 365,
        CREDIT_INCOME_RATIO=df["AMT_CREDIT"] / df["AMT_INCOME_TOTAL"].clip(lower=1),
        ANNUITY_INCOME_RATIO=df["AMT_ANNUITY"] / df["AMT_INCOME_TOTAL"].clip(lower=1),
        CREDIT_TERM=df["AMT_ANNUITY"] / df["AMT_CREDIT"].clip(lower=1),
        DAYS_EMPLOYED_RATIO=df["DAYS_EMPLOYED"] / df["DAYS_BIRTH"],
        INCOME_PER_PERSON=df["AMT_INCOME_TOTAL"] / df["CNT_FAM_MEMBERS"].clip(lower=1),
        EXT_SOURCE_MEAN=ext.mean(axis=1),
        EXT_SOURCE_STD=ext.std(axis=1),
    )


def aggregate_bureau(bureau: pd.DataFrame) -> pd.DataFrame:
    """Collapse bureau.csv (many rows per applicant) to one row per SK_ID_CURR."""
    return bureau.groupby("SK_ID_CURR").agg(
        BUREAU_RECORD_COUNT=("SK_ID_BUREAU", "count"),
        BUREAU_ACTIVE_COUNT=("CREDIT_ACTIVE", lambda s: (s == "Active").sum()),
        BUREAU_DAYS_CREDIT_MEAN=("DAYS_CREDIT", "mean"),
        BUREAU_OVERDUE_MAX=("AMT_CREDIT_SUM_OVERDUE", "max"),
    )


def add_bureau_features(app: pd.DataFrame, bureau_agg: pd.DataFrame) -> pd.DataFrame:
    """Left-join the bureau aggregates. Applicants with no bureau file get
    counts/amounts of 0 and BUREAU_NO_HISTORY = 1. BUREAU_DAYS_CREDIT_MEAN stays
    NaN (0 would mean "credit opened today") and is imputed later like any column.
    """
    out = app.merge(bureau_agg, left_on="SK_ID_CURR", right_index=True, how="left")
    out["BUREAU_NO_HISTORY"] = out["BUREAU_RECORD_COUNT"].isna().astype(int)
    zero_fill = ["BUREAU_RECORD_COUNT", "BUREAU_ACTIVE_COUNT", "BUREAU_OVERDUE_MAX"]
    out[zero_fill] = out[zero_fill].fillna(0)
    return out
