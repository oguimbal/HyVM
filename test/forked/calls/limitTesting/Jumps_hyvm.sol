// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.15;

import {IUniswapV2Router01} from "../../../utils/interfaces/IUniswapV2Router01.sol";
import {IERC20} from "../../../utils/interfaces/IERC20.sol";

/// @dev This contract has a complex constructor code
contract Jumps {
    uint256 private number;

    constructor(uint256 _number) {
        number = _number;

        function1();
        function2();
    }

    function function1() private view returns (uint256) {
        if (number % 10 == 0) {
            return 1;
        } else {
            return 0;
        }
    }

    function function2() private returns (uint256 x) {
        unchecked {
            ++number;
        }

        x = number;

        if (x == 0) {
            return x;
        }
        if (x == 1) {
            function1();
        }
        if (x == 2) {
            function2();
        }
        if (x == 3) {
            function3();
        }
        if (x == 4) {
            function4();
        }
        if (x == 5) {
            function5();
        }
        if (x == 6) {
            function6();
        }
        if (x == 7) {
            function7();
        }
        if (x == 8) {
            function8();
        } else {
            x = function1();
        }
    }

    function function3() private view {
        function1();
        function4();
    }

    function function4() private view {
        function1();
        function5();
    }

    function function5() private view {
        function1();
        function6();
    }

    function function6() private view {
        function1();
        function7();
    }

    function function7() private view {
        function1();
        function8();
    }

    function function8() private view {
        function1();
        function9();
    }

    function function9() private view {
        function1();
    }
}
