import numpy as np
import os

# Try to find the file dynamically to avoid path errors
base_dir = os.path.dirname(os.path.abspath(__file__))
data_path = os.path.abspath(os.path.join(base_dir, '../data/vortex_charge.npy'))

print(f"--- DATA INSPECTOR ---")
print(f"Looking for: {data_path}")

if not os.path.exists(data_path):
    print("CRITICAL: File not found on disk.")
else:
    try:
        data = np.load(data_path)
        print(f"\n[FILE STATS]")
        print(f"Shape: {data.shape}")
        print(f"Type:  {data.dtype}")

        # Check content
        d_min = np.min(data)
        d_max = np.max(data)
        d_mean = np.mean(data)
        d_abs_max = np.max(np.abs(data))

        print(f"Min:   {d_min:.5f}")
        print(f"Max:   {d_max:.5f}")
        print(f"Mean:  {d_mean:.5f}")
        print(f"Peak (Abs): {d_abs_max:.5f}")

        # Check if it's just empty
        if d_abs_max < 0.001:
            print("\n[DIAGNOSIS]: The file contains ZEROS (or near-zero noise).")
            print("The simulation ran, but the saved data is empty.")
        else:
            print(f"\n[DIAGNOSIS]: The file has STRUCTURE (Peak={d_abs_max:.3f}).")
            print("The 3D Plotter settings are incorrectly hiding the data.")

    except Exception as e:
        print(f"Error loading file: {e}")