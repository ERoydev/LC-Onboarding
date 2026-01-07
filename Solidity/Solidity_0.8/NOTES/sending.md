- Check if address is an address of a contract
    - if _implementation is an address to contract i can check if is a contract using:
    - require(_implementation.code.length > 0, "implementation not a contract");
    - So if code.length > 0 = Then this is a contract

- Bitwise Shifting Overview
Shiftin a number left or right in binary is fast way to multiply or divide by powers of 2
Each bit in the binary representation of a number represents a power of 2.

    - Left shift (shl(assembly)):
        - Shifting left by 1 bit is same as multiplying by 2.
        - Shifting left by n bits is the same as 2 ** n.
  
    - Right shift (shr(assembly)):
        - Shifting right by 1 bit is the same as dividing by 2.
        - Shifting right by n bits same as dividing by 2 ** n.
    
    - Example:
        - 5 = 101 in binary (3 bits).
        - Shifting 5 left by 1 bit: 101 << 1 -> 1010 (which is 10 in decimal). Same as multiplication
        - 5 << 2 -> 10100 (which is 20 in decimal)
        - 101 = 1.2^2 + 0.2^1 + 1. 2^0 = 4 + 0 + 1 = 5, 
        - when i shift left i have 1010 = 1*2^3 + 0*2^2 + 1*2^1 + 0*2^0
        - Formula: cefficient * 2^index for every bit in the bytes to receive the decimal