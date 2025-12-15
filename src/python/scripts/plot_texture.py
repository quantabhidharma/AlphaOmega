import matplotlib.pyplot as plt
import numpy as np

# Load the raw simulation data
try:
    data = np.loadtxt('vacuum_texture.csv', delimiter=',')
except FileNotFoundError:
    print("Error: vacuum_texture.csv not found. Make sure you ran the Julia script first.")
    exit()

# Setup the plot
plt.figure(figsize=(10, 8))
plt.imshow(data, cmap='magma', interpolation='nearest', origin='lower')

# Aesthetics
cbar = plt.colorbar()
cbar.set_label('Action Density (Geometric Tension)', rotation=270, labelpad=20)
plt.title(r'Vacuum Texture: The "Ghost Sector" ($\beta=3.98$)', fontsize=14)
plt.xlabel('Spatial X', fontsize=12)
plt.ylabel('Euclidean Time T', fontsize=12)

# Save high-res
plt.savefig('vacuum_texture.png', dpi=300, bbox_inches='tight')
print("SUCCESS: Image saved to 'vacuum_texture.png'")
plt.show()