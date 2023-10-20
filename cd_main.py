import pandas as pd
from sklearn.model_selection import RandomizedSearchCV
import numpy as np
from functools import reduce

from cd_optimise import MyModel
from cd_custom_cv import CustomCV
from cd_plot_fit import plot_fit
from cd_error import error

import os
os.chdir(os.path.dirname(os.path.realpath(__file__)))

def load_data(filepath):
    # Load your data
    data = pd.read_csv(filepath)
    return data

def custom_discrete(low, high, step):
    return list(np.arange(low, high, step))

if __name__ == '__main__':
    # Load your training data
    y_train = load_data('random_data.csv').iloc[:, -1] # <class 'pandas.core.frame.DataFrame'>

    # Split your training data into X and y
    X_train = np.ones((y_train.shape[0], 1)) # If you don't have separate input data

    model = MyModel()

    # Define the parameter distributions
    param_grid = {
        "world_size_x": custom_discrete(10, 16, 5),
        "world_size_y": custom_discrete(10, 16, 5),
        "F": custom_discrete(2,16,1), # amount of cultures
        # "q": custom_discrete(1,5,1), # diversity of cultures
        "radius": custom_discrete(0.5, 5, 0.5),
        "veloc": custom_discrete(0, 1.1, 0.1),
        "steplength": custom_discrete(0.1, 1.1, 0.1),
        "angle": custom_discrete(0,360,1)
    }

    grid_size = reduce(lambda x, y: x * len(y), param_grid.values(), 1)
    # print(f"Size of the search space: {grid_size}")

    random_search = RandomizedSearchCV(model, param_distributions=param_grid,
                                   cv=CustomCV(n_splits=2),
                                   verbose=3, n_jobs=-1, n_iter=10)
    random_search.fit(X_train, y_train)

    # Load your validation data
    y_val = load_data('random_data.csv').iloc[:, -1] # or random_data_validation.csv

    # Use the best model to make predictions on the validation data
    best_model = random_search.best_estimator_
    X_val = np.ones((y_val.shape[0], 1)) # If you don't have separate input data for validation
    predictions = best_model.predict(X_val)

    error_value = error(predictions, y_val)

    print(f"error_value: {error_value}")

    # # Retrieve the and plot best estimator
    # plot_fit(predictions, y_val)

    # print(random_search.best_params_)