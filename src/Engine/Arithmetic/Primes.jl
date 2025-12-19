module Primes

    """
    von_mangoldt(n)
    
    The spectral signature of the Ghost Sector.
    Returns ln(p) if n is a prime power p^k, otherwise 0.
    This function defines the "hard" frequencies of the vacuum.
    """
    function von_mangoldt(n::Int)
        if n < 2
            return 0.0
        end
        
        # Factorization check
        temp = n
        p = 0
        
        # Check divisibility
        for i in 2:isqrt(n)
            if temp % i == 0
                p = i
                # Divide out all factors of p
                while temp % p == 0
                    temp ÷= p
                end
                # If temp becomes 1, n was a power of p
                if temp == 1
                    return log(p)
                else
                    # n has multiple distinct prime factors -> not a prime power
                    return 0.0
                end
            end
        end
        
        # If no factors found, n is prime
        return log(n)
    end

    """
    generate_ghost_spectrum(N)
    
    Generates the cumulative "Ghost Phase" up to energy scale N.
    This corresponds to the Chebyshev function ψ(x).
    """
    function generate_ghost_spectrum(N::Int)
        spectrum = zeros(Float64, N)
        for i in 1:N
            spectrum[i] = von_mangoldt(i)
        end
        return spectrum
    end

end