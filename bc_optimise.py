from sklearn.base import BaseEstimator, RegressorMixin

from bc_model import run_model_with_parameters
from bc_error import error

class MyModel(BaseEstimator, RegressorMixin):
    def __init__(self, original = "false", communication_regime = "HK (select all)", number_of_agents=50, extremism_range=0.1, extremism_type="one side", alpha=1, beta=1, entry_exit_rate=0.1, min_eps=0.1, max_eps=0.9):
        self.original = original
        self.communication_regime = communication_regime
        self.number_of_agents = number_of_agents
        self.extremism_range = extremism_range
        self.extremism_type = extremism_type
        self.alpha = alpha
        self.beta = beta
        self.entry_exit_rate = entry_exit_rate
        self.min_eps = min_eps
        self.max_eps = max_eps
        self.parameters = {
            'original': self.original,
            'communication_regime': self.communication_regime,
            'number_of_agents': self.number_of_agents,
            'extremism_range': self.extremism_range,
            'extremism_type': self.extremism_type,
            'alpha': self.alpha,
            'beta': self.beta,
            'entry_exit_rate': self.entry_exit_rate,
            'min_eps': self.min_eps,
            'max_eps': self.max_eps
        }


    def fit(self, X, y=None):
        self.parameters = {
            'original': self.original,
            'communication_regime': self.communication_regime,
            'number_of_agents': self.number_of_agents,
            'extremism_range': self.extremism_range,
            'extremism_type': self.extremism_type,
            'alpha': self.alpha,
            'beta': self.beta,
            'entry_exit_rate': self.entry_exit_rate,
            'min_eps': self.min_eps,
            'max_eps': self.max_eps
        }

        return self

    def predict(self, X):
        self.predictions_ = run_model_with_parameters(self.parameters)
        return self.predictions_


    def score(self, X, y):
        if hasattr(self, 'predictions_'):
            predictions = self.predictions_
        else:
            predictions = self.predict(X)
        return -error(predictions, y) # Note the negative sign because GridSearchCV tries to maximize the score
