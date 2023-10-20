import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

import os
os.chdir(os.path.dirname(os.path.realpath(__file__)))

# Set the seed for reproducibility
np.random.seed(42)

# Assuming you have 100 turtles and 100 ticks, you might do something like:
num_ticks = 100

# Generate the data
data = np.random.uniform(low=0.0, high=1.0, size=(num_ticks,))

# Convert to a DataFrame
df_train = pd.DataFrame(data, columns=["Value"])

# Save the DataFrame to a CSV file
df_train.to_csv('random_data.csv', index=False)

# # Perturb the original data by up to 10% to create a validation dataset
# perturbation = np.random.uniform(low=-0.2, high=0.2, size=(num_ticks,))
# data_val = data + perturbation*data  # element-wise multiplication
# df_val = pd.DataFrame(data_val, columns=["Value"])

# # Save the validation DataFrame to a CSV file
# df_val.to_csv('random_data_validation.csv', index=False)

plt.figure(figsize=(10,6))
plt.plot(df_train)
# plt.plot(df_val)
plt.title('Random data plot')
plt.xlabel('Index')
plt.ylabel('Value')
plt.grid(True)
plt.show()