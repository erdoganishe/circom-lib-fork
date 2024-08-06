pragma circom  2.1.8;

template IsEqual() {
    signal input a;
    signal input b;
    signal in <== a - b;
    signal output out;
    signal inv;
    inv <-- in!=0 ? 1/in : 0;
    out <== -in*inv +1;
    in*out === 0;
}


template isDistinctInNine() {
    signal input arr[9];
    signal output out;

    component eq[36];  // 36 = 9*(9-1)/2
    signal eqOut[36];
    
    var k = 0;
    var index = 0;
    for (var i = 0; i < 9; i++) {
        for (var j = i + 1; j < 9; j++) {
            eq[index] = IsEqual();
            eq[index].a <== arr[i];
            eq[index].b <== arr[j];
            eqOut[index] <== eq[index].out;

            index++;
        }
    }

    signal res[37];
    res[0] <== 1;
    for (var i = 1; i < 37; i++) {
        res[i] <== res[i-1]*eqOut[i-1];
    }

 
    out<== 1-res[36];
}

template IsEqualToBoard(){
    signal input solution[9][9];
    signal input board[9][9];
    signal output isValid;
    signal out[81];
    component eqCheck[162];
    component isCorrectValues[81];
    signal isCorrectValuesInSolutions[81];
    
    for (var i = 0; i < 162; i++) {
        eqCheck[i] = IsEqual();
    }

    for (var i = 0; i < 81; i++){
        isCorrectValues[i] = IsInRange();
    }

    for (var i=0; i < 9;i++){
        for (var j = 0; j < 9; j++){
            eqCheck[(i*9+j)*2].a <== 0;
            eqCheck[(i*9+j)*2].b <== board[i][j];
            eqCheck[(i*9+j)*2+1].a <== board[i][j];
            eqCheck[(i*9+j)*2+1].b <== solution[i][j];

            isCorrectValues[i*9+j].x <== solution[i][j];
            isCorrectValuesInSolutions[i*9+j] <== isCorrectValues[i*9+j].out;

            

            out[i*9+j] <==  eqCheck[(i*9+j)*2+1].out + eqCheck[(i*9+j)*2].out - eqCheck[(i*9+j)*2+1].out * eqCheck[(i*9+j)*2].out;

        }
    }
    signal res[82];
    signal res2[82];
    res[0] <== 1;
    res2[0] <== 1;
    for(var i =0; i<81; i++){
        res[i+1] <== res[i] * out[i];
        res2[i+1] <== res2[i] * isCorrectValuesInSolutions[i];

    }
    isValid <== res[81] * res2[81];

}

template IsInRange() {
    signal input x;
    signal output out;

    // Check if x is between 1 and 9
    signal oneCheck[9];
    component eq[9];

    for (var i = 1; i <= 9; i++) {
        eq[i - 1] = IsEqual();
        eq[i - 1].a <== x;
        eq[i - 1].b <== i;
        oneCheck[i - 1] <== eq[i - 1].out;
    }

    // Sum up the results to see if any of them is 1 (meaning x is between 1 and 9)
    out <== oneCheck[0] + oneCheck[1] + oneCheck[2] + oneCheck[3] + oneCheck[4] + oneCheck[5] + oneCheck[6] + oneCheck[7] + oneCheck[8];
}

template SudokuVerifier() {
    signal input solution[9][9];
    signal output isValid;
    signal input board[9][9];

    signal row[9][9];
    signal col[9][9];
    signal square[9][9];
    var index = 0;

    // Components for distinct checks
    component rowCheck[9];
    component colCheck[9];
    component squareCheck[9];
    for (var i = 0; i < 9; i++) {
        rowCheck[i] = isDistinctInNine();
        colCheck[i] = isDistinctInNine();
        squareCheck[i] = isDistinctInNine();
    }

    //rows
    for (var i = 0; i < 9; i++) {
        for (var j = 0; j < 9; j++) {
            row[index][j] <== solution[i][j];

        }
        rowCheck[i].arr <== row[index];

        index++;
    }
    index = 0;
    //columns
    for (var j = 0; j < 9; j++) {
        for (var i = 0; i < 9; i++) {
            col[index][i] <== solution[i][j];
        }
        colCheck[j].arr <== col[index];
        index++;

    }
    index = 0;

    //squares
    for (var blockRow = 0; blockRow < 3; blockRow++) {
        for (var blockCol = 0; blockCol < 3; blockCol++) {
            var otherIndex = 0;
            for (var i = 0; i < 3; i++) {
                for (var j = 0; j < 3; j++) {
                    square[index][otherIndex] <== solution[blockRow * 3 + i][blockCol * 3 + j];
                    otherIndex++;
                }
            }
            squareCheck[index].arr <== square[index];
            index++;

        }
    }


    signal res[28];
    res[0] <== 1;
    for (var i = 0; i < 9; i++) {
        res[i*3+1] <== res[i*3] * rowCheck[i].out;
        res[i*3+2] <== res[i*3+1] * colCheck[i].out;
        res[i*3+3] <== res[i*3+2] * squareCheck[i].out;

    }
    component isEqualToBoard = IsEqualToBoard();
    isEqualToBoard.board <== board;
    isEqualToBoard.solution <== solution;
    


    isValid <== res[27]*isEqualToBoard.isValid;
    isValid === 1;
  

}