using LinearAlgebra
using Statistics
using Random
using Plots
using Base.Threads

# --- VISUALIZATION DASHBOARD ---
gr(size=(800, 600), legend=true, titlefontsize=10)

# --- HARDWARE & PHYSICS CONFIG ---
const L = 4           # Keep it small for instant visualization
const β_START = 0.1
const β_END = 6.0
const STEPS = 50
const SWEEPS = 100    # Faster sweeps for the plot

# Physics Engine (Condensed)
const Z3 = exp(2π * im / 3)
const TWIST = ComplexF64[Z3 0 0; 0 1 0; 0 0 1/Z3]

function random_SU3(ϵ)
    R = randn(ComplexF64, 3, 3); H = (R+R')/2 - tr(R+R')/6*I
    return exp(im * ϵ * H)
end

function get_energy(U)
    # Calculate average Plaquette (Energy Density)
    E = 0.0
    count = 0
    for t=1:L, x=1:L, y=1:L, z=1:L, μ=1:3, ν=μ+1:4
        # Simple 1x1 Loop
        P = U[t,x,y,z,μ] * U[t,x,y,z,ν]' # Simplified for speed/demo
        E += real(tr(P))
        count += 1
    end
    return E / (count * 3.0)
end

function run_visual_scan()
    println("--- GENERATING VACUUM PHASE DIAGRAM ---")
    U = [random_SU3(1.0) for t=1:L, x=1:L, y=1:L, z=1:L, μ=1:4]
    
    betas = Float64[]
    energies = Float64[]
    polys = Float64[]
    
    # Live Plot Object
    plt = plot(layout=(2,1), link=:x)
    
    epsilon = 0.2
    
    for step in 1:STEPS
        β = β_START + (β_END - β_START) * (step / STEPS)
        
        # Fast Thermalization
        for _ in 1:SWEEPS
            for idx in 1:(L^4) # Serial for safety in plot script
                # (Simplified Update Logic for Visualization Speed)
                t,x,y,z = Tuple(CartesianIndices((L,L,L,L))[idx])
                μ = rand(1:4)
                old = U[t,x,y,z,μ]
                new = random_SU3(epsilon) * old
                dS = -β/3 * real(tr(new) - tr(old)) # Naive Action Proxy
                if rand() < exp(-dS); U[t,x,y,z,μ] = new; end
            end
        end
        
        # Measurements
        push!(betas, β)
        push!(energies, get_energy(U))
        
        # Polyakov Loop (Time direction product)
        p_loop = abs(mean([tr(prod(U[:,x,y,z,1])) for x=1:L, y=1:L, z=1:L])) / 3.0
        push!(polys, p_loop)
        
        # Update Plot
        p1 = plot(betas, energies, label="Vacuum Energy (Plaquette)", 
                  ylabel="Order", c=:blue, lw=2, legend=:bottomright)
        p2 = plot(betas, polys, label="Confinement (Polyakov)", 
                  ylabel="|P|", xlabel="Inverse Coupling (β)", c=:red, lw=2)
        
        display(plot(p1, p2, layout=(2,1)))
        print(".") # Heartbeat
    end
    println("\nScan Complete. Image Generated.")
end

run_visual_scan()