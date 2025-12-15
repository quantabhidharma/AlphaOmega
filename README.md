# A|Ω⟩ – Lattice Vacuum Engine

[![License](https://img.shields.io/badge/License-MIT-green)](https://opensource.org/licenses/MIT)
[![Julia](https://img.shields.io/badge/Julia-1.10+-9558B2?logo=julia&logoColor=white)](https://julialang.org)
[![Status](https://img.shields.io/badge/Status-Operational-success)](https://github.com/quantabhidharma/AlphaOmega)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.17844109.svg)](https://doi.org/10.5281/zenodo.17844109)

## Overview

**The A|Ω⟩ Research Program** is a specialized Lattice Gauge Theory framework designed to probe the non-perturbative structure of the Quantum Vacuum.

Unlike standard lattice QCD codes (Grid, Chroma) which optimize for brute-force bulk thermodynamics, this engine is architected for **Twisted Vacuum Tomography**. It leverages **Twisted Eguchi-Kawai (TEK) Reduction** and $Z_N$ boundary conditions to simulate infinite-volume confinement physics on compact, topologically non-trivial manifolds ("Time Cubes").

This repository serves as the computational verification layer for the **A|Ω⟩ Research Program**, specifically isolating the mechanism of color confinement via:

* **Twisted Boundary Conditions:** Preserving center symmetry ($Z_3$) in small volumes to prevent deconfining phase transitions.
* **Vacuum Texture Analysis:** Real-time visualization of action density, center vortices, and topological defects.
* **Dual-Sector Dynamics:** Investigating the stability of the vacuum ansatz under extreme topological stress.

## Technical Specifications

| Parameter | Specification | Note |
| :--- | :--- | :--- |
| **Engine Core** | **Julia** (High-Performance) | Replaces legacy Python prototypes |
| **Gauge Group** | Pure SU(3) Yang-Mills | Quenched Approximation |
| **Topology** | $T^4$ with 't Hooft Twist | Twisted Boundary Conditions (TBC) |
| **Algorithm** | Metropolis-Hastings | Optimized for Apple Silicon (M-Series) |
| **Target Hardware** | Mac Studio (M4 Max) | 128GB Unified Memory Architecture |
| **Critical Coupling** | $\beta_c \approx 6.0$ | Scaling window verification active |

## Key Results (Verified)

Current telemetry from the **Institute Verification Run** (Dec 2025):

1. **Confinement Preservation:** The "Time Cube" topology successfully suppresses the bulk deconfining transition at small volumes. The Polyakov Loop remains disordered ($P \approx 0$) well into the scaling window.
2. **Hysteresis & Metastability:** Cold-start simulations ($\beta=8.0 \to 0.0$) exhibit strong hysteresis, confirming the robust topological protection of the confined phase.
3. **Vacuum Texture:** Real-time diagnostics confirm the formation of "electric" and "magnetic" flux domains, visualized via local action density mapping.

## Repository Structure

The Institute follows a strict separation of concerns:

* **`code/`**
  * **`julia_engine/`**: The active production core. High-performance Monte Carlo kernels.
  * **`python_prototypes/`**: Legacy exploratory scripts (kept for reference).
  * **`viz/`**: Telemetry and visualization pipelines (`visualize_texture.jl`).

* **`docs/`**
  * **`formalism/`**: LaTeX source for the A|Ω theoretical framework.

* **`data/`**
  * *Note: Large lattice binaries (`.jld2`, `.log`) are `.gitignore`d.* Only synthesized figures and metadata are committed.

## Installation & Usage

**Prerequisites:** Julia 1.10+, VS Code.

```bash
# 1. Clone the Institute Repo
git clone [https://github.com/quantabhidharma/AlphaOmega.git](https://github.com/quantabhidharma/AlphaOmega.git)
cd AlphaOmega

# 2. Instantiate the Julia Environment
julia --project=code/julia_engine -e 'using Pkg; Pkg.instantiate()'
```

### Running a Simulation

To run the standard "Vacuum Texture" diagnostic (The Heat Map), ensure you are in the repository root:

```bash
# Run the visualization script using the Julia engine environment
julia --project=code/julia_engine code/viz/visualize_texture.jl
```

To execute the "Sniper" script for the Critical Point scan (Requires High-Performance Node):

```bash
julia --project=code/julia_engine code/julia_engine/critical_scan.jl
```

## Citation

The A|Ω⟩ formalism is an evolving theoretical framework. If you utilize this engine or its derived data, please cite:

> Yiannopoulos, A. (2025). *A|Ω⟩: Twisted Eguchi-Kawai Reduction & Vacuum Tomography*. Open Science Framework. DOI: 10.17605/OSF.IO/9AS78

---

*© 2025 A|Ω⟩ Institute. All Non-Perturbative Rights Reserved.*
