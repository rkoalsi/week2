pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/poseidon.circom";
include "../node_modules/circomlib/circuits/mux1.circom";

template CheckRoot(n) { // compute the root of a MerkleTree of n Levels 
    signal input leaves[2**n];
    signal output root;

    //[assignment] insert your code here to calculate the Merkle root from 2^n leaves
    var i =2**n;
    var level = 0;
    component hash[n][i/2];
    for(var j=0; j<n;j++){
        for(var k=0; k<(i/2);k++){
            hash[j][k] = Poseidon(2);
        }
    }

    while(level<n){
        if(level == 0){
            var k=0;
            for (var j=0; j<i; j=j+2){
                hash[level][k].inputs[0] <== leaves[j];
                hash[level][k].inputs[1] <== leaves[j+1];
                k++;
            }
        } else {
            var k=0;
            for (var j=0;j<i; j=j+2){
                hash[level][k].inputs[0] <== hash[level-1][j].out;
                hash[level][k].inputs[1] <== hash[level-1][j+1].out;
                k++;
            }            

        }
        level++;                
        i = i/2;
    }
    root <== hash[n-1][0].out;
}

template returnIndex() {
    signal in;
    signal out;

    out <== in*1;
}
template MerkleTreeInclusionProof(n) {
    signal input leaf;
    signal input path_elements[n];
    signal input path_index[n]; // path index are 0's and 1's indicating whether the current element is on the left or right
    signal output root; // note that this is an OUTPUT signal

    //[assignment] insert your code here to compute the root from a leaf and elements along the path
    //The hash function will store Poseidon hashes
    component hash[n];
    component mux[n];

    // Storing outputs of Poseidon hash
    signal out[n + 1];
    out[0] <== leaf;

    for (var i = 0; i < n; i++) {
        hash[i] = Poseidon(2);
        mux[i] = MultiMux1(2);
        mux[i].c[0][0] <== out[i];
        mux[i].c[0][1] <== path_elements[i];
        mux[i].c[1][0] <== path_elements[i];
        mux[i].c[1][1] <== out[i];
        mux[i].s <== path_index[i];
        hash[i].inputs[0] <== mux[i].out[0];
        hash[i].inputs[1] <== mux[i].out[1];
        out[i + 1] <== hash[i].out;
    }

    root <== out[n];
}