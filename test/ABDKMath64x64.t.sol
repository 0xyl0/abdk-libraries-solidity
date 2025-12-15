// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {console2} from "forge-std/Test.sol";
import {ABDKMath64x64 as Math} from "src/ABDKMath64x64.sol";

contract ABDKMath64x64 is Test {

    function setUp() public {
    }

    function _cast(int128 x) internal returns (uint256) {
        return uint256(uint128(x));
    }

    function testFuzzDecimalConversion(uint256 x) public pure {
        x = bound(x, 0, (uint256(uint128(Math.MAX_64x64)) * Math.DECIMAL_PRECISION) >> 64);
        //console2.log(x, "x");

        int128 fd = Math.fromUnsignedDecimal(x);
        //console2.log(uint256(uint128(fd)), "uint256(fd)");

        // Inverse
        uint256 fdi = Math.toUnsignedDecimal(fd);
        //console2.log(fdi, "fdi");
        assertApproxEqAbs(fdi, x, 1, "Wrong fromDecimal inversion");
    }

    function test_log_2() public {
        console2.log(" -- log_2 --");

        // min
        console2.log("min fixed point 64.64");
        int128 minLog = Math.log_2(1);
        console2.log(Math.toUnsignedDecimal(1), "1 to dec (1/2^64) = 5.4e-20 (fixed point has better decimal precision!)");
        console2.log(_cast(minLog), "minLog");
        console2.log("minLog to dec");
        console2.log(Math.toDecimal(minLog));

        console2.log("");
        console2.log("min uint256");
        int128 conversionMinLog = Math.log_2(Math.fromUnsignedDecimal(uint256(1)));
        console2.log(_cast(conversionMinLog), "conversionMinLog");
        console2.log("conversionMinLog to dec:");
        console2.log(Math.toDecimal(conversionMinLog));

        // max
        console2.log("");
        console2.log("max fixed point 64.64");
        int128 maxLog = Math.log_2(Math.MAX_64x64);
        assertEq(Math.MAX_64x64, type(int128).max, "Wrong fixed point max");
        console2.log(Math.toUnsignedDecimal(Math.MAX_64x64), "max to dec (2^63-1)");
        console2.log(_cast(maxLog), "maxLog");
        console2.log("maxLog to dec:");
        console2.log(Math.toDecimal(maxLog));

        console2.log("");
        console2.log("max uint256");
        uint256 conversionMax = (_cast(Math.MAX_64x64) * Math.DECIMAL_PRECISION) >> 64;
        int128 conversionMaxLog = Math.log_2(Math.fromUnsignedDecimal(conversionMax));
        console2.log(conversionMax, "conversionMax (2^63-1)");
        console2.log(_cast(conversionMaxLog), "conversionMaxLog");
        console2.log("conversionMaxLog to dec:");
        console2.log(Math.toDecimal(conversionMaxLog));
    }

    function testFuzz_log_2(uint256 x) public {
        x = bound(x, 1, (_cast(type(int128).max) * Math.DECIMAL_PRECISION) >> 64);
        Math.log_2(Math.fromUnsignedDecimal(x));
    }

    function test_exp_2() public {
        console2.log(" -- exp_2 --");

        // min
        console2.log("min fixed point 64.64");
        int128 min = -0x400000000000000000;
        int128 minExp = Math.exp_2(min);
        console2.log("min:");
        console2.log(min);
        console2.log("-2^70 to dec (-2^70/2^64) = -2^6 = -64:");
        console2.log(Math.toDecimal(min));
        console2.log(_cast(minExp), "minExp (1/2^64 = 5.4e-20)");
        console2.log("minExp to dec (fixed point has better decimal precision!)");
        console2.log(Math.toDecimal(minExp));
        // below min
        assertEq(Math.exp_2(Math.fromDecimal(min - 1)), 0, "exp below min should be zero");

        console2.log("");
        console2.log("min uint256 (-64)");
        int256 conversionMin = int256(-64 * int256(Math.DECIMAL_PRECISION));
        assertEq(min, Math.fromDecimal(conversionMin), "Wrong exp min");
        int128 conversionMinExp = Math.exp_2(Math.fromDecimal(conversionMin));
        console2.log("-64 to fixed point:");
        console2.log(Math.fromDecimal(conversionMin));
        console2.log(_cast(conversionMinExp), "conversionMinExp (1/2^64 = 5.4e-20)");
        console2.log("conversionMinExp to dec (fixed point has better decimal precision!):");
        console2.log(Math.toDecimal(conversionMinExp));
        // below min
        assertEq(Math.exp_2(Math.fromDecimal(conversionMin - 1)), 0, "exp below min should be zero");

        // max
        console2.log("");
        console2.log("max fixed point 64.64");
        int128 max = 0x3F0000000000000000 - 1;
        int128 maxExp = Math.exp_2(max);
        console2.log("max:");
        console2.log(max);
        console2.log(Math.toUnsignedDecimal(max), "max to dec (63*2^64-1)");
        console2.log(_cast(maxExp), "maxExp");
        console2.log(Math.toUnsignedDecimal(maxExp), "maxExp to dec");
        assertLt(Math.toUnsignedDecimal(maxExp), (1 << 63) * Math.DECIMAL_PRECISION, "exp should be less than 2^63");
        // TODO
        //vm.expectRevert();
        //Math.exp_2(max + 1);

        console2.log("");
        console2.log("max uint256");
        uint256 conversionMax = 63 * Math.DECIMAL_PRECISION - 1;
        int128 conversionMaxExp = Math.exp_2(Math.fromUnsignedDecimal(conversionMax));
        console2.log("conversionMax to fixed point");
        console2.log(Math.fromUnsignedDecimal(conversionMax));
        console2.log(conversionMax, "conversionMax (63)");
        console2.log(_cast(conversionMaxExp), "conversionMaxExp");
        console2.log("conversionMaxExp to dec:");
        console2.log(Math.toDecimal(conversionMaxExp));
        // TODO
        //vm.expectRevert();
        //Math.exp_2(Math.fromUnsignedDecimal(conversionMax + 1));
    }

    function testFuzz_exp_2(int256 x) public {
        x = bound(x, int256(-64 * int256(Math.DECIMAL_PRECISION)), int256(63 * Math.DECIMAL_PRECISION - 1));
        Math.exp_2(Math.fromDecimal(x));
    }

    // We assume max exponent 2e18
    function test_pow() public {
        console2.log(" -- pow --");

        // min
        console2.log("");
        console2.log("min");
        /* TODO!!
         * y log x >= -59.8e18 (from log_2 min uint test), y < 2e18
         * log x >= -29.8
         * x >= 1e18 * 2^2.2 / 2^32
         */
        uint256 minX = 1e18 * 436 / 100 / uint256(1<<32);
        //uint256 minX = 1e10;
        uint256 minY = 2e18 - 1;
        console2.log(minX, "minX");
        //console2.log("mul:");
        //console2.log(Math.mul(Math.fromUnsignedDecimal(minY), Math.log_2(Math.fromUnsignedDecimal(minX))));
        //console2.log(Math.toDecimal(Math.mul(Math.fromUnsignedDecimal(minY), Math.log_2(Math.fromUnsignedDecimal(minX)))));
        uint256 minP = Math.pow(minX, minY);
        console2.log(minP, "minP");
        assertGt(minP, 0, "Reached product zero");

        // max
        console2.log("");
        console2.log("max");
        /*
         * y log x <= 63e18 - 1, y < 2e18
         * log x <= (63e18 - 1) / 2e18 ~= 31.5
         * x <= 2^(31.5) = 2^32 / 2^(1/2) <= 2^32 / 1.4143
         */
        uint256 maxX = uint256(1<<32) * 10000 / 14143 * 1e18;
        uint256 maxY = 2e18 - 1;
        console2.log(maxX, "maxX");
        //console2.log("mul:");
        //console2.log(Math.mul(Math.fromUnsignedDecimal(maxY), Math.log_2(Math.fromUnsignedDecimal(maxX))));
        //console2.log(Math.toDecimal(Math.mul(Math.fromUnsignedDecimal(maxY), Math.log_2(Math.fromUnsignedDecimal(maxX)))));
        uint256 maxP = Math.pow(maxX, maxY);
        console2.log(maxP, "maxP");
    }

    function testFuzz_pow(uint256 x, uint256 y) public {
        // (1, 2 ^32)
        x = bound(x, 1e18 * 436 / 100 / uint256(1<<32), uint256(1<<32) * 10000 / 14143 * 1e18);
        // (1e18, 2e18)
        y = bound(y, 1e18 + 1, 2e18 - 1);

        console2.log(x, "x");
        console2.log(y, "y");

        uint256 p = Math.pow(x, y);
        assertGt(p, 0, "Reached product zero");
    }
}
