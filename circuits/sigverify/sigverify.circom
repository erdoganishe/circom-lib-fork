pragma circom 2.1.8;

include "./p256/p256.circom";
include "./p256/p256_func.circom";

template SignatureVerification(){
    signal input sig[2][6];
    signal input pubkey[2][6];
    signal input message[6];

    component getGen = GetGenerator(43, 6);

    signal generator[2][6];

    generator <== getGen.out;

    var order[100] = get_p256_order(43, 6);
    signal reduced_order[6];
    for (var i = 0; i < 6; i++){
        reduced_order[i] <== order[i];
    }

    var sinv_comp[50] = mod_inv(43, 6, sig[1], order);
    signal sinv[6];
    for (var i = 0; i < 6; i++){
        sinv[i] <-- sinv_comp[i];
    }

    signal sh[6];

    component mult = BigMultModP(43,6);
    
    mult.a <== sinv;
    mult.b <== message;
    mult.p <== reduced_order;
    sh <== mult.out;


    signal sr[6];

    component mult2 = BigMultModP(43,6);
    
    mult2.a <== sinv;
    mult2.b <== sig[0];
    mult2.p <== reduced_order;
    sr <== mult2.out;

    signal tmpPoint1[2][6];
    signal tmpPoint2[2][6];

    component scalarMultiplication = P256ScalarMult(43,6);
    component scalarMultiplication2 = P256ScalarMult(43,6);
    
    scalarMultiplication.scalar <== sh;
    scalarMultiplication.point <== generator;

    tmpPoint1 <== scalarMultiplication.out;

    scalarMultiplication2.scalar <== sr;
    scalarMultiplication2.point <== pubkey;

    tmpPoint2 <== scalarMultiplication2.out;

    signal verifyX[6];

    component sumPoints = P256AddUnequal(43,6);
    
    sumPoints.a <== tmpPoint1;
    sumPoints.b <== tmpPoint2;

    verifyX <== sumPoints.out[0];

    verifyX === sig[0];
}

