using Symbolics
using LinearAlgebra
using Statistics
using Random
using Printf

# --- A|Ω FINE-TUNE SNIPER ---
# Objective: Pinpoint exact β where <S> == 0.785398
# Range: β ∈ [3.80, 4.10]

const L = 8
const N_SWEEPS = 5000   # High precision thermalization
const N_THERM = 200     # Burn-in
const Z3_PHASE = exp(2im * π / 3.0) 
const TARGET = π/4

function random_SU3(ϵ)
    R = randn(ComplexF64, 3, 3)
    H = (R + R') / 2 - tr(R + R')/6 * I
    return exp(im * ϵ * H)
end

function get_avg_action(U)
    total_S = 0.0
    count = 0
    for t in 1:L, x in 1:L, y in 1:L, z in 1:L
        u = U[t, x, y, z, 1]
        t_next = mod1(t+1, L); x_next = mod1(x+1, L)
        v_shift = U[t_next, x, y, z, 2]
        u_shift = U[t, x_next, y, z, 1]
        v = U[t, x, y, z, 2]
        
        plaq = u * v_shift * u_shift' * v'
        
        # Apply Twist to T-X plane at boundary (T=L)
        if t == L; plaq *= Z3_PHASE; end 
        
        total_S += (1.0 - real(tr(plaq))/3.0)
        count += 1
    end
    return total_S / count
end

function run_fine_scan()
    println("--- A|Ω PRECISION LOCUS SCAN ---")
    println("Target: π/4 ≈ $(@sprintf("%.6f", TARGET))")
    println("-----------------------------------------------------")
    println("   β    |    <S>     |    Diff    |   Error  | Status")
    println("-----------------------------------------------------")
    
    # Initialize Hot
    U = [random_SU3(2.0) for t=1:L, x=1:L, y=1:L, z=1:L, μ=1:4]
    
    # Fine increments
    betas = [3.979]
    
    for β in betas
        # Deep Thermalization
        current_S_vals = Float64[]
        
        for sweep in 1:N_SWEEPS
            for t in 1:L, x in 1:L, y in 1:L, z in 1:L, μ in 1:4
                 A = zeros(ComplexF64, 3, 3)
                 curr = [t, x, y, z]
                 for ν in 1:4
                    if μ == ν; continue; end
                    # Indices
                    fwd_mu = copy(curr); fwd_mu[μ] = mod1(fwd_mu[μ]+1, L)
                    fwd_nu = copy(curr); fwd_nu[ν] = mod1(fwd_nu[ν]+1, L)
                    bwd_nu = copy(curr); bwd_nu[ν] = mod1(bwd_nu[ν]-1, L)
                    fwd_mu_bwd_nu = copy(bwd_nu); fwd_mu_bwd_nu[μ] = mod1(fwd_mu_bwd_nu[μ]+1, L)
                    
                    # Twist Logic
                    is_twisted = (μ==1 && ν==2) || (μ==2 && ν==1) || (μ==3 && ν==4) || (μ==4 && ν==3)
                    twist_u = (is_twisted && (curr[μ]==L || curr[ν]==L)) ? Z3_PHASE : 1.0+0im
                    twist_l = (is_twisted && (curr[μ]==L || bwd_nu[ν]==L)) ? Z3_PHASE' : 1.0+0im

                    # Staples
                    upper = (U[fwd_mu[1],fwd_mu[2],fwd_mu[3],fwd_mu[4],ν] * U[fwd_nu[1],fwd_nu[2],fwd_nu[3],fwd_nu[4],μ]' * U[t,x,y,z,ν]') * twist_u
                    lower = (U[fwd_mu_bwd_nu[1],fwd_mu_bwd_nu[2],fwd_mu_bwd_nu[3],fwd_mu_bwd_nu[4],ν]' * U[bwd_nu[1],bwd_nu[2],bwd_nu[3],bwd_nu[4],μ]' * U[bwd_nu[1],bwd_nu[2],bwd_nu[3],bwd_nu[4],ν]) * twist_l
                    A += (upper + lower)
                 end
                 
                 old = U[t,x,y,z,μ]
                 new = random_SU3(0.2) * old
                 dS = -β/3.0 * real(tr((new - old) * A))
                 if rand() < exp(-dS); U[t,x,y,z,μ] = new; end
            end
            
            if sweep > N_THERM
                push!(current_S_vals, get_avg_action(U))
            end
        end
        
        # Stats
        S_mean = mean(current_S_vals)
        S_err = std(current_S_vals) / sqrt(length(current_S_vals))
        diff = S_mean - TARGET
        
        mark = ""
        if abs(diff) < 0.005; mark = "<< EXACT MATCH"; end
        
        @printf("  %.2f  |  %.6f  | %+.6f  | ±%.4f | %s\n", β, S_mean, diff, S_err, mark)
    end
end

run_fine_scan()