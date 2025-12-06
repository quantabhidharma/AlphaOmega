#  A|Ω⟩ – Quantum Abhidharma Lattice QCD Engine

[![License](https://img.shields.io/badge/License-MIT-green)]()
[![Python](https://img.shields.io/badge/Python-3.9+-blue)]()
[![Status](https://img.shields.io/badge/Status-Experimental_Validation-orange)]()

## Overview

**quantum-abhidharma** is a specialized Lattice QCD implementation designed for the study of **topological boundary conditions** and non-perturbative vacuum defects.

Unlike standard high-performance codes (Grid, Chroma) optimized for bulk infinite-volume calculations, this engine focuses on **vacuum tomography**: the ability to freeze, twist, and inspect specific sub-volumes of the lattice. It allows researchers to easily simulate:
* **Casimir Geometries:** Fixed Dirichlet boundaries with specific gauge values.
* **Topological Defects:** Center vortices (Z_N) and domain walls.
* **Phase Space Partitioning:** Measuring observables in disjoint vacuum sectors.

It serves as the computational verification layer for the **A|Ω⟩ Research Program** (see `papers/` directory), specifically testing the stability of the Dual-Sector Vacuum ansatz.

## Technical Specifications

| Parameter | Specification | Note |
| :--- | :--- | :--- |
| **Gauge Group** | Pure SU(3) | Yang-Mills (Quenched Approximation) |
| **Action** | Standard Wilson | Plaquette-based |
| **Algorithm** | Metropolis-Hastings | Local updates with Gram-Schmidt re-unitarization |
| **Lattice Volume** | Parametric (L³ × T) | Engine supports arbitrary dimensions limited only by host RAM |
| **Verified Configurations** | 8⁴ (Prototyping), 12⁴ (Scaling), 16⁴ (Production targets) | Current results use 8⁴ |
| **Coupling (β)** | 5.5 - 6.0 | Validated in the scaling window |
| **Boundaries** | Flexible | Supports Periodic, Fixed, and Twisted (Center Element) |

**Note on Limitations:** The quenched approximation neglects dynamical quarks. Continuum limit extrapolation (a→0) and finite-size scaling analysis are planned for future work.

## Key Results (Preliminary)

Results from 8⁴ lattice configurations:

1. **Geometric Stability:** Calibration of vacuum noise to geometric action S=π/4 yields a noise parameter ξ ≈ 0.0084.
2. **Casimir Pressure:** Simulations with fixed boundary conditions exhibit a vacuum energy deficit of ~80% relative to the disordered phase (E_bulk ≈ 0.046 vs E_wall ≈ 0.22), consistent with mass gap behavior.
3. **Flux Condensation:** 3D tomography observes spontaneous formation of **center vortices** (flux tubes) connecting twisted boundary sectors, consistent with the dual Meissner effect.
4. **Confinement:** The Polyakov Loop order parameter shows ⟨|P|⟩ ≈ 0.28 in the bulk (confined) even when boundaries are ordered (|P|=1), consistent with topological protection mechanisms.

## Repository Structure

* **`code/`**: The monorepo containing the physics engines.
    * `python_engine/`: The core implementation.
        * `src/quantum_abhidharma/`: Generators, Dynamics, and Observables.
        * `scripts/`: Experiments (`run_vortex.py`, `run_polyakov.py`).
* **`papers/`**: Manuscripts and theoretical derivations.
* **`data/`**: Organized by run parameters (e.g., `L08_T08_b5.5/`). Large configurations archived on OSF.

## Installation
```bash
git clone https://github.com/quantabhidharma/AlphaOmega.git
cd AlphaOmega/code/python_engine
pip install -e .
```

## Quick Start: The "Fire & Ice" Dipole

This script generates a topological domain wall and visualizes the resulting flux tube:
```bash
python code/python_engine/scripts/run_vortex.py
python code/python_engine/scripts/visualize_vortex.py
```

Results are automatically saved to `data/L08_T08_b5.5/` (or corresponding parameter bucket).

## Data Organization

Simulation data is organized hierarchically by lattice parameters:
```
data/
├── L08_T08_b5.5/          # Prototyping configurations
│   ├── lattice.npy
│   ├── charge_density.npy
│   └── run_metadata.json
│
├── L12_T12_b5.7/          # Scaling studies
└── L16_T16_b6.0/          # Production runs
```

Raw `.npy` arrays and high-resolution visualizations will be archived on the **Open Science Framework (OSF)** upon publication.

## Citation

If you use this code or data, please cite:

> Yiannopoulos, A. (2025). *A|Ω⟩: Quantum Abhidharma Lattice Engine*. Open Science Framework. DOI: 10.17605/OSF.IO/9AS78

For theoretical background, see manuscripts in `papers/`.

---

*© 2025 Alexander Yiannopoulos.*
