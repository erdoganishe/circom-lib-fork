pragma circom  2.0.0;

include "./sudoku/sudoku.circom";

component main{public [board]} = SudokuVerifier();