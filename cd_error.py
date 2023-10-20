from scipy.spatial.distance import euclidean
from functools import partial
import numpy as np
import pandas as pd
from fastdtw import fastdtw
from numpy.linalg import norm
from itertools import groupby

def remove_trailing_duplicates(lst):
    # Reverse and group by consecutive duplicate elements
    grouped = [(key, list(group)) for key, group in groupby(lst[::-1])]
    
    # Take only one from each group
    cleaned = [g[0] for g in grouped]
    
    # Reverse again to get the desired list
    return cleaned[::-1]

# To do:
# - take individual culture values, erase stagnant values out - done
# - choose min of all distances - done
# - if cd is better than bc: Interesting inherent bas for model
#   because I don't punish it for having many, many cultures out of which
#   (by mere chance) one culture might fit best

def my_euclidean(x, y):
    return norm(x - y)

def transform_df(data, column_name = 'culture'):
    # Step 1: Convert string representation of lists to actual lists
    data[column_name] = data[column_name].apply(
        lambda x: [int(i) for i in x[1:-1].split()])
    
    # Step 2: Create a new DataFrame with separate columns
    new_data = pd.DataFrame(data[column_name].to_list())
    
    # Step 3: Set Column Names
    new_data.columns = ['culture_' + str(i) for i in new_data.columns]
    
    return new_data

def error(predictions, target_df):
    # Extract and transform predictions into workable data frame
    model_data = pd.concat([
        transform_df(predictions['culture'].to_frame(), 'culture'),
        predictions['tick'].to_frame()
        ], axis=1)

    # Step 2: Normalize the Data
    model_data.iloc[:, :-1] = model_data.iloc[:, :-1] / 4.0

    model_data = model_data.groupby('tick').agg(
        {col: ['mean', 'std'] for col in model_data.columns[:-1]}
    ).reset_index()

    # Flatten the MultiIndex columns and add '_mean' and '_std' suffixes
    model_data.columns = ['tick'] + [
        f'{col}_{agg_func}' for col, agg_func in model_data.columns[1:]
    ]

    if isinstance(target_df, pd.DataFrame): # make fit for single parameter run or receiving data frame
        target_data = target_df.values.ravel()
    else:
        target_data = target_df.ravel()

    distances = []

    # List of columns with '_mean' in their name
    mean_columns = [col for col in model_data.columns if '_mean' in col]

    # Number of such columns
    num_columns = len(mean_columns)

    for i in range(num_columns):
        # Compute the DTW distance
        x_mean = model_data[f'culture_{i}_mean'].values.ravel()
        x_mean = remove_trailing_duplicates(x_mean)

        distance, _ = fastdtw(target_data, x_mean, dist=my_euclidean)
        
        # Add the computed distance to the total distance
        distances.append(distance)

    return min(distances)