pragma solidity ^0.4.16;

import "ds-test/test.sol";
import "sai/sai.t.sol";

import "./SaiProxy.sol";

contract SaiProxyTest is SaiTestBase {
    SaiProxy proxy;

    function setUp() {
        super.setUp();
        setPublicRoles();
        proxy = new SaiProxy(tub);
        tub.cork(1000 ether);
    }

    function testProxyDraw() {
        assertEq(sai.balanceOf(this), 0 ether);
        gem.transfer(proxy, 100 ether);
        proxy.draw(50 ether, ray(1.5 ether));
        proxy.pull(sai, 50 ether);

        assertEq(sai.balanceOf(this), 50 ether);
    }

    function testFailProxyDrawBelowTubMat() {
        gem.transfer(proxy, 100 ether);
        proxy.draw(50 ether, ray(0.9999 ether));
    }
}
