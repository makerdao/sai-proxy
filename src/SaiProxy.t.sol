pragma solidity ^0.4.16;

import "ds-test/test.sol";

import "./SaiProxy.sol";

contract SaiProxyTest is DSTest {
    SaiProxy proxy;

    function setUp() {
        proxy = new SaiProxy();
    }

    function testFail_basic_sanity() {
        assert(false);
    }

    function test_basic_sanity() {
        assert(true);
    }
}
