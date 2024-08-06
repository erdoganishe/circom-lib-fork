import { SignatureVerification } from "@zkit";
import { expect } from "chai";
import { ethers, zkit } from "hardhat";

function bigint_to_array(n: number, k: number, x: bigint) {
  let mod: bigint = 1n;
  for (var idx = 0; idx < n; idx++) {
    mod = mod * 2n;
  }

  let ret: bigint[] = [];
  var x_temp: bigint = x;
  for (var idx = 0; idx < k; idx++) {
    ret.push(x_temp % mod);
    x_temp = x_temp / mod;
  }
  return ret;
}

describe("Signature verifier", () => {
  let testCircuit: SignatureVerification;

  before("setup", async () => {
    testCircuit = await zkit.getCircuit("SignatureVerification");
  });

  var test_cases: Array<[bigint, bigint, bigint, bigint, bigint, boolean]> = [];

  //sigs, pubkeys and messages
  var pubkeyXs: Array<bigint> = [24699421327605645609893166675948233908378872899344623213011938273144393977536n];
  var pubkeyYs: Array<bigint> = [46735762527270948025810515628175005295095579632347210322952615593068106769364n];
  var messages: Array<bigint> = [54941067531832343686662778698436553724419331438834863383601749548219960339947n];
  var sigr: Array<bigint> = [82687486293860444451045824750298503364879493356172846243220266948966553875529n];
  var sigs: Array<bigint> = [50382842096910531307929701129386628378524358528061511415249677934737019216097n];
  var isValids: Array<boolean> = [true];

  for (var idx = 0; idx < 1; idx++) {
    test_cases.push([pubkeyXs[idx], pubkeyYs[idx], messages[idx], sigr[idx], sigs[idx], isValids[idx]]);
  }

  it("Check solution", async () => {
    let test_case = test_cases[0];

    let pubx = test_case[0];
    let puby = test_case[1];
    let message = test_case[2];
    let sigr = test_case[3];
    let sigs = test_case[4];
    let is_valid = test_case[5];

    var pubx_array: bigint[] = bigint_to_array(43, 6, pubx);
    var puby_array: bigint[] = bigint_to_array(43, 6, puby);
    var message_array: bigint[] = bigint_to_array(43, 6, message);
    var signatureR_array: bigint[] = bigint_to_array(43, 6, sigr);
    var signatureS_array: bigint[] = bigint_to_array(43, 6, sigs);

    const proofStruct = await testCircuit.generateProof({
      pubkey: [pubx_array, puby_array],
      message: message_array,
      sig: [signatureR_array, signatureS_array],
    });

    const [pA, pB, pC, publicSignals] = await testCircuit.generateCalldata(proofStruct);
  });
});
