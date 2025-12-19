module Observables

    using ..Constants
    using LinearAlgebra
    using Statistics

    function measure_energy_density(lattice)
        M = sum(lattice) / length(lattice)
        Omega_Matter = abs(M)
        Omega_Lambda = 1.0 - Omega_Matter
        return Omega_Matter, Omega_Lambda
    end

    """
    measure_mass_gap(lattice)
    
    Calculates the Mass Gap raw. Returns a Complex number.
    
    Interpretations:
    - Real(m) > 0: Stable Matter (Decay)
    - Real(m) < 0: Expansion/Tachyon (Growth)
    - Imag(m) != 0: Resonance/Oscillation (Sign flip in correlation)
    """
    function measure_mass_gap(lattice)
        L, T = size(lattice, 1), size(lattice, 4)
        
        # 1. Zero Momentum Projection
        phi_t = zeros(ComplexF64, T)
        for t in 1:T
            phi_t[t] = sum(lattice[:, :, :, t])
        end
        
        # 2. Correlator C(tau) - NO ABS()
        # We preserve the raw correlation sign.
        C = zeros(Float64, T)
        for tau in 0:(T-1)
            sum_corr = 0.0
            for t in 1:T
                t_plus = ((t + tau - 1) % T) + 1
                # We take the real part of the product, but do NOT absolute value the result.
                # If the vacuum is anti-correlated, this sum will be negative.
                sum_corr += real(phi_t[t] * conj(phi_t[t_plus]))
            end
            C[tau+1] = sum_corr / T
        end
        
        # 3. Extract Mass (Complex Log)
        c0 = C[1]
        c1 = C[2]
        
        # Avoid division by zero
        if abs(c1) < 1e-12
            return 0.0 + 0.0im
        end
        
        # m = ln( C(0) / C(1) )
        # Since we use Complex arguments, this handles negative ratios gracefully
        # by returning a mass with an imaginary component (+iπ).
        ratio = c0 / c1
        return log(Complex(ratio))
    end

end