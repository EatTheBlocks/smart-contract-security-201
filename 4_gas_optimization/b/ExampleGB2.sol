// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

contract ExampleGB2 {
    function shortCircuiting(uint256 a) external pure returns (bool) {
        if (logic1(a) && logic2(a)) return true;
        return false;
    }

    function logic1(uint256 a) internal pure returns (bool) {
        //this function is simpler than logic2
        if (a > 5) return true;
        return false;
    }

    function logic2(uint256 a) internal pure returns (bool) {
        //this function is more complex than logic1
        for (uint256 i = 0; i < type(uint256).max; i++) {
            if (a == i) return true;
        }

        return false;
    }
}
