pragma solidity ^0.4.16;

import "ds-test/test.sol";
import "ds-proxy/proxy.sol";

import "sai/tub.sol";
import {SaiTestBase} from "sai/sai.t.sol";

import "./SaiProxy.sol";

contract SaiDSProxyTest is SaiTestBase {
    DSProxy proxy;
    address basicActions;
    address customActions;
    address tokenActions;

    function setUp() public {
        super.setUp();
        DSProxyFactory factory = new DSProxyFactory();
        proxy = factory.build();

        basicActions = address(new ProxySaiBasicActions());
        customActions = address(new ProxySaiCustomActions());
        tokenActions = address(new ProxyTokenActions());
        mom.setCap(1000 ether);
        gem.mint(900 ether);
        gem.push(proxy, 100 ether);
    }

    // These tests work by calling `this.foo(args)`, to set the code and
    // data state vars with the corresponding contract code and calldata
    // (including the args), followed by `execute()` to actually make
    // the proxy call. `foo` needs to have the same call signature as
    // the actual proxy function that is being tested.
    //
    // The main reason for the `this.foo` abstraction is easy
    // construction of the correct calldata.

    function join(address tub, uint wad) external {
        tub;wad;
        proxy.execute(basicActions, msg.data);
    }
    function exit(address tub, uint wad) external {
        tub;wad;
        proxy.execute(basicActions, msg.data);
    }

    function open(address tub) external returns (bytes32 cup) {
        tub;
        cup = proxy.execute(basicActions, msg.data);
    }

    function give(address tub, bytes32 cup, address lad) external {
        tub;cup;lad;
        proxy.execute(basicActions, msg.data);
    }

    function lock(address tub, bytes32 cup, uint wad) external {
        tub;cup;wad;
        proxy.execute(basicActions, msg.data);
    }

    function free(address tub, bytes32 cup, uint wad) external {
        tub;cup;wad;
        proxy.execute(basicActions, msg.data);
    }

    function draw(address tub, bytes32 cup, uint wad) external {
        tub;cup;wad;
        proxy.execute(basicActions, msg.data);
    }

    function wipe(address tub, bytes32 cup, uint wad) external {
        tub;cup;wad;
        proxy.execute(basicActions, msg.data);
    }

    function shut(address tub, bytes32 cup) external {
        tub;cup;wad;
        proxy.execute(basicActions, msg.data);
    }

    function bite(address tub, bytes32 cup) external {
        tub;cup;
        proxy.execute(basicActions, msg.data);
    }

    function bust(address tap, uint wad) external {
        tap;wad;
        proxy.execute(basicActions, msg.data);
    }

    function boom(address tap, uint wad) external {
        tap;wad;
        proxy.execute(basicActions, msg.data);
    }

    function cash(address tap, uint wad) external {
        tap;wad;
        proxy.execute(basicActions, msg.data);
    }

    function mock(address tap, uint wad) external {
        tap;wad;
        proxy.execute(basicActions, msg.data);
    }

    function approve(address tub, address guy, uint wad) external {
        tub;guy;wad;
        proxy.execute(tokenActions, msg.data);
    }

    function approve(address token, address guy, bool wat) external {
        token;guy;wat;
        proxy.execute(tokenActions, msg.data);
    }

    function transfer(address token, address guy, uint wad) external {
        token;guy;wad;
        proxy.execute(tokenActions, msg.data);
    }

    function deposit(address token, uint wad) external {
        token;wad;
        proxy.execute(tokenActions, msg.data);
    }

    function withdraw(address token, uint wad) external {
        token;wad;
        proxy.execute(tokenActions, msg.data);
    }

    function approveAll(address tub, address tap, bool wat) external {
        tub;tap;wat;
        proxy.execute(customActions, msg.data);
    }

    function drawAmount(address tub, uint jam, uint wad) external {
        tub;jam;wad;
        proxy.execute(customActions, msg.data);
    }

    function drawAmountAtMargin(address tub, bytes32 cup, uint wad, uint mat) external {
        tub;cup;wad;mat;
        proxy.execute(customActions, msg.data);
    }

    function drawAmountAtMargin(address tub, uint wad, uint mat) external {
        tub;wad;mat;
        proxy.execute(customActions, msg.data);
    }

    function wipeAmountAtMargin(address tub, bytes32 cup, uint wad, uint mat) external {
        tub;cup;wad;mat;
        proxy.execute(customActions, msg.data);
    }

    function testProxyApproveBoolean() public {
        assertTrue(gem.allowance(proxy, tub) == 0);
        this.approve(gem, tub, true);
        assertTrue(gem.allowance(proxy, tub) == uint(-1));
    }

    function testProxyApprove() public {
        assertEq(gem.allowance(proxy, tub), 0);
        this.approve(gem, tub, 10);
        assertEq(gem.allowance(proxy, tub), 10);
    }

    function testProxyTransfer() public {
        assertEq(gem.balanceOf(address(0x1)), 0);
        this.transfer(gem, address(0x1), 1 ether);
        assertEq(gem.balanceOf(address(0x1)), 1 ether);
    }

    // TODO: missing test for deposit & withdraw
    function testProxyapproveAll() public {
        assertTrue(gem.allowance(proxy, tub) == 0);
        assertTrue(gov.allowance(proxy, tub) == 0);
        assertTrue(skr.allowance(proxy, tub) == 0);
        assertTrue(sai.allowance(proxy, tub) == 0);

        assertTrue(gem.allowance(proxy, tap) == 0);
        assertTrue(skr.allowance(proxy, tap) == 0);
        assertTrue(sai.allowance(proxy, tap) == 0);

        this.approveAll(tub, tap, true);

        assertTrue(gem.allowance(proxy, tub) == uint(-1));
        assertTrue(gov.allowance(proxy, tub) == uint(-1));
        assertTrue(skr.allowance(proxy, tub) == uint(-1));
        assertTrue(sai.allowance(proxy, tub) == uint(-1));

        assertTrue(gem.allowance(proxy, tap) == uint(-1));
        assertTrue(skr.allowance(proxy, tap) == uint(-1));
        assertTrue(sai.allowance(proxy, tap) == uint(-1));

        this.approveAll(tub, tap, false);

        assertTrue(gem.allowance(proxy, tub) == 0);
        assertTrue(gov.allowance(proxy, tub) == 0);
        assertTrue(skr.allowance(proxy, tub) == 0);
        assertTrue(sai.allowance(proxy, tub) == 0);

        assertTrue(gem.allowance(proxy, tap) == 0);
        assertTrue(skr.allowance(proxy, tap) == 0);
        assertTrue(sai.allowance(proxy, tap) == 0);
    }

    function testProxyJoin() public {
        assertEq(skr.balanceOf(proxy),  0 ether);

        this.join(tub, 50 ether);

        assertEq(skr.balanceOf(proxy), 50 ether);
    }

    function testProxyExit() public {
        this.join(tub, 50 ether);

        assertEq(skr.balanceOf(proxy), 50 ether);
        assertEq(gem.balanceOf(proxy), 50 ether);

        this.exit(tub, 10 ether);

        assertEq(skr.balanceOf(proxy), 40 ether);
        assertEq(gem.balanceOf(proxy), 60 ether);
    }

    function testProxyOpen() public {
        var cup1 = this.open(tub);
        assertEq(cup1, bytes32(1));

        assertEq(tub.lad(cup1), proxy);
        assertEq(tub.ink(cup1), 0);
        assertEq(tub.tab(cup1), 0);

        var cup2 = this.open(tub);
        assertEq(cup2, bytes32(2));
    }

    function testProxyGive() public {
        var cup = this.open(tub);

        assertEq(tub.lad(cup), proxy);
        this.give(tub, cup, this);
        assertEq(tub.lad(cup), this);
    }

    function testProxyLock() public {
        var cup = this.open(tub);
        this.join(tub, 50 ether);

        assertEq(skr.balanceOf(proxy), 50 ether);
        assertEq(tub.ink(cup), 0);
        this.lock(tub, cup, 50 ether);
        assertEq(skr.balanceOf(proxy),  0 ether);
        assertEq(tub.ink(cup), 50 ether);
    }

    function testProxyFree() public {
        var cup = this.open(tub);
        this.join(tub, 50 ether);
        this.lock(tub, cup, 50 ether);

        assertEq(skr.balanceOf(proxy), 0 ether);
        assertEq(tub.ink(cup), 50 ether);
        this.free(tub, cup, 20 ether);
        assertEq(skr.balanceOf(proxy), 20 ether);
        assertEq(tub.ink(cup), 30 ether);
    }

    function testProxyDraw() public {
        var cup = this.open(tub);
        this.join(tub, 50 ether);
        this.lock(tub, cup, 50 ether);

        assertEq(sai.balanceOf(proxy),  0 ether);
        assertEq(tub.tab(cup),  0 ether);
        this.draw(tub, cup, 10 ether);
        assertEq(sai.balanceOf(proxy), 10 ether);
        assertEq(tub.tab(cup), 10 ether);
    }

    function testProxyWipe() public {
        var cup = this.open(tub);
        this.join(tub, 50 ether);
        this.lock(tub, cup, 50 ether);
        this.draw(tub, cup, 10 ether);

        assertEq(sai.balanceOf(proxy), 10 ether);
        assertEq(tub.tab(cup), 10 ether);
        this.wipe(tub, cup, 3 ether);
        assertEq(sai.balanceOf(proxy),  7 ether);
        assertEq(tub.tab(cup), 7 ether);
    }

    function testProxyShut() public {
        var cup = this.open(tub);
        this.join(tub, 50 ether);
        this.lock(tub, cup, 50 ether);
        this.draw(tub, cup, 10 ether);

        assertEq(tub.ink(cup), 50 ether);
        assertEq(tub.tab(cup), 10 ether);
        this.shut(tub, cup);
        assertEq(tub.ink(cup),  0 ether);
        assertEq(tub.tab(cup),  0 ether);
    }

    function testProxyBust() public {
        mom.setCap(100 ether);
        mom.setMat(ray(wdiv(3 ether, 2 ether)));  // 150% liq limit
        mark(2 ether);

        this.join(tub, 10 ether);
        var cup = this.open(tub);
        this.lock(tub, cup, 10 ether);

        mark(3 ether);
        this.draw(tub, cup, 16 ether);  // 125% collat
        mark(2 ether);

        assertTrue(!tub.safe(cup));
        tub.bite(cup);

        // get 2 skr, pay 4 sai (25% of the debt)
        var sai_before = sai.balanceOf(proxy);
        var skr_before = skr.balanceOf(proxy);
        assertEq(sai_before, 16 ether);
        this.bust(tap, 2 ether);
        var sai_after = sai.balanceOf(proxy);
        var skr_after = skr.balanceOf(proxy);
        assertEq(sai_before - sai_after, 4 ether);
        assertEq(skr_after - skr_before, 2 ether);
    }

    function testProxyBoom() public {
        sai.mint(tap, 50 ether);
        this.join(tub, 60 ether);

        assertEq(sai.balanceOf(proxy),  0 ether);
        assertEq(skr.balanceOf(proxy), 60 ether);
        this.boom(tap, 50 ether);
        assertEq(sai.balanceOf(proxy), 50 ether);
        assertEq(skr.balanceOf(proxy), 10 ether);
        assertEq(tap.joy(), 0);
    }

    function testProxyCash() public {
        mom.setCap(5 ether);            // 5 sai debt ceiling
        pip.poke(bytes32(1 ether));   // price 1:1 gem:ref
        mom.setMat(ray(2 ether));       // require 200% collat
        this.join(tub, 10 ether);
        var cup = this.open(tub);
        this.lock(tub, cup, 10 ether);
        this.draw(tub, cup, 5 ether);
        var price = wdiv(1 ether, 2 ether);  // 100% collat
        mark(price);
        top.cage();

        assertEq(sai.balanceOf(proxy),  5 ether);
        assertEq(skr.balanceOf(proxy),  0 ether);
        assertEq(gem.balanceOf(proxy), 90 ether);
        this.cash(tap, sai.balanceOf(proxy));
        assertEq(sai.balanceOf(proxy),   0 ether);
        assertEq(skr.balanceOf(proxy),   0 ether);
    }

    function testProxyMock() public {
        testProxyCash();
        this.mock(tap, 5 ether);
        assertEq(sai.balanceOf(proxy), 5 ether);
    }

    function testProxyDrawAmount() public {
        // put in 10 ether, get 10 skr, lock it all and draw 5 sai
        this.drawAmount(tub, 10 ether, 5 ether);
        assertEq(sai.balanceOf(proxy), 5 ether);
    }

    function proxyDraw(bytes32 cup, uint wad, uint mat) public {
        assertEq(sai.balanceOf(this), 0 ether);
        if (cup != "") {
            this.drawAmountAtMargin(tub, cup, wad, ray(mat));
        } else {
            this.drawAmountAtMargin(tub, wad, ray(mat));
        }
        var (,ink,art,) = tub.cups(1);
        assertEq(sai.balanceOf(proxy), wad);
        assertEq(art, rdiv(wad, tub.chi()));
        assertEq(ink, wdiv(rmul(wmul(vox.par(), wad), ray(mat)), tub.tag()));
    }

    function proxyWipe(bytes32 cup, uint wad, uint mat) public {
        var saiBalance = uint(sai.balanceOf(proxy));
        this.wipeAmountAtMargin(tub, cup, wad, ray(mat));
        var (,ink,art,) = tub.cups(1);
        assertEq(sai.balanceOf(proxy), 10 ether);
        assertEq(art, sub(saiBalance, wad));
        assertEq(ink, wmul(sub(saiBalance, wad), mat));
    }

    function testProxyDrawAtMargin() public {
        proxyDraw("", 50 ether, 1.5 ether);
        assertEq(skr.balanceOf(proxy), 0);
    }

    function testProxyDrawChangeMat() public {
        proxyDraw("", 50 ether, 1 ether);
        assertEq(skr.balanceOf(proxy), 0);
    }

    function testProxyDrawSKRInBalance() public {
        this.join(tub, 50 ether);
        assertEq(skr.balanceOf(proxy), 50 ether);
        proxyDraw("", 50 ether, 1.5 ether);
        assertEq(skr.balanceOf(proxy), 0);
    }

    function testProxyDrawSKRLocked() public {
        this.open(tub);
        this.join(tub, 50 ether);
        this.lock(tub, 1, 50 ether);
        var (,ink,,) = tub.cups(1);
        assertEq(ink, 50 ether);
        proxyDraw(1, 50 ether, 1.5 ether);
        assertEq(skr.balanceOf(proxy), 0);
    }

    function testProxyDrawSKRLockedExceed() public {
        this.open(tub);
        this.join(tub, 100 ether);
        this.lock(tub, 1, 100 ether);
        var (,ink,,) = tub.cups(1);
        assertEq(ink, 100 ether);
        proxyDraw(1, 50 ether, 1.5 ether);
    }

    function testFailProxyDrawBelowTubMat() public {
        proxyDraw("", 50 ether, 0.9999 ether);
    }

    function testProxyDrawAfterPeriodChi() public {
        mom.setTax(1000008022568992670911001251);  // 200% / day
        vox.warp(1 days);
        proxyDraw("", 100 ether, 1 ether);
        assertEq(skr.balanceOf(proxy), 0);
    }

    function testProxyDrawAfterPeriodPar() public {
        mom.setWay(1000008022568992670911001251);  // 200% / day
        vox.warp(1 days);
        proxyDraw("", 50 ether, 1 ether);
        assertEq(skr.balanceOf(proxy), 0);
    }

    function testProxyWipeAmountAtMargin() public {
        proxyDraw("", 50 ether, 1.5 ether);
        proxyWipe(1, 40 ether, 1.5 ether);
    }

    function testProxyWipeChangeMat() public {
        proxyDraw("", 50 ether, 1.5 ether);
        proxyWipe(1, 40 ether, 1 ether);
    }

    function testFailProxyWipeBelowTubMat() public {
        proxyDraw("", 50 ether, 1.5 ether);
        proxyWipe(1, 40 ether, 0.9999 ether);
    }
}
