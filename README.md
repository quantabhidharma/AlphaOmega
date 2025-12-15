# A|Ω⟩ Lattice Vacuum Engine

[![License](https://img.shields.io/badge/License-MIT-green)](https://opensource.org/licenses/MIT)
[![Julia](https://img.shields.io/badge/Julia-1.10+-9558B2?logo=julia&logoColor=white)](https://julialang.org)
[![Status](https://img.shields.io/badge/Status-v0.2.0-active)](https://github.com/quantabhidharma/AlphaOmega)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.17844109.svg)](https://doi.org/10.5281/zenodo.17844109)

## 1. Abstract

**The A|Ω⟩ Research Program** establishes a specialized Lattice Gauge Theory (LGT) framework designed to probe the non-perturbative structure of the SU(3) Yang-Mills vacuum.

Distinct from general-purpose lattice QCD packages (e.g., Chroma, Grid) which optimize for large-volume hadronic spectroscopy, this engine is architected specifically for **Twisted Eguchi-Kawai (TEK) Reduction**. It utilizes $Z_N$-twisted boundary conditions to simulate infinite-volume confinement physics on compact, topologically non-trivial manifolds ($T^4$). This approach allows for high-precision tomography of vacuum structure—specifically center vortices and topological defects—while suppressing finite-volume deconfining artifacts.

## 2. Methodology

The simulation kernel isolates the mechanism of color confinement via three geometric constraints:

* **Twisted Boundary Conditions (TBC):** Implementation of 't Hooft flux to preserve Center Symmetry ($Z_3$) in reduced volumes, preventing the breaking of confinement at small physical scales ($L \ll \Lambda_{QCD}^{-1}$).
* **Toroidal Compactification:** Simulation on $T^4$ hypertoroidal geometries to enforce specific topological sectors.
* **Action Density Tomography:** Real-time calculation of the local plaquette action $S(x)$ to map the formation of chromoelectric and chromomagnetic flux tubes.

## 3. Technical Specifications

| Component | Specification | Description |
| :--- | :--- | :--- |
| **Formalism** | Pure SU(3) Yang-Mills | Wilson Gauge Action (Quenched) |
| **Algorithm** | Metropolis-Hastings | Local update algorithm with $O(N^2)$ scaling |
| **Boundary** | 't Hooft Twist | Symmetric twist tensor $z_{\mu\nu} \in Z_3$ |
| **Architecture** | Julia 1.10+ | Just-In-Time (JIT) compiled for Apple Silicon (M-Series) |
| **Precision** | `Float64` / `ComplexF64` | Double-precision arithmetic for unitary stability |
| **Criticality** | $\beta_c \approx 6.0$ | Scaling window verification active |

## 4. Repository Structure

The Institute archive adheres to a rigid hierarchical structure to separate computational kernels from archival documentation.

```text
AlphaOmega/
├── src/                          # LEVEL 1: Source Code
│   ├── Engine/                   # LEVEL 2: Physics Core
│   │   ├── WilsonAction.jl       # LEVEL 3: Lattice Discretization
│   │   ├── MonteCarlo.jl         # LEVEL 3: Metropolis Update Kernels
│   │   └── TwistFactors.jl       # LEVEL 3: Z3 Boundary Conditions
│   │
│   └── Diagnostics/              # LEVEL 2: Measurement Suite
│       ├── PolyakovLoop.jl       # LEVEL 3: Confinement Order Parameter
│       └── TextureMap.jl         # LEVEL 3: Vacuum Tomography
│
├── docs/                         # LEVEL 1: Documentation & Portal
│   ├── formalism/                # LEVEL 2: LaTeX Source
│   │   └── te_reduction.tex      # LEVEL 3: Theoretical Basis
│   │
│   ├── figures/                  # LEVEL 2: Visual Assets
│   │   ├── ao_logo.jpg           # LEVEL 3: Institute Identity
│   │   └── vacuum_density/       # LEVEL 3: Generated Plots
│   │       └── hyst_loop.png     # LEVEL 4: Criticality Data
│   │
│   └── index.html                # LEVEL 2: Public Portal Entry
│
├── data/                         # LEVEL 1: Binary Data (Untracked)
│   └── .gitignore                # LEVEL 2: Exclusion Rules
│
└── README.md                     # LEVEL 1: Project Overview
