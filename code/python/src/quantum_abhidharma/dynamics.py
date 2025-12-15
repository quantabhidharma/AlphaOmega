import numpy as np


def get_staples(lattice):
    T, L, _, _, _, _, _ = lattice.shape
    staples_sum = np.zeros_like(lattice)
    for mu in range(4):
        for nu in range(4):
            if mu == nu: continue
            U_nu = lattice[:, :, :, :, nu]
            U_mu_shift_nu = np.roll(lattice[:, :, :, :, mu], -1, axis=nu)
            U_nu_shift_mu = np.roll(lattice[:, :, :, :, nu], -1, axis=mu)
            U_nu_shift_mu_dag = U_nu_shift_mu.swapaxes(-1, -2).conj()
            upper = U_nu @ U_mu_shift_nu @ U_nu_shift_mu_dag

            U_nu_down = np.roll(lattice[:, :, :, :, nu], 1, axis=nu)
            U_mu_down = np.roll(lattice[:, :, :, :, mu], 1, axis=nu)
            U_nu_down_dag = U_nu_down.swapaxes(-1, -2).conj()
            U_nu_corner = np.roll(np.roll(lattice[:, :, :, :, nu], 1, axis=nu), -1, axis=mu)
            lower = U_nu_down_dag @ U_mu_down @ U_nu_corner
            staples_sum[:, :, :, :, mu] += upper + lower
    return staples_sum


def random_su3_updates(lattice, epsilon):
    shape = lattice.shape[:-2] + (3, 3)
    R = np.random.normal(0, 1, shape) + 1j * np.random.normal(0, 1, shape)
    H = R + R.swapaxes(-1, -2).conj()
    tr = np.trace(H, axis1=-2, axis2=-1)[..., None, None]
    H -= tr / 3.0 * np.eye(3)
    update = np.eye(3) + 1j * epsilon * H

    # Gram-Schmidt
    v0 = update[..., :, 0];
    v0 /= np.sqrt(np.real(np.sum(v0 * v0.conj(), axis=-1)))[..., None]
    v1 = update[..., :, 1];
    v1 -= np.sum(v1 * v0.conj(), axis=-1)[..., None] * v0
    v1 /= np.sqrt(np.real(np.sum(v1 * v1.conj(), axis=-1)))[..., None]
    v2 = update[..., :, 2];
    v2 -= np.sum(v2 * v0.conj(), axis=-1)[..., None] * v0
    v2 -= np.sum(v2 * v1.conj(), axis=-1)[..., None] * v1
    v2 /= np.sqrt(np.real(np.sum(v2 * v2.conj(), axis=-1)))[..., None]
    X = np.stack([v0, v1, v2], axis=-1)
    dets = np.linalg.det(X)
    X = X * (dets ** (-1 / 3))[..., np.newaxis, np.newaxis]
    return X


def metropolis_with_walls(lattice, beta, epsilon, wall_locs):
    staples = get_staples(lattice)
    X = random_su3_updates(lattice, epsilon)
    new_lattice = X @ lattice

    staples_dag = staples.swapaxes(-1, -2).conj()

    # Calculate Action Density
    old_S = np.trace(lattice @ staples_dag, axis1=-2, axis2=-1).real
    new_S = np.trace(new_lattice @ staples_dag, axis1=-2, axis2=-1).real

    delta_S = new_S - old_S

    # Metropolis Cooling Logic
    accept_mask = (delta_S >= 0)

    wall_mask = np.ones(lattice.shape[:-2], dtype=bool)
    for z_wall in wall_locs: wall_mask[:, :, :, z_wall, :] = False

    final_mask = accept_mask & wall_mask
    full_mask = final_mask[..., np.newaxis, np.newaxis]
    lattice = np.where(full_mask, new_lattice, lattice)

    return lattice, np.count_nonzero(final_mask) / final_mask.size