from abaqus import *
from abaqusConstants import *
import os
from odbAccess import *

def run_analysis(mesh_size):
    """
    Run ABAQUS analysis with specified mesh size and extract results
    
    Args:
        mesh_size (float): Global mesh seed size
    
    Returns:
        dict: Dictionary containing results
    """
    model = mdb.models['Model-1']
    part = model.parts['Part-1']  # Update with your part name
    
    # Delete existing mesh
    part.deleteMesh()
    
    # Set new mesh size
    part.seedPart(size=mesh_size, deviationFactor=0.1, minSizeFactor=0.1)
    part.generateMesh()
    
    # Get element count
    element_count = len(part.elements)
    
    # Run the job
    job_name = f'Job-mesh-{mesh_size}'
    mdb.Job(name=job_name, model='Model-1')
    mdb.jobs[job_name].submit()
    mdb.jobs[job_name].waitForCompletion()
    
    # Open output database
    odb = openOdb(path=job_name + '.odb')
    last_frame = odb.steps['Step-1'].frames[-1]  # Update with your step name
    
    # Get von Mises stress
    stress_field = last_frame.fieldOutputs['S']
    mises = stress_field.getScalarField(invariant=MISES)
    max_mises = max([value.data for value in mises.values])
    
    # Get displacement magnitude
    displacement_field = last_frame.fieldOutputs['U']
    max_displacement = max([((value.data[0])**2 + 
                           (value.data[1])**2 + 
                           (value.data[2])**2)**0.5 
                          for value in displacement_field.values])
    
    odb.close()
    
    return {
        'mesh_size': mesh_size,
        'element_count': element_count,
        'max_mises': max_mises,
        'max_displacement': max_displacement
    }

def main():
    # Define mesh sizes to analyze
    mesh_sizes = [10.0, 5.0, 2.5, 1.0]  # Update with your desired mesh sizes
    
    # Create results file
    with open('analysis_results.csv', 'w') as f:
        f.write('Mesh Size,Element Count,Max von Mises,Max Displacement\n')
        
        # Run analysis for each mesh size
        for mesh_size in mesh_sizes:
            results = run_analysis(mesh_size)
            
            # Write results to file
            f.write(f"{results['mesh_size']},{results['element_count']},"
                   f"{results['max_mises']},{results['max_displacement']}\n")
            
if __name__ == "__main__":
    main()
