pragma solidity ^0.4.16;

import "ds-test/test.sol";
import "sai/sai.t.sol";

import "./SaiProxy.sol";

contract SaiProxyExtended is SaiProxy {
    function open(address _tub) {
        var tub = SaiTub(_tub);
        tub.open();
    }
    function lock(address _tub, bytes32 cup, uint wad) {
        var tub = SaiTub(_tub);
        ERC20(tub.skr()).approve(tub, wad);
        tub.lock(cup, wad);
    }
}

contract SaiProxyTest is SaiTestBase {
    SaiProxyExtended proxy;

    function setUp() {
        super.setUp();
        proxy = new SaiProxyExtended();
        mom.setHat(1000 ether);
        gem.mint(900 ether);
    }

    function proxyDraw(bytes32 cup, uint wad, uint mat) {
        assertEq(sai.balanceOf(this), 0 ether);
        gem.transfer(proxy, 100 ether);
        if (cup != "") {
            proxy.draw(TubInterface(tub), cup, wad, ray(mat));
        } else {
            proxy.draw(TubInterface(tub), wad, ray(mat));
        }
        var (,ink,art) = tub.cups(1);
        assertEq(sai.balanceOf(proxy), wad);
        assertEq(art, rdiv(wad, tub.chi()));
        assertEq(ink, wdiv(rmul(wmul(vox.par(), wad), ray(mat)), tub.tag()));
    }

    function proxyWipe(bytes32 cup, uint wad, uint mat) {
        var saiBalance = uint(sai.balanceOf(proxy));
        proxy.wipe(TubInterface(tub), cup, wad, ray(mat));
        var (,ink,art) = tub.cups(1);
        assertEq(sai.balanceOf(proxy), 10 ether);
        assertEq(art, sub(saiBalance, wad));
        assertEq(ink, wmul(sub(saiBalance, wad), mat));
    }

    function testProxyDraw() {
        proxyDraw("", 50 ether, 1.5 ether);
        assertEq(skr.balanceOf(proxy), 0);
    }

    function testProxyDrawChangeMat() {
        proxyDraw("", 50 ether, 1 ether);
        assertEq(skr.balanceOf(proxy), 0);
    }

    function testProxyDrawSKRInBalance() {
        tub.join(50 ether);
        skr.transfer(proxy, 50 ether);
        assertEq(skr.balanceOf(proxy), 50 ether);
        proxyDraw("", 50 ether, 1.5 ether);
        assertEq(skr.balanceOf(proxy), 0);
    }

    function testProxyDrawSKRLocked() {
        proxy.open(tub);
        tub.join(50 ether);
        skr.transfer(proxy, 50 ether);
        proxy.lock(tub, 1, 50 ether);
        var (,ink,) = tub.cups(1);
        assertEq(ink, 50 ether);
        proxyDraw(1, 50 ether, 1.5 ether);
        assertEq(skr.balanceOf(proxy), 0);
    }

    function testProxyDrawSKRLockedExceed() {
        proxy.open(tub);
        tub.join(100 ether);
        skr.transfer(proxy, 100 ether);
        proxy.lock(tub, 1, 100 ether);
        var (,ink,) = tub.cups(1);
        assertEq(ink, 100 ether);
        proxyDraw(1, 50 ether, 1.5 ether);
    }

    function testFailProxyDrawBelowTubMat() {
        proxyDraw("", 50 ether, 0.9999 ether);
    }

    function testProxyDrawAfterPeriodChi() {
        mom.setTax(1000008022568992670911001251);  // 200% / day
        vox.warp(1 days);
        proxyDraw("", 100 ether, 1 ether);
        assertEq(skr.balanceOf(proxy), 0);
    }

    function testProxyDrawAfterPeriodPar() {
        mom.setWay(1000008022568992670911001251);  // 200% / day
        vox.warp(1 days);
        proxyDraw("", 50 ether, 1 ether);
        assertEq(skr.balanceOf(proxy), 0);
    }

    function testProxyWipe() {
        proxyDraw("", 50 ether, 1.5 ether);
        proxyWipe(1, 40 ether, 1.5 ether);
    }

    function testProxyChangeMat() {
        proxyDraw("", 50 ether, 1.5 ether);
        proxyWipe(1, 40 ether, 1 ether);
    }

    function testFailProxyWipeBelowTubMat() {
        proxyDraw("", 50 ether, 1.5 ether);
        proxyWipe(1, 40 ether, 0.9999 ether);
    }
}
