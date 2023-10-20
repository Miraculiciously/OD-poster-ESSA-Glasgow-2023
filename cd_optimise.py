from sklearn.base import BaseEstimator, RegressorMixin

from cd_model import run_model_with_parameters
from cd_error import error

class MyModel(BaseEstimator, RegressorMixin):
    def __init__(self, world_size_x = 20, world_size_y = 20, F = 5, radius = 0.5, veloc = 1, steplength = 0.5, angle = 20, data_frame = None):
        self.world_size_x = world_size_x
        self.world_size_y = world_size_y
        self.F = F
        self.radius = radius
        self.veloc = veloc
        self.steplength = steplength
        self.angle = angle
        self.parameters = {
            'world_size_x': self.world_size_x,
            'world_size_y': self.world_size_y,
            'F': self.F,
            'radius': self.radius,
            'veloc': self.veloc,
            'steplength': self.steplength,
            'angle': self.angle
        }
        # Store the data frame
        self.data_frame = data_frame


    def fit(self, X, y=None):
        self.parameters = {
            'world_size_x': self.world_size_x,
            'world_size_y': self.world_size_y,
            'F': self.F,
            'radius': self.radius,
            'veloc': self.veloc,
            'steplength': self.steplength,
            'angle': self.angle
        }

        return self

    def predict(self, X):
        if self.data_frame is None:
            return run_model_with_parameters(self.parameters)
        else:
            return self.data_frame

    def score(self, X, y):
        predictions = self.predict(X)
        return -error(predictions, y) # Note the negative sign because GridSearchCV tries to maximize the score
