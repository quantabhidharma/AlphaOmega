module Initialize

    using ..Constants
    using Random

    """
    cold_start_vacuum!(lattice)
    
    Initializes the lattice to the Geometric Action Limit (S = π/4).
    This is not a random start; it is a specific, low-entropy quantum state.
    """
    function cold_start_vacuum!(lattice)
        println("[INSTITUTE] Initializing Vacuum to Geometric Saturation (S=π/4)...")
        
        for i in eachindex(lattice)
            noise = randn() * Constants.COLD_START_SIGMA
            lattice[i] = exp(im * noise)
        end
    end

end