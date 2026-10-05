"""Credit-risk metrics used by notebooks 04 to 06."""

import numpy as np
import pandas as pd
from sklearn.metrics import (average_precision_score, precision_recall_curve,
                             roc_auc_score, roc_curve)


def ks_statistic(y_true, y_prob) -> float:
    """Max gap between the cumulative score distributions of defaulters and payers."""
    fpr, tpr, _ = roc_curve(y_true, y_prob)
    return float((tpr - fpr).max())


def best_f1(y_true, y_prob):
    """Highest F1 over all thresholds, and the threshold that gives it."""
    precision, recall, thresholds = precision_recall_curve(y_true, y_prob)
    f1 = 2 * precision * recall / (precision + recall + 1e-9)
    i = int(np.argmax(f1[:-1]))  # the last PR point has no threshold
    return float(f1[i]), float(thresholds[i])


def evaluate(y_true, y_prob, name=None) -> pd.Series:
    """AUROC, Gini, KS, AUPRC and best F1 (with its threshold) as one row."""
    auroc = roc_auc_score(y_true, y_prob)
    f1, threshold = best_f1(y_true, y_prob)
    return pd.Series({
        "AUROC": auroc,
        "Gini": 2 * auroc - 1,
        "KS": ks_statistic(y_true, y_prob),
        "AUPRC": average_precision_score(y_true, y_prob),
        "F1": f1,
        "F1_threshold": threshold,
    }, name=name)


def psi(expected, actual, bins: int = 10) -> float:
    """Population Stability Index. <0.10 stable, 0.10-0.25 watch, >0.25 review.

    Bins are the deciles of `expected`; empty bins are floored at 1e-6 so the log
    never sees zero.
    """
    expected, actual = np.asarray(expected, float), np.asarray(actual, float)
    edges = np.unique(np.quantile(expected, np.linspace(0, 1, bins + 1)))
    edges[0], edges[-1] = -np.inf, np.inf
    e = np.clip(np.histogram(expected, edges)[0] / len(expected), 1e-6, None)
    a = np.clip(np.histogram(actual, edges)[0] / len(actual), 1e-6, None)
    return float(np.sum((a - e) * np.log(a / e)))
