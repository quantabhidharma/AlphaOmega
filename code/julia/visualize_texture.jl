using LinearAlgebra
using Statistics
using Random
using DelimitedFiles
using Printf

# --- A|Ω VACUUM TEXTURE IMAGER ---
# Objective: Visualize the topological defects at the Geometric Limit
# Target Beta: 3.98 (The Golden Spike)

const L = 12            # Adjusted to 12 for speed (16^4 is heavy on single thread)
const β = 3.98          # The "Pi/4" Coupling
const N_SWEEPS = 500    # Thermalization
const Z3_PHASE = exp(2im * π / 3.0)

function random_SU3(ϵ)
    R = randn(ComplexF64, 3, 3)
    H = (R + R') / 2 - tr(R + R')/6 * I
    return exp(im * ϵ * H)
end

function print_progress(step, total)
    bar_width = 40
    frac = step / total
    filled = round(Int, frac * bar_width)
    bar = repeat("█", filled) * repeat("░", bar_width - filled)
    @printf("\rProgress: [%s] %.1f%% (Sweep %d/%d)", bar, frac * 100, step, total)
end

println("--- GENERATING VACUUM TEXTURE MAP ---")
println("L=$L^4 | β=$β | Topology: Twisted")

# 1. Initialize (Cold Start)
U = [Matrix{ComplexF64}(I, 3, 3) for t=1:L, x=1:L, y=1:L, z=1:L, μ=1:4]

# 2. Simulation Loop
for sweep in 1:N_SWEEPS
    print_progress(sweep, N_SWEEPS)
    
    for t in 1:L, x in 1:L, y in 1:L, z in 1:L
        for μ in 1:4
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
            
            # Update
            old_link = U[t,x,y,z,μ]
            new_link = random_SU3(0.2) * old_link
            dS = -β/3.0 * real(tr((new_link - old_link) * A))
            if rand() < exp(-dS); U[t,x,y,z,μ] = new_link; end
        end
    end
end
println("\nSimulation Complete.")

# 3. Extract 2D Slice (T-X Plane)
println("Extracting Action Density Slice...")
density_map = zeros(Float64, L, L)
y_slice = L ÷ 2
z_slice = L ÷ 2

for t in 1:L, x in 1:L
    # Calculate Plaquette in T-X plane
    u = U[t, x, y_slice, z_slice, 1] # T
    v = U[t, x, y_slice, z_slice, 2] # X
    
    t_next = mod1(t+1, L)
    x_next = mod1(x+1, L)
    
    v_shift = U[t_next, x, y_slice, z_slice, 2]
    u_shift = U[t, x_next, y_slice, z_slice, 1]
    
    plaq = u * v_shift * u_shift' * v'
    if t == L; plaq *= Z3_PHASE; end # Apply Boundary Twist
    
    # Store Action Density (0 = Ordered, 1 = Disordered)
    density_map[t, x] = 1.0 - real(tr(plaq))/3.0
end

# 4. Save
writedlm("vacuum_texture.csv", density_map, ',')
println("Saved 'vacuum_texture.csv'.")