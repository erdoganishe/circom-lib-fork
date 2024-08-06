pragma circom 2.0.0;

include "./sigverify/sigverify.circom";

component main{public [pubkey]} = SignatureVerification();