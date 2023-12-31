import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import os
from tqdm import tqdm
from bc_optimise import MyModel
from bc_custom_cv import CustomCV
from sklearn.model_selection import KFold
from bc_error import error

def load_data(filepath):
    # Load data
    data = pd.read_csv(filepath)
    return data

def custom_cross_val_score(model, X, y, cv, error_func, params):
    kf = KFold(n_splits=cv)
    scores = []

    for train_index, test_index in kf.split(X):
        X_train, X_test = X[train_index], X[test_index]
        y_train, y_test = y[train_index], y[test_index]

        model.set_params(**params)
        model.fit(X_train, y_train)

        # Since your model generates the entire time-series prediction from parameters,
        # we do not need to use X_test and y_test for prediction, just for error calculation.
        score = error_func(params, y_test)
        scores.append(score)

    return np.array(scores)

if __name__ == '__main__':
    # Define the path to data file
    filepath = 'random_data_training.csv'

    # Set working directory
    os.chdir(os.path.dirname(os.path.realpath(__file__)))

    # Load training data
    y_train = load_data(filepath)

    # If y_train is a DataFrame with a single column, convert it to a 1D numpy array
    if isinstance(y_train, pd.DataFrame) and y_train.shape[1] == 1:
        y_train = y_train.values.ravel()

    # Split your training data into X and y
    X_train = np.ones((y_train.shape[0], 1))  # If you don't have separate input data

    model = MyModel()

    # Define a range for n_splits
    n_splits_range = list(range(2, 12))

    # List to store the mean cross-validated score for each value of n_splits
    cv_scores_mean = []
    cv_scores_std = []

    # Params for the model, found through some parameter optimisation

    # (Hyperparameter tuning (as finding n_splits) aims to optimize
    # model's learning parameters and is largely independent of the
    # cross-validation structure (n_splits), which is a methodological
    # choice for performance assessment and doesn't directly affect
    # the model learning process.)
    params = {
        "original": True,
        "communication_regime": "HK (select all)",
        "number_of_agents": 200,
        "extremism_range": 0.04,
        "extremism_type": "one side",
        "alpha": 3.21,
        "beta": 1.21,
        "entry_exit_rate": 0.02,
        "min_eps": 0.1,
        "max_eps": 0.85
    }


    # Loop over n_splits_range and for each value, perform cross-validation and then compute the mean score
    for n_splits in tqdm(n_splits_range):
        cv_scores = custom_cross_val_score(model, X_train, y_train, cv=n_splits, error_func=error, params=params)
        cv_scores_mean.append(np.mean(cv_scores))
        cv_scores_std.append(np.std(cv_scores))

    cv_scores_mean = np.array(cv_scores_mean)
    cv_scores_std = np.array(cv_scores_std)

    # Plot the validation curve
    plt.figure(figsize=(10, 6))
    plt.plot(n_splits_range, cv_scores_mean, color='blue', marker='o', markersize=5, label='mean cross-validated error')
    plt.fill_between(n_splits_range, cv_scores_mean - cv_scores_std, cv_scores_mean + cv_scores_std, alpha=0.15, color='blue')
    plt.title('Validation curve')
    plt.xlabel('n_splits')
    plt.ylabel('Cross-validated error')
    plt.grid()
    plt.legend(loc='upper right')

    min_mean_idx = np.argmin(cv_scores_mean) # Find index where mean score is minimum
    optimal_n_splits = n_splits_range[min_mean_idx] # Find the n_splits value corresponding to this index
    std_at_min_mean = cv_scores_std[min_mean_idx] # Fetch the standard deviation corresponding to this minimum mean
    
    print(f"The optimal number of splits is: {optimal_n_splits}")
    print(f"The error at this split is: {cv_scores_mean[min_mean_idx]}")
    print(f"The standard deviation at this split is: {std_at_min_mean}")
    
    plt.show()

