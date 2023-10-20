from fastdtw import fastdtw
from scipy.spatial.distance import euclidean
from functools import partial
import numpy as np
import pandas as pd

from bc_model import run_model_with_parameters

def my_metric(x, y, model_std, *args, **kwargs):
    model_median = np.median(x)
    model_mean = np.mean(x)
    if (abs(model_median - y) <= model_std).any() or (abs(model_mean - y) <= model_std).any():
        return 0
    else:
        return abs(x - y)

def error(predictions, target_df):
    model_data = predictions
    
    if isinstance(target_df, pd.DataFrame): 
        target_data = target_df.values.ravel()
    else:
        target_data = target_df.ravel()

    # x is model data, y is target data
    distance, _ = fastdtw(model_data, target_data, dist=partial(my_metric, model_std=np.std(model_data)))
    
    return distance


