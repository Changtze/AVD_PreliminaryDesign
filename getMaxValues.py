from odbAccess import *
import csv
import os
import glob  # For finding multiple ODB files

def extract_max_values(odbPath):
    try:
        odb = openOdb(path=odbPath)
        step = odb.steps['Step-1']  # Replace 'Step-1' if necessary
        frame = step.frames[-1]  # Last frame

        # # --- Extract Maximum Displacement ---
        # displacementData = frame.fieldOutputs['U']
        # displacementValues = displacementData.values
        # maxDisplacement = 0.0
        # for disp in displacementValues:
        #     magnitude = sqrt(disp.data[0]**2 + disp.data[1]**2 + disp.data[2]**2)
        #     maxDisplacement = max(maxDisplacement, magnitude)

        # --- Extract Maximum Von Mises Stress ---
        stressData = frame.fieldOutputs['S']
        stressValues = stressData.values
        maxVonMises = 0.0
        for stress in stressValues:
            if hasattr(stress, 'mises'):
                maxVonMises = max(maxVonMises, stress.mises)

        #  --- Extract mesh count ---
        odb.close()
        return maxVonMises, odbPath  # Return ODB path too

    except Exception as e:
        print(f"Error processing {odbPath}: {e}")
        return None, None, odbPath  # Return None if error


def write_to_csv(results, outputFileName):
    file_exists = os.path.exists(outputFileName) # check if file exists
    with open(outputFileName, 'a', newline='') as csvfile:  # Append mode
        writer = csv.writer(csvfile)
        if not file_exists: # write header only if file is new
            writer.writerow(['ODB File', 's_max'])  # Header row

        for odbPath, maxVonMises in results:
          if maxVonMises is not None: # write data only if extraction was successful
            writer.writerow([odbPath, maxVonMises])


# --- Main script ---

# 1. Find ODB files (using glob)
odbFiles = glob.glob('*.odb')  # Finds all .odb files in the current directory
# or specify the path:
# odbFiles = glob.glob('/path/to/odb/files/*.odb')

if not odbFiles:
    print("No ODB files found in the specified directory.")
    exit()

outputFileName = 'max_values_results.csv'
results_list = []

for odbFile in odbFiles:
    maxVM, odbPath = extract_max_values(odbFile)
    results_list.append((odbPath, maxVM))

write_to_csv(results_list, outputFileName)

print(f"Results saved to {outputFileName}")