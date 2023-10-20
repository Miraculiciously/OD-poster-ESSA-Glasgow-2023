import pynetlogo
import pandas as pd
import numpy as np

def run_model_with_parameters(parameters):

    # Start a NetLogo instance
    netlogo = pynetlogo.NetLogoLink(gui=False)

    # Load your model
    netlogo.load_model('bc_6_3.nlogo')

    # Set input parameters
    netlogo.command(f'set original {str(parameters["original"]).lower()}')
    netlogo.command(f'set communication_regime "{parameters["communication_regime"]}"')
    netlogo.command(f'set number_of_agents {parameters["number_of_agents"]}')
    netlogo.command(f'set extremism_range {parameters["extremism_range"]}')
    netlogo.command(f'set alpha {float(parameters["alpha"])}')
    netlogo.command(f'set beta {parameters["beta"]}')
    netlogo.command(f'set entry_exit_rate {parameters["entry_exit_rate"]}')
    netlogo.command(f'set min_eps {parameters["min_eps"]}')
    netlogo.command(f'set max_eps {parameters["max_eps"]}')
    netlogo.command(f'set extremism_type "{parameters["extremism_type"]}"')

    # Setup the model
    netlogo.command('setup')

    # Run the model with 'go' button which is a forever button
    netlogo.command('go')

    # Gather the output as a pandas dataframe
    opinions = np.array(netlogo.report('[opinion] of turtles'))
    data = {"[opinion] of turtles": opinions}
    data_frame = pd.DataFrame(data)

    # Remember to kill the link when you're done
    netlogo.kill_workspace()

    return data_frame
