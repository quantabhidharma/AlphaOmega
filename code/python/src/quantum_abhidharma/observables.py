import numpy as np

def get_full_energy_grid(lattice):
    """Returns the 4D Energy Density map (Action Density)."""
    T, L, _, _, _, _, _ = lattice.shape
    energy_grid = np.zeros((T, L, L, L))
    for mu in range(4):
        for nu in range(mu + 1, 4):
            U_mu = lattice[:, :, :, :, mu]
            U_nu_shift_mu = np.roll(lattice[:, :, :, :, nu], -1, axis=mu)
            U_mu_shift_nu = np.roll(lattice[:, :, :, :, mu], -1, axis=nu)
            U_mu_shift_nu_dag = U_mu_shift_nu.swapaxes(-1, -2).conj()
            U_nu_dag = lattice[:, :, :, :, nu].swapaxes(-1, -2).conj()
            staple = U_mu @ U_nu_shift_mu @ U_mu_shift_nu_dag @ U_nu_dag
            tr_val = np.trace(staple, axis1=-2, axis2=-1).real
            energy_grid += (1.0 - tr_val / 3.0)
    return np.mean(energy_grid, axis=0)

def calculate_topological_charge_density(lattice):
    """Returns the 4D Topological Charge Density q(x)."""
    T_dim, L, _, _, _, _, _ = lattice.shape
    F_tensor = {}
    for mu in range(4):
        for nu in range(mu + 1, 4):
            U_mu = lattice[:,:,:,:,mu]
            U_nu_shift_mu = np.roll(lattice[:,:,:,:,nu], -1, axis=mu)
            U_mu_shift_nu = np.roll(lattice[:,:,:,:,mu], -1, axis=nu)
            U_nu = lattice[:,:,:,:,nu]
            P1 = U_mu @ U_nu_shift_mu @ U_mu_shift_nu.swapaxes(-1,-2).conj() @ U_nu.swapaxes(-1,-2).conj()
            F = (P1 - P1.swapaxes(-1,-2).conj()) / (2j)
            tr = np.trace(F, axis1=-2, axis2=-1)[..., None, None]
            F -= tr / 3.0 * np.eye(3)
            F_tensor[(mu, nu)] = F

    term1 = F_tensor[(0,1)] @ F_tensor[(2,3)]
    term2 = F_tensor[(0,2)] @ F_tensor[(1,3)]
    term3 = F_tensor[(0,3)] @ F_tensor[(1,2)]
    Q_matrix = term1 - term2 + term3
    q_vals = np.real(np.trace(Q_matrix, axis1=-2, axis2=-1))
    return np.mean(q_vals, axis=0)

def calculate_polyakov_loops(lattice):
    """Calculates the Polyakov Loop P(x)."""
    T, L, _, _, _, _, _ = lattice.shape
    U_time = lattice[:, :, :, :, 0]
    polyakov_field = np.zeros((L, L, L, 3, 3), dtype=np.complex128)
    for i in range(3): polyakov_field[..., i, i] = 1.0
    for t in range(T):
        polyakov_field = polyakov_field @ U_time[t]
    loops = np.trace(polyakov_field, axis1=-2, axis2=-1) / 3.0
    return loops