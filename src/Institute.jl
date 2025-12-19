# ==============================================================================
# A|Ω⟩ INSTITUTE // GRAND UNIFICATION DRIVER V7 (UNCENSORED)
# ==============================================================================

include("Engine/Constants.jl")
include("Engine/Types.jl")
include("Engine/QCD/Dynamics.jl")
include("Engine/QCD/Initialize.jl")
include("Engine/Diagnostics/Observables.jl")

using .Constants
using .Types
using .Dynamics
using .Initialize
using .Observables
using Dates
using Random

function main()
    # --- ENTROPY INJECTION ---
    # We seed the RNG with the current nanosecond to ensure a unique universe.
    seed_val = floor(Int, time() * 1e9)
    Random.seed!(seed_val)

    println("\n=== A|Ω⟩ INSTITUTE: UNIFIED FIELD SIMULATION (RunID: $seed_val) ===")
    println("Target 1: Dark Energy (Ω_Λ ≈ 0.68)")
    println("Target 2: Mass Gap Stability")
    println("Metric: Complex Mass (Detects Expansion & Resonance)")
    println("------------------------------------------------------------------\n")

    lattice = zeros(ComplexF64, Constants.L, Constants.L, Constants.L, Constants.T)
    Initialize.cold_start_vacuum!(lattice)

    N_SWEEPS = 2500 
    start_time = now()
    
    println("[ SYSTEM ] Beginning Time Evolution...")

    Lx, Ly, Lz, Lt = Constants.L, Constants.L, Constants.L, Constants.T

    for sweep in 1:N_SWEEPS
        
        # --- HOT LOOP ---
        for t in 1:Lt, z in 1:Lz, y in 1:Ly, x in 1:Lx
            
            # Periodic Boundaries
            xp = (x % Lx) + 1; xm = (x - 2 + Lx) % Lx + 1
            yp = (y % Ly) + 1; ym = (y - 2 + Ly) % Ly + 1
            zp = (z % Lz) + 1; zm = (z - 2 + Lz) % Lz + 1
            tp = (t % Lt) + 1; tm = (t - 2 + Lt) % Lt + 1

            staple_sum = lattice[xp, y, z, t] + lattice[xm, y, z, t] +
                         lattice[x, yp, z, t] + lattice[x, ym, z, t] +
                         lattice[x, y, zp, t] + lattice[x, y, zm, t] +
                         lattice[x, y, z, tp] + lattice[x, y, z, tm]
            
            current_link = lattice[x, y, z, t]
            
            # Signed Topology 
            phi_signed = angle(current_link)
            
            lattice[x, y, z, t] = Dynamics.update_link!(current_link, staple_sum, phi_signed)
        end

        # --- TELEMETRY ---
        if sweep % 100 == 0
            Omega_m, Omega_L = Observables.measure_energy_density(lattice)
            mass_complex = Observables.measure_mass_gap(lattice)
            
            # Formatting
            l_str = rpad(round(Omega_L, digits=4), 6)
            
            # Complex Mass Logic
            m_real = real(mass_complex)
            m_imag = imag(mass_complex)
            
            if m_real < 0
                # Expansion (Tachyon)
                mass_str = "$(round(m_real, digits=4)) [EXP]"
            elseif abs(m_imag) > 0.1
                # Resonance (Oscillation)
                mass_str = "$(round(m_real, digits=4)) [RES]"
            else
                # Stable Matter
                mass_str = "$(round(m_real, digits=4))      "
            end
            
            println("Sweep $sweep | Ω_Λ: $l_str | Mass: $mass_str | $(now())")
        end
    end

    runtime = now() - start_time
    println("\n[ SUCCESS ] Simulation Complete in $runtime")
end

main()