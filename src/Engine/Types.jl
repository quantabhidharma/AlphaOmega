module Types

    using ..Constants

    # We use ComplexF64 to represent the U(1) phase link variables.
    # In the future, this will be replaced by an SU(3) Matrix struct.
    const Lattice = Array{ComplexF64, 4}

end