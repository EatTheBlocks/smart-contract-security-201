// Variable Packing

// Variables not Packed
contract PackingExample1 {
    uint128 a,
    uint256 b,
    uint128 c,

    constructor(uint128 _a, uint256 _b, uint128 _c) {
        a = _a,
        b = _b,
        c = _c,
    }

}

// Varibles Packed
contract PackingExample2 {
    uint128 a,
    uint128 c,
    uint256 b,

    constructor(uint128 _a, uint256 _b, uint128 _c) {
        a = _a,
        b = _b,
        c = _c,
    }
}
