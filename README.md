# A|Ω⟩: Quantum Abhidharma Lattice Engine

**DOI:** (Pending OSF Registration)  
**Status:** Experimental Validation  

## Project Overview
The **A|Ω⟩ Research Program** proposes a reformulation of Quantum Field Theory (QFT) that abandons the assumption of a positive-definite metric space in favor of an indefinite-metric structure (Krein space). This architecture resolves the conformal factor instability by identifying the "Ghost Sector" (negative metric) with the Conformal Mode of the gravitational field.

This repository contains the **Lattice QCD** numerical experiments validating the stability and confinement properties of the Dual-Sector Vacuum.

## Key Findings
1. **Geometric Stability:** The vacuum ansatz with geometric action $S=\pi/4$ corresponds to a calibrated noise level of $\xi \approx 0.0084$.
2. **Casimir Pressure:** Topological boundary conditions induce a vacuum energy deficit of ~80% relative to the disordered phase.
3. **Flux Condensation:** 3D Tomography confirms the spontaneous formation of Center Vortices (Flux Tubes) connecting orthogonal phase sectors.
4. **Topological Protection:** The Polyakov Loop order parameter confirms the bulk vacuum suppresses free quarks ($\langle|P|\rangle \approx 0.28$) even under cooling, suggesting a topological mechanism for proton stability.

## Repository Structure
* `src/`: The core physics engine (Metropolis dynamics, Topology measurement, Observables).
* `experiments/`: Reproducible scripts for Casimir and Vortex measurements.
* `data/`: (Hosted on OSF) Raw lattice configurations and charge density maps.

## Installation & Usage
1. Clone the repository.
2. Install dependencies: `pip install numpy plotly scipy`
3. Run the Vortex Experiment:
   ```bash
   python experiments/run_vortex.py
   python experiments/visualize_vortex.py