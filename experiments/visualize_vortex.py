import os
import numpy as np
import plotly.graph_objects as go
import sys

print("--- FINAL VORTEX VISUALIZER ---")

# 1. Load Data
base_dir = os.path.dirname(os.path.abspath(__file__))
data_path = os.path.join(base_dir, '../data/vortex_charge.npy')

if not os.path.exists(data_path):
    print("Error: Data file missing.")
    sys.exit(1)

q_map = np.load(data_path)
if q_map.ndim == 4: q_map = np.mean(q_map, axis=0)

# 2. Statistics
peak = np.max(np.abs(q_map))
print(f"Peak Charge: {peak:.4f}")

# 3. Visualization Settings
# We render TWO Isosurfaces on the SAME coordinate system
L = q_map.shape[0]
X, Y, Z = np.mgrid[0:L, 0:L, 0:L]

fig = go.Figure()

# POSITIVE CHARGE (Red)
# We only show values between 15% and 100% of the peak
fig.add_trace(go.Isosurface(
    x=X.flatten(), y=Y.flatten(), z=Z.flatten(),
    value=q_map.flatten(),
    isomin=peak * 0.15,
    isomax=peak,
    surface_count=4,
    colorscale='Hot',
    opacity=0.4,
    caps=dict(x_show=False, y_show=False),
    name='Positive (Monopole)'
))

# NEGATIVE CHARGE (Blue)
# We map the negative values.
# Note: Isosurface expects positive ranges usually, so we invert the data for the Blue trace
# to make the logic identical.
fig.add_trace(go.Isosurface(
    x=X.flatten(), y=Y.flatten(), z=Z.flatten(),
    value=-q_map.flatten(), # INVERTED DATA
    isomin=peak * 0.15,
    isomax=peak,
    surface_count=4,
    colorscale='Bluered', # Blue to Red (we will see the Blue part)
    opacity=0.4,
    caps=dict(x_show=False, y_show=False),
    name='Negative (Anti-Monopole)'
))

fig.update_layout(
    title=f'Topological Dipole (Peak Q={peak:.3f})',
    scene=dict(
        xaxis_title='X',
        yaxis_title='Y',
        zaxis_title='Z',
        bgcolor='black',
        aspectmode='data',
        camera=dict(eye=dict(x=1.5, y=1.5, z=1.5)) # Zoom out slightly
    ),
    paper_bgcolor='black',
    font=dict(color='white')
)

output_file = os.path.join(base_dir, "vortex_final.html")
fig.write_html(output_file)
print(f"\n[SUCCESS] Saved to {output_file}")

# Open
try:
    import webbrowser
    webbrowser.open('file://' + output_file)
except: pass


def calculate_polyakov_loops(lattice):
    """
    Calculates the Polyakov Loop P(x) at every spatial site.
    P(x) = Trace( Product of U_time along the time direction ) / 3
    """
    T, L, _, _, _, _, _ = lattice.shape

    # 1. Extract Temporal Links U_0 (Time direction is mu=0)
    # Shape: (T, L, L, L, 3, 3)
    U_time = lattice[:, :, :, :, 0]

    # 2. Initialize P(x) with Identity
    # Shape: (L, L, L, 3, 3)
    polyakov_field = np.zeros((L, L, L, 3, 3), dtype=np.complex128)
    for i in range(3): polyakov_field[..., i, i] = 1.0

    # 3. Multiply along Time (Matrix Multiplication)
    for t in range(T):
        polyakov_field = polyakov_field @ U_time[t]

    # 4. Take Trace and Normalize
    loops = np.trace(polyakov_field, axis1=-2, axis2=-1) / 3.0
    return loops