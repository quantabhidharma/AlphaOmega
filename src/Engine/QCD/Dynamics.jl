module Dynamics

    using ..Constants
    using LinearAlgebra

    function get_complex_coupling(phi_val::Float64)
        # Real Stiffness (Symmetric)
        beta_real = Constants.BETA_SATURATION / (1.0 + phi_val^2)
        
        # Ghost Instability (Monodromy)
        gamma = (Constants.C_LIGHT / 4.0) * (1.0 - beta_real / Constants.BETA_SATURATION)
        
        return beta_real, gamma
    end

    function get_screened_alpha(phi_val::Float64)
        # Screening Factor (Symmetric)
        screening = 1.0 + (Constants.N_CAUSAL * phi_val^2)
        return Constants.ALPHA / screening
    end

    function update_link!(U, staples, current_phi)
        
        # Use the raw phi (signed) to determine direction, 
        # but magnitude for coupling strength.
        phi_mag = abs(current_phi)
        phi_sign = sign(current_phi)
        
        # If phi is exactly 0, default to +1 to break symmetry
        if phi_sign == 0.0; phi_sign = 1.0; end

        beta_real, gamma = get_complex_coupling(phi_mag)
        
        # --- STEP 1: PHYSICAL FLUCTUATION ---
        delta = exp(im * randn() * Constants.UPDATE_STEP_SIZE)
        U_prime = delta * U
        
        S_old = -real(U * staples)
        S_new = -real(U_prime * staples)
        dS = S_new - S_old
        
        dS_causal = dS / Float64(Constants.N_CAUSAL)

        if rand() < exp(-beta_real * dS_causal)
            U = U_prime 
        end

        # --- STEP 2: HELICAL GHOST TORQUE ---
        # 1. REMOVED Schwinger Factor (2π) -> Restores full drive ("Go Lower")
        # 2. ADDED Sign Dependence -> Restores Negative Branch Topology
        
        alpha_eff = get_screened_alpha(phi_mag)
        drift_strength = gamma * alpha_eff
        
        # The Torque direction depends on which branch (Physical/Ghost) we are in.
        # This creates the "Vacuum Helix" topology.
        ghost_twist = exp(im * phi_sign * drift_strength) 
        U = ghost_twist * U
        
        return U
    end

end