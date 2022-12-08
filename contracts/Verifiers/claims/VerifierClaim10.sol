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
contract VerifierClaim10 {
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
            1696283087047604467387705235016752683575107196615331012175232586428390106823,
            6245801410647564962317172803593993331686828552070766554505995903708171557281
        );                                      
        
        vk.IC[1] = Pairing.G1Point( 
            14285845696692353338430648697747896031027412869278131582702738336497259225368,
            4309632618987580488852127016529631304779632705157829405216344083686404639257
        );                                      
        
        vk.IC[2] = Pairing.G1Point( 
            7215154866388470862307877999306567762450673160274887336560479169892610577157,
            19881723586513166110399061216000099911453099607572104782708864015627720307501
        );                                      
        
        vk.IC[3] = Pairing.G1Point( 
            19071749056009539305534186831588402882014490285166558794418673525922626479694,
            5304630321092844262470351810967517492914611845295303929618780778901347146675
        );                                      
        
        vk.IC[4] = Pairing.G1Point( 
            16087131800822684205171809715036318418959266645099211999162132171473349213190,
            12916819761205804222462911010198624949401707415948654375725506306181269181927
        );                                      
        
        vk.IC[5] = Pairing.G1Point( 
            14193239671943940606025422246143067654089014157217341132488445391935665767807,
            954663434589861377041327147971434637475220984607430075175920644381497429883
        );                                      
        
        vk.IC[6] = Pairing.G1Point( 
            1677258757795696255096505067565352366300254100949961178608715672670280761100,
            10932243277956688234815509883569306277463354151461366170861210454320910940125
        );                                      
        
        vk.IC[7] = Pairing.G1Point( 
            6819233425069161795138813968318840953310736121309943689809817168296816614225,
            9581975438002070784578868249583330367166496889079421737563492052933983384604
        );                                      
        
        vk.IC[8] = Pairing.G1Point( 
            18989314369413972313574854916806720459950978199406758138286442641636570886199,
            741558989467927419314023557246679503699154031580629210206283115082245334107
        );                                      
        
        vk.IC[9] = Pairing.G1Point( 
            7887895061470071736308263398911963686868904585191216810526521224987389284264,
            19976589744140270678322498074872864274729620875421103569102123125801895327572
        );                                      
        
        vk.IC[10] = Pairing.G1Point( 
            16014765948903805798998705394893029342109899246260567987469723458724757876787,
            6068786659603777872001151498394089847619316204300116228840580499329662350815
        );                                      
        
        vk.IC[11] = Pairing.G1Point( 
            20664094611402119426122272390032457527351442782999065019313502420654671134791,
            16993115566729172829377335413695631874531439816332516737048093282536655820748
        );                                      
        
        vk.IC[12] = Pairing.G1Point( 
            9714420269227892747129861421369057524056212837434347137388796341978775766027,
            9318087553101240167617961151466737843044704170940431963077817008223012767288
        );                                      
        
        vk.IC[13] = Pairing.G1Point( 
            3205774889647100280018377440778624503346948341825144941720479767513499266261,
            3791782045852028471381114578596896444255480399236872924531120472729735034616
        );                                      
        
        vk.IC[14] = Pairing.G1Point( 
            4464728556609522855868132507493458740985685804230052063074729280326770622926,
            7532391557759247893048793988465513664538859143339340204399256197234652125802
        );                                      
        
        vk.IC[15] = Pairing.G1Point( 
            17233189086154158108386686863588076981441649028129392150732131215036389115368,
            10216478339363832195251356633475350370826640569034365629000909838183162145610
        );                                      
        
        vk.IC[16] = Pairing.G1Point( 
            6303253264897797238156010525763613481912491079958194626613477431028059390490,
            242708359490687431379535089283997900798142651527325792171959179930097448446
        );                                      
        
        vk.IC[17] = Pairing.G1Point( 
            1750121855755986417112318533654599268743729951963094032544613031272673157423,
            13152318204775081512091765447466309009902458152531343411668215264107257760992
        );                                      
        
        vk.IC[18] = Pairing.G1Point( 
            5964247166430375394832291459259343909299701232904018426355163089789248755566,
            6625448975391211037830688094150177099439677459186882231184890506026082157447
        );                                      
        
        vk.IC[19] = Pairing.G1Point( 
            4272849417783673148793049881471173713712218307268460479304350717768467627727,
            11115953604189438741459436811139221550107483998142491593349779813901061469836
        );                                      
        
        vk.IC[20] = Pairing.G1Point( 
            12072908937570890431012605113925657003695719291164960510609618258910693239215,
            1962874307760838301060433412554231712593429254908973623106405848533274666880
        );                                      
        
        vk.IC[21] = Pairing.G1Point( 
            436069719222446775623150317766935681185526867583692645915367284815239763917,
            5414947280987651055962235631112898336713330583126369880206143458833886537181
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
