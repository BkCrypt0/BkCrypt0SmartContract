//
// Copyright 2017 Christian Reitwiessner
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
// 2019 OKIMS
//      ported to solidity 0.6
//      fixed linter warnings
//      added requiere error messages
//
//
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;
library Pairing {
    struct G1Point {
        uint X;
        uint Y;
    }
    // Encoding of field elements is: X[0] * z + X[1]
    struct G2Point {
        uint[2] X;
        uint[2] Y;
    }
    /// @return the generator of G1
    function P1() internal pure returns (G1Point memory) {
        return G1Point(1, 2);
    }
    /// @return the generator of G2
    function P2() internal pure returns (G2Point memory) {
        // Original code point
        return G2Point(
            [11559732032986387107991004021392285783925812861821192530917403151452391805634,
             10857046999023057135944570762232829481370756359578518086990519993285655852781],
            [4082367875863433681332203403145435568316851327593401208105741076214120093531,
             8495653923123431417604973247489272438418190587263600148770280649306958101930]
        );

/*
        // Changed by Jordi point
        return G2Point(
            [10857046999023057135944570762232829481370756359578518086990519993285655852781,
             11559732032986387107991004021392285783925812861821192530917403151452391805634],
            [8495653923123431417604973247489272438418190587263600148770280649306958101930,
             4082367875863433681332203403145435568316851327593401208105741076214120093531]
        );
*/
    }
    /// @return r the negation of p, i.e. p.addition(p.negate()) should be zero.
    function negate(G1Point memory p) internal pure returns (G1Point memory r) {
        // The prime q in the base field F_q for G1
        uint q = 21888242871839275222246405745257275088696311157297823662689037894645226208583;
        if (p.X == 0 && p.Y == 0)
            return G1Point(0, 0);
        return G1Point(p.X, q - (p.Y % q));
    }
    /// @return r the sum of two points of G1
    function addition(G1Point memory p1, G1Point memory p2) internal view returns (G1Point memory r) {
        uint[4] memory input;
        input[0] = p1.X;
        input[1] = p1.Y;
        input[2] = p2.X;
        input[3] = p2.Y;
        bool success;
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            success := staticcall(sub(gas(), 2000), 6, input, 0xc0, r, 0x60)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }
        require(success,"pairing-add-failed");
    }
    /// @return r the product of a point on G1 and a scalar, i.e.
    /// p == p.scalar_mul(1) and p.addition(p) == p.scalar_mul(2) for all points p.
    function scalar_mul(G1Point memory p, uint s) internal view returns (G1Point memory r) {
        uint[3] memory input;
        input[0] = p.X;
        input[1] = p.Y;
        input[2] = s;
        bool success;
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            success := staticcall(sub(gas(), 2000), 7, input, 0x80, r, 0x60)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }
        require (success,"pairing-mul-failed");
    }
    /// @return the result of computing the pairing check
    /// e(p1[0], p2[0]) *  .... * e(p1[n], p2[n]) == 1
    /// For example pairing([P1(), P1().negate()], [P2(), P2()]) should
    /// return true.
    function pairing(G1Point[] memory p1, G2Point[] memory p2) internal view returns (bool) {
        require(p1.length == p2.length,"pairing-lengths-failed");
        uint elements = p1.length;
        uint inputSize = elements * 6;
        uint[] memory input = new uint[](inputSize);
        for (uint i = 0; i < elements; i++)
        {
            input[i * 6 + 0] = p1[i].X;
            input[i * 6 + 1] = p1[i].Y;
            input[i * 6 + 2] = p2[i].X[0];
            input[i * 6 + 3] = p2[i].X[1];
            input[i * 6 + 4] = p2[i].Y[0];
            input[i * 6 + 5] = p2[i].Y[1];
        }
        uint[1] memory out;
        bool success;
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            success := staticcall(sub(gas(), 2000), 8, add(input, 0x20), mul(inputSize, 0x20), out, 0x20)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }
        require(success,"pairing-opcode-failed");
        return out[0] != 0;
    }
    /// Convenience method for a pairing check for two pairs.
    function pairingProd2(G1Point memory a1, G2Point memory a2, G1Point memory b1, G2Point memory b2) internal view returns (bool) {
        G1Point[] memory p1 = new G1Point[](2);
        G2Point[] memory p2 = new G2Point[](2);
        p1[0] = a1;
        p1[1] = b1;
        p2[0] = a2;
        p2[1] = b2;
        return pairing(p1, p2);
    }
    /// Convenience method for a pairing check for three pairs.
    function pairingProd3(
            G1Point memory a1, G2Point memory a2,
            G1Point memory b1, G2Point memory b2,
            G1Point memory c1, G2Point memory c2
    ) internal view returns (bool) {
        G1Point[] memory p1 = new G1Point[](3);
        G2Point[] memory p2 = new G2Point[](3);
        p1[0] = a1;
        p1[1] = b1;
        p1[2] = c1;
        p2[0] = a2;
        p2[1] = b2;
        p2[2] = c2;
        return pairing(p1, p2);
    }
    /// Convenience method for a pairing check for four pairs.
    function pairingProd4(
            G1Point memory a1, G2Point memory a2,
            G1Point memory b1, G2Point memory b2,
            G1Point memory c1, G2Point memory c2,
            G1Point memory d1, G2Point memory d2
    ) internal view returns (bool) {
        G1Point[] memory p1 = new G1Point[](4);
        G2Point[] memory p2 = new G2Point[](4);
        p1[0] = a1;
        p1[1] = b1;
        p1[2] = c1;
        p1[3] = d1;
        p2[0] = a2;
        p2[1] = b2;
        p2[2] = c2;
        p2[3] = d2;
        return pairing(p1, p2);
    }
}
contract VerifierRevoke10 {
    using Pairing for *;
    struct VerifyingKey {
        Pairing.G1Point alfa1;
        Pairing.G2Point beta2;
        Pairing.G2Point gamma2;
        Pairing.G2Point delta2;
        Pairing.G1Point[] IC;
    }
    struct Proof {
        Pairing.G1Point A;
        Pairing.G2Point B;
        Pairing.G1Point C;
    }
    function verifyingKey() internal pure returns (VerifyingKey memory vk) {
        vk.alfa1 = Pairing.G1Point(
            20491192805390485299153009773594534940189261866228447918068658471970481763042,
            9383485363053290200918347156157836566562967994039712273449902621266178545958
        );

        vk.beta2 = Pairing.G2Point(
            [4252822878758300859123897981450591353533073413197771768651442665752259397132,
             6375614351688725206403948262868962793625744043794305715222011528459656738731],
            [21847035105528745403288232691147584728191162732299865338377159692350059136679,
             10505242626370262277552901082094356697409835680220590971873171140371331206856]
        );
        vk.gamma2 = Pairing.G2Point(
            [11559732032986387107991004021392285783925812861821192530917403151452391805634,
             10857046999023057135944570762232829481370756359578518086990519993285655852781],
            [4082367875863433681332203403145435568316851327593401208105741076214120093531,
             8495653923123431417604973247489272438418190587263600148770280649306958101930]
        );
        vk.delta2 = Pairing.G2Point(
            [11559732032986387107991004021392285783925812861821192530917403151452391805634,
             10857046999023057135944570762232829481370756359578518086990519993285655852781],
            [4082367875863433681332203403145435568316851327593401208105741076214120093531,
             8495653923123431417604973247489272438418190587263600148770280649306958101930]
        );
        vk.IC = new Pairing.G1Point[](22);
        
        vk.IC[0] = Pairing.G1Point( 
            10630665629285135017513088372683423704600545736269655592574692493979870267937,
            5472017100087498461628166910172719665680276802417022022527109833550436822536
        );                                      
        
        vk.IC[1] = Pairing.G1Point( 
            12323334883163890689504764720650941414144408382408881209860181642385085563358,
            12973186527187698191107376131425885829304299690917818573747402323516739103109
        );                                      
        
        vk.IC[2] = Pairing.G1Point( 
            9052898213167427373586278521457192424666397407519420052194599915817084309659,
            12980001579262508075878895965040418114801452225821940788055621377338709528334
        );                                      
        
        vk.IC[3] = Pairing.G1Point( 
            21325446254886340072204863909680787217765824624754565799506278489599332119983,
            14378896127877246408144003245712103681913641814071552510926778561484998266367
        );                                      
        
        vk.IC[4] = Pairing.G1Point( 
            13403677809796191103852405306102357478147724527224128097972737467099682682271,
            17233220701833297577875034936549016105952817899151115745698432288052320346999
        );                                      
        
        vk.IC[5] = Pairing.G1Point( 
            4896015050789670947806344596713542274972693886457274974521796555269027449305,
            753382056735495596507095047394111420510332034183158246038035310608497216120
        );                                      
        
        vk.IC[6] = Pairing.G1Point( 
            15739723207366723868385075392614551000035069667047902335290345763840673159074,
            1581250966555209876183894613558384012702830421105647457833493922484129784143
        );                                      
        
        vk.IC[7] = Pairing.G1Point( 
            15400880962306064909129658999286995398538745615753951140973118405527287808896,
            14595265234548513730192699169952160147379658545358894866776687259437372434622
        );                                      
        
        vk.IC[8] = Pairing.G1Point( 
            19378549716182310870245814755299443692652712409839509179326097435275359576071,
            2376411105382657390038038700864212920068922030988507891121711584870138095894
        );                                      
        
        vk.IC[9] = Pairing.G1Point( 
            15899065554866419743425838786290782699726023315836285480222520635978722142440,
            1302011734036101912676407815083342091141163793558615030218976093907893397392
        );                                      
        
        vk.IC[10] = Pairing.G1Point( 
            2422441124024811701729499330121279342331286369501175101752516535887738865789,
            11697838164465961496279471280522968506936809813824995922005861350280344981671
        );                                      
        
        vk.IC[11] = Pairing.G1Point( 
            19953006511736173885860878368564205613354878725541089869491155423114474070523,
            11913001747033298379860027777243999787332739584990719375621621509320697542018
        );                                      
        
        vk.IC[12] = Pairing.G1Point( 
            14234234536744596147223819847888613641837919097401248256040788913278548281450,
            6840570195365628256969490396781157861698600520898415086738203622688124432377
        );                                      
        
        vk.IC[13] = Pairing.G1Point( 
            8360460414180443822987041632292078938744139082307032410325664318113010694367,
            16998472674641776009418953052002816130441864704696420438026660138019056073423
        );                                      
        
        vk.IC[14] = Pairing.G1Point( 
            6478049672762134861908864335784621871037386916842444212602047962358206187693,
            8593663969842330595751743855239884892762547904035040596064445247230449211473
        );                                      
        
        vk.IC[15] = Pairing.G1Point( 
            18896226656774241266275219911676708210871409820470520468729058983655349092730,
            13325084972148274129489869187640114538072006129320591747497990998095387421319
        );                                      
        
        vk.IC[16] = Pairing.G1Point( 
            12559855090420943969322119045651463406837567390439142060148398590133691015532,
            15327709150603060481955408633428739944524039741855172344265334885062486591591
        );                                      
        
        vk.IC[17] = Pairing.G1Point( 
            19812816546457104214316467371589356565263785883832214234377737254640157133840,
            1305443088350615933158147908591827935720949713551413199635978683627827771152
        );                                      
        
        vk.IC[18] = Pairing.G1Point( 
            14854089717676775660310967568444157634524459341724439653055166479352774099157,
            15439142013433886951938363958555476105247554594348155113898880301867314392565
        );                                      
        
        vk.IC[19] = Pairing.G1Point( 
            6106792418413097801143993729603806721981982640288119765816005066262694066245,
            16084372689713032222069424626703768399932702892968487471945900066768493053758
        );                                      
        
        vk.IC[20] = Pairing.G1Point( 
            19703438034213511475910734485331058888580210692231692309889259744403402050792,
            5519121519044414496735039457052604315329141608632349341709568561417924884206
        );                                      
        
        vk.IC[21] = Pairing.G1Point( 
            13168708848112881015028826158296626490123248149148358864628147434563357511117,
            14052480354825542244419558852589061576172075788405337834766074796852176031391
        );                                      
        
    }
    function verify(uint[] memory input, Proof memory proof) internal view returns (uint) {
        uint256 snark_scalar_field = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
        VerifyingKey memory vk = verifyingKey();
        require(input.length + 1 == vk.IC.length,"verifier-bad-input");
        // Compute the linear combination vk_x
        Pairing.G1Point memory vk_x = Pairing.G1Point(0, 0);
        for (uint i = 0; i < input.length; i++) {
            require(input[i] < snark_scalar_field,"verifier-gte-snark-scalar-field");
            vk_x = Pairing.addition(vk_x, Pairing.scalar_mul(vk.IC[i + 1], input[i]));
        }
        vk_x = Pairing.addition(vk_x, vk.IC[0]);
        if (!Pairing.pairingProd4(
            Pairing.negate(proof.A), proof.B,
            vk.alfa1, vk.beta2,
            vk_x, vk.gamma2,
            proof.C, vk.delta2
        )) return 1;
        return 0;
    }
    /// @return r  bool true if proof is valid
    function verifyProof(
            uint[2] memory a,
            uint[2][2] memory b,
            uint[2] memory c,
            uint[] memory input
        ) public view returns (bool r) {
        Proof memory proof;
        proof.A = Pairing.G1Point(a[0], a[1]);
        proof.B = Pairing.G2Point([b[0][0], b[0][1]], [b[1][0], b[1][1]]);
        proof.C = Pairing.G1Point(c[0], c[1]);
        uint[] memory inputValues = new uint[](input.length);
        for(uint i = 0; i < input.length; i++){
            inputValues[i] = input[i];
        }
        if (verify(inputValues, proof) == 0) {
            return true;
        } else {
            return false;
        }
    }
}
