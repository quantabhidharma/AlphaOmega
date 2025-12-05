import sys
import os
import numpy as np
import plotly.graph_objects as go

# Add parent directory to path so we can import 'src'
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from src.lattice import generate_twisted_walls
from src.dynamics import metropolis_with_walls
from src.observables import calculate_topological_charge_density

if __name__ == "__main__":
    L = 8
    T = 8
    beta = 5.5
    epsilon = 0.05
    steps = 200

    print("--- RUNNING: ALPHA-OMEGA VORTEX SIMULATION ---")
    lattice, walls = generate_twisted_walls(L, T)

    print("Cooling...")
    for s in range(steps):
        lattice, acc = metropolis_with_walls(lattice, beta, epsilon, walls)
        if s % 50 == 0: print(f"Step {s}...")

        # ... (rest of script) ...

        print("Measuring Topology...")
        q_map = calculate_topological_charge_density(lattice)

        # --- ROBUST SAVING FIX ---
        # 1. Define the path relative to this script
        data_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), '../data'))

        # 2. Create the directory if it doesn't exist
        os.makedirs(data_dir, exist_ok=True)

        # 3. Save
        np.save(os.path.join(data_dir, "vortex_lattice.npy"), lattice)
        np.save(os.path.join(data_dir, "vortex_charge.npy"), q_map)
        print(f"Data successfully saved to: {data_dir}")