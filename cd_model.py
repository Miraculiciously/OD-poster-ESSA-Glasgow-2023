import pynetlogo
import pandas as pd
import os

def run_model_with_parameters(parameters):

    # Start a NetLogo instance
    netlogo = pynetlogo.NetLogoLink(gui=False, jvmargs=['-Xmx2G'])

    # Load your model
    netlogo.load_model('cd_6_3.nlogo')

    # Set input parameters
    netlogo.command(f'set saving {str(True).lower()}')

     # Set simuation parameters
    netlogo.command(f'set world-size-x {parameters["world_size_x"]}')
    netlogo.command(f'set world-size-y {parameters["world_size_y"]}')
    netlogo.command(f'set F {parameters["F"]}')
    # netlogo.command(f'set q {parameters["q"]}')
    netlogo.command(f'set radius {parameters["radius"]}')
    netlogo.command(f'set veloc {float(parameters["veloc"])}')
    netlogo.command(f'set steplength {parameters["steplength"]}')
    netlogo.command(f'set angle {parameters["angle"]}')

    # Setup the model
    netlogo.command('setup')

    # Get seed
    the_seed = int(netlogo.report('seed'))

    # Run the model with 'go' button which is a forever button
    netlogo.command('go')

    # Fetch culture data from files saved by NetLogo
    files = [os.path.join(f) for f in os.listdir() if f"culture_data_{the_seed}_" in f and f.endswith('.txt')]
    assert files, "The 'files' list is empty!"
    all_data = []


    for filename in sorted(files):  # Sorting makes sure data is processed in order of ticks
        try:
            df_temp = pd.read_csv(filename, header=None, names=['culture'])
            tick_num = int(filename.split('_')[3].replace('.txt', ''))  # filename structure: "culture_data_[seed]_[tick].txt"
            df_temp['tick'] = tick_num
            df_temp['turtle_id'] = df_temp.index
            all_data.append(df_temp)
            os.remove(filename)  # Delete the file after reading its content
        except IndexError:
            print(f"Error with filename: {filename}")
            continue
        except FileNotFoundError:
            print(f"File {filename} does not exist!")
            exit()

    # if not all_data:
    #     raise ValueError("No data files were read. Check the 'past runs' directory and file naming.")

    df = pd.concat(all_data, ignore_index=True)

    # df.to_csv(f"past runs/culture_data_{the_seed}.csv", index=False)

    print(f"Created file for seed {the_seed}...")
    netlogo.kill_workspace()

    return df
