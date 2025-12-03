import sys
import os
import numpy as np

# Add src to path
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from src.lattice import generate_hot_start
from src.dynamics import metropolis_with_walls
from src.observables import calculate_polyakov_loops

if __name__ == "__main__":
    L = 8
    T = 8
    beta = 5.5
    epsilon = 0.2  # Larger steps for thermal fluctuation
    steps = 200

    print("--- POLYAKOV LOOP CONFINEMENT TEST ---")

    # 1. Initialize HOT (The Soup)
    # We want to start with a disordered vacuum to verify it STAYS disordered (Confined)
    print("Initializing Hot Bulk...")
    lattice = generate_hot_start(L, T)

    # 2. Apply Twisted Walls
    # We manually freeze the boundaries on top of the hot lattice
    print("Applying Twisted Boundary Conditions...")
    walls = [0, 4]

    # Wall A (Z=0): Identity
    for mu in range(4):
        lattice[:, :, :, 0, mu] = np.eye(3)

    # Wall B (Z=4): Twisted Center Element
    z_phase = np.exp(2j * np.pi / 3.0)
    for mu in range(4):
        lattice[:, :, :, 4, mu] = np.eye(3) * z_phase

    # 3. Run Thermalization (Not Cooling!)
    # We use standard Metropolis to maintain quantum fluctuations
    print(f"Thermalizing with Fixed Walls ({steps} steps)...")

    for s in range(1, steps + 1):
        lattice, acc = metropolis_with_walls(lattice, beta, epsilon, walls)
        if s % 50 == 0:
            print(f"Step {s} | Acc: {acc:.1%}")

    # 4. Measure Confinement
    print("\n--- Measuring Order Parameter |P| ---")
    P_field = calculate_polyakov_loops(lattice)
    P_abs = np.abs(P_field)

    # 5. Analysis
    print("\nZ-Axis Profile of |P|:")
    print("----------------------------------------")
    print("  |P| ~ 1.0 => Deconfined (Free Quarks)")
    print("  |P| ~ 0.0 => Confined   (Forbidden)")
    print("----------------------------------------")

    z_profile = np.mean(P_abs, axis=(0, 1))  # Average over X, Y

    for z, P_val in enumerate(z_profile):
        marker = "|| WALL ||" if z in walls else "          "

        if P_val < 0.2:
            state = "CONFINED  "
        elif P_val < 0.6:
            state = "TRANSITION"
        else:
            state = "FREE      "

        bar = "#" * int(P_val * 20)
        print(f"Z={z} | |P|={P_val:.4f}  {state} {marker} {bar}")