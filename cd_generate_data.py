import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

import os
os.chdir(os.path.dirname(os.path.realpath(__file__)))

# Set the seed for reproducibility
np.random.seed(42)

num_ticks = 100

# Initialize the first data point between 0 and 1
data = [np.random.uniform(0, 1)]

# Generate normally distributed data
for _ in range(num_ticks-1):
    next_val = np.random.normal(data[-1], 0.05)  # Adjusted standard deviation
    
    # Clip the value to make sure it stays between 0 and 1
    next_val = max(0, min(next_val, 1))
    data.append(next_val)

data = np.array(data)

# Convert to a DataFrame
df_train = pd.DataFrame(data, columns=["Value"])

# Save the DataFrame to a CSV file
df_train.to_csv('random_data.csv', index=False)

# # Perturb the original data by up to 10% to create a validation dataset
# perturbation = np.random.uniform(low=-0.1, high=0.1, size=(num_ticks,))
# data_val = data + perturbation * data
# data_val = np.clip(data_val, 0, 1)   # Ensure values stay within [0, 1]
# df_val = pd.DataFrame(data_val, columns=["Value"])

# # Save the validation DataFrame to a CSV file
# df_val.to_csv('random_data_validation.csv', index=False)

# Plotting
plt.figure(figsize=(10,6))
plt.plot(df_train, label='Training')
# plt.plot(df_val, label='Validation')
plt.title('Random data plot')
plt.xlabel('Index')
plt.ylabel('Value')
plt.legend()
plt.grid(True)
plt.show()
