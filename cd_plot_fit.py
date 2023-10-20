import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
import seaborn as sns
from scipy.interpolate import interp1d
from itertools import groupby

def remove_trailing_duplicates(lst):
    grouped = [(key, list(group)) for key, group in groupby(lst[::-1])]
    cleaned = [g[0] for g in grouped]
    return cleaned[::-1]

def transform_df(data, column_name='culture'):
    data[column_name] = data[column_name].apply(lambda x: [int(i) for i in x[1:-1].split()])
    new_data = pd.DataFrame(data[column_name].to_list())
    new_data.columns = ['culture_' + str(i) for i in new_data.columns]
    return new_data

def plot_fit(predictions, y_val):
    model_data = pd.concat([
        transform_df(predictions['culture'].to_frame(), 'culture'),
        predictions['tick'].to_frame()
    ], axis=1)

    model_data.iloc[:, :-1] = model_data.iloc[:, :-1] / 4.0

    model_data = model_data.groupby('tick').agg(
        {col: ['mean'] for col in model_data.columns[:-1]}
    ).reset_index()

    model_data.columns = ['tick'] + [
        f'{col}_{agg_func}' for col, agg_func in model_data.columns[1:]
    ]

    y_val = np.ravel(y_val)

    x_common = np.linspace(0, 1, 200)
    x_val_ticks = np.linspace(0, 1, len(y_val))
    
    f_val = interp1d(x_val_ticks, y_val, kind='linear', fill_value='extrapolate')
    y_val_interpolated = f_val(x_common)

    sns.set_palette("colorblind")
    mean_columns = [col for col in model_data.columns if '_mean' in col]

    for col in mean_columns:
        # Remove trailing duplicates using your function
        x_mean = model_data[col].values.ravel()
        x_mean = remove_trailing_duplicates(x_mean)
        
        # Create a matching tick array for x_mean, making sure it's normalized
        x_mean_ticks = np.linspace(0, 1, len(x_mean))
        
        # Create an interpolating function based on cleaned data
        interpolating_function = interp1d(x_mean_ticks, x_mean, kind='linear', fill_value='extrapolate')
        
        # Interpolate the cleaned data onto the common axis
        y_model_interpolated = interpolating_function(x_common)
        
        plt.plot(x_common, y_model_interpolated, label=col)

    plt.plot(x_common, y_val_interpolated, label='Validation Data', linestyle='--')
    plt.xlabel('Tick')
    plt.ylabel('Culture Mean Value')
    plt.legend()
    plt.title('Culture Mean Value Over Time')
    plt.tight_layout()
    
    plt.show()
