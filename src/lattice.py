import numpy as np


def generate_hot_start(L, T):
    """Initialize Random Hot Lattice (Disordered)."""
    lattice = np.zeros((T, L, L, L, 4, 3, 3), dtype=np.complex128)
    shape = lattice.shape[:-2] + (3, 3)
    R = np.random.normal(0, 1, shape) + 1j * np.random.normal(0, 1, shape)
    q, r = np.linalg.qr(R)
    dets = np.linalg.det(q)
    phase = dets ** (-1 / 3)
    lattice = q * phase[..., np.newaxis, np.newaxis]
    return lattice


def generate_twisted_walls(L, T):
    """
    Z=0: Identity
    Z=4: Twisted Center Element (Z3)
    """
    lattice = np.zeros((T, L, L, L, 4, 3, 3), dtype=np.complex128)
    for mu in range(4):
        for c in range(3):
            lattice[:, :, :, :, mu, c, c] = 1.0

    z_phase = np.exp(2j * np.pi / 3.0)
    z_wall_idx = L // 2
    for mu in range(4):
        lattice[:, :, :, z_wall_idx, mu, :, :] *= z_phase

    return lattice, [0, z_wall_idx]