
# Halo2 is a Plonk-based proving system

- Workshop resource: https://www.youtube.com/watch?v=60lkR8DZKUA

1. Introduction
   - A `circuit` consists of a rectangular matrix of witnesses and a set of constraints
   - Each cell in that matrix has a value which value is an element from a `finite field`
   - For each column `i`, construct a Lagrange polynomial a_i(X) interpolating the values in each column
   - at row `j`, cell A_i,j = a_i(w^^j), where `w` is n-th root of unity.

1.1. There are different types of columns in `halo2`:
   // Vary between proofs
   - Advice columns (private inputs/ witness) -> Prover can see, verifier does not now nothing about
   - Instance columns (public inputs) -> Prover and verifier can see
   // Baked into circuit
   - fixed columns + lookup tables -> Values that prover and verifier agree upon at the beginning
   - selector columns control gates    

1.2. Column Data Structure
```rs
/// Advice column.
Column<Advice>
/// Column for public input.
Column<Instance>
/// A fixed column for constants.
Column<Fixed>
/// A fixed column that holds binary constants.
Selector
/// A fixed column for a lookup table.
TableColumn 
```

1.3 Permutation Check
```rs
// Enable the ability to enforce equality over cells in this column
pub fn enable_quality<C: Into<Column<Any>>>(&mut self, column: C)
```

1.4 Add custom gate
```rs
// pub fn create_gate<C:Into<Constraing<F>>, Iter:: IntoIterator<Item = C>>(&mut self, name: &'static str, constraint impl)
```

1.5 Add a lookup argument


2. How to implement a circuit in halo2 ?
- Define a `Config` struct that holds the columns used in the circuit
- Define a `Chip` struct that configures the constraints in the circuit and provides assignment functions
- Define a circuit struct that implements the Circuit trait and. 
- Instantiate a circuit instance and feed it into the prover