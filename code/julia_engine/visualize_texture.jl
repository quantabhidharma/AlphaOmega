using LinearAlgebra
using Statistics
using Random
using Plots
using Printf

# --- A|Ω VISUALIZATION CONFIG ---
const L = 10          # 10x10x10x10 (10,000 sites - visible resolution)
const N_COLORS = 3    # SU(3)
const β_START = 0.1   # Hot (Confined)
const β_END = 8.0     # Cold (Deconfined)
const FRAMES = 60     # Number of frames in the movie
const SWEEPS_PER_FRAME = 10 # Physics steps between photos

# --- PHYSICS KERNEL ---
const Z3 = exp(2π * im / 3)
const TWIST = ComplexF64[Z3 0 0; 0 1 0; 0 0 1/Z3]

function random_SU3(ϵ)
    R = randn(ComplexF64, 3, 3)
    H = (R + R') / 2 - tr(R + R')/6 * I
    return exp(im * ϵ * H)
end

function get_local_energy(U)
    # Extract a 2D slice (X vs Y) at fixed T=1, Z=1
    # Returns a 2D matrix of energy values for plotting
    energy_map = zeros(Float64, L, L)
    
    t, z = 1, 1 # Slice indices
    
    for x in 1:L, y in 1:L
        # Calculate the "Plaquette" at this specific point
        # U_mu(x) * U_nu(x+mu) * U_mu(x+nu)† * U_nu(x)†
        # We average over all plane orientations (mu, nu) at this site
        sum_tr = 0.0
        
        # Simplified loop for visualization speed
        # Check X-Y plaquette specifically (visualize the plane we are looking at)
        U_x = U[t, x, y, z, 2] # 2 = x direction
        
        # Periodic wrap for neighbor
        next_x = mod1(x+1, L)
        next_y = mod1(y+1, L)
        
        U_y_shifted = U[t, next_x, y, z, 3] # 3 = y direction
        U_x_shifted = U[t, x, next_y, z, 2]
        U_y = U[t, x, y, z, 3]
        
        # Real part of trace = How aligned the field is (1.0 = Perfect, 0.0 = Chaos)
        plaq = real(tr(U_x * U_y_shifted * U_x_shifted' * U_y')) / 3.0
        energy_map[x, y] = plaq
    end
    return energy_map
end

function run_movie_studio()
    println("--- A|Ω INSTITUTE: DIAGNOSTIC MODE ---")
    println("Resolution: $L x $L")
    println("Analyzing Texture Stats...")

    # Start with Identity Matrices (Perfect Crystal)
    U = [Matrix{ComplexF64}(I, 3, 3) for t=1:L, x=1:L, y=1:L, z=1:L, μ=1:4]
    
    anim = @animate for frame in 1:FRAMES
        progress = frame / FRAMES
        β = β_START + (β_END - β_START) * progress
        epsilon = 0.2
        
        # Physics Steps
        accepts = 0
        total = 0
        for _ in 1:SWEEPS_PER_FRAME
            for idx in 1:L^4
                t,x,y,z = Tuple(CartesianIndices((L,L,L,L))[idx])
                μ = rand(1:4)
                old = U[t,x,y,z,μ]
                new = random_SU3(epsilon) * old
                dS = -β/3.0 * real(tr(new) - tr(old))
                
                if dS < 0 || rand() < exp(-dS)
                    U[t,x,y,z,μ] = new
                    accepts += 1
                end
                total += 1
            end
        end
        
        # Measurements
        heatmap_data = get_local_energy(U)
        avg_plaq = mean(heatmap_data)
        std_dev = std(heatmap_data) # How "rough" is the texture?
        acc_rate = round(accepts/total*100, digits=1)
        
        # --- TERMINAL OUTPUT (COPY PASTE THIS) ---
        @printf("Frame %02d | β=%.2f | Plaq=%.4f (±%.4f) | Acc=%.1f%%\n", 
                frame, β, avg_plaq, std_dev, acc_rate)
        
        # Plot (Auto-scaling colors to see structure)
        heatmap(heatmap_data, 
                c=:thermal, 
                title="β=$(round(β, digits=2)) | E=$(round(avg_plaq, digits=3))",
                aspect_ratio=:equal, axis=nothing, border=:none)
    end
    
    gif(anim, "vacuum_diagnostic.gif", fps=10)
    println("Done.")
end

run_movie_studio()