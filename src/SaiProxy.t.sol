pragma solidity ^0.4.16;

import "ds-test/test.sol";
import "ds-proxy/proxy.sol";

import "sai/sai.t.sol";

import "./SaiProxy.sol";

contract WETH is DSToken {
    function WETH() DSToken("WETH") public {}

    function deposit() public payable {
        _balances[msg.sender] = add(_balances[msg.sender], msg.value);
        _supply = add(_supply, msg.value);
    }

    function withdraw(uint amount) public {
        _balances[msg.sender] = sub(_balances[msg.sender], amount);
        _supply = sub(_supply, amount);
        require(msg.sender.call.value(amount)());
    }
}

contract SaiDSProxyTest is DSTest, DSMath {
    DevVox   vox;
    DevTub   tub;
    DevTop   top;
    SaiTap   tap;

    SaiMom   mom;

    WETH     gem;
    DSToken  sai;
    DSToken  sin;
    DSToken  skr;
    DSToken  gov;

    address  pit;

    DSValue  pip;
    DSValue  pep;
    DSRoles  dad;

    DSProxy proxy;
    address basicActions;
    address customActions;
    address tokenActions;

    function ray(uint256 wad) internal pure returns (uint256) {
        return wad * 10 ** 9;
    }
    function wad(uint256 ray_) internal pure returns (uint256) {
        return wdiv(ray_, RAY);
    }

    function mark(uint price) internal {
        pip.poke(bytes32(price));
    }

    function mark(DSToken tkn, uint price) internal {
        if (tkn == gov) pep.poke(bytes32(price));
        else if (tkn == gem) mark(price);
    }

    function warp(uint256 age) internal {
        vox.warp(age);
        tub.warp(age);
        top.warp(age);
    }

    function setUp() public {
        GemFab gemFab = new GemFab();
        DevVoxFab voxFab = new DevVoxFab();
        DevTubFab tubFab = new DevTubFab();
        TapFab tapFab = new TapFab();
        DevTopFab topFab = new DevTopFab();
        MomFab momFab = new MomFab();
        DevDadFab dadFab = new DevDadFab();

        DaiFab daiFab = new DaiFab(gemFab, VoxFab(voxFab), TubFab(tubFab), tapFab, TopFab(topFab), momFab, DadFab(dadFab));

        gem = new WETH();
        gov = new DSToken('GOV');
        pip = new DSValue();
        pep = new DSValue();
        pit = address(0x123);

        daiFab.makeTokens();
        daiFab.makeVoxTub(gem, gov, pip, pep, pit);
        daiFab.makeTapTop();
        DSRoles authority = new DSRoles();
        authority.setRootUser(this, true);
        daiFab.configAuth(authority);

        sai = DSToken(daiFab.sai());
        sin = DSToken(daiFab.sin());
        skr = DSToken(daiFab.skr());
        vox = DevVox(daiFab.vox());
        tub = DevTub(daiFab.tub());
        tap = SaiTap(daiFab.tap());
        top = DevTop(daiFab.top());
        mom = SaiMom(daiFab.mom());
        dad = DSRoles(daiFab.dad());

        sai.approve(tub);
        skr.approve(tub);
        gem.approve(tub);
        gov.approve(tub);

        sai.approve(tap);
        skr.approve(tap);

        mark(1 ether);
        mark(gov, 1 ether);

        mom.setCap(20 ether);

        DSProxyFactory factory = new DSProxyFactory();
        proxy = factory.build();

        basicActions = address(new ProxySaiBasicActions());
        customActions = address(new ProxySaiCustomActions());
        tokenActions = address(new ProxyTokenActions());
        mom.setCap(1000 ether);
        gem.deposit.value(1000 ether)();
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

    function join(address tub_, uint wad_) external {
        tub_;wad_;
        proxy.execute(basicActions, msg.data);
    }
    function exit(address tub_, uint wad_) external {
        tub_;wad_;
        proxy.execute(basicActions, msg.data);
    }

    function open(address tub_) external returns (bytes32 cup) {
        tub_;
        cup = proxy.execute(basicActions, msg.data);
    }

    function give(address tub_, bytes32 cup, address lad) external {
        tub_;cup;lad;
        proxy.execute(basicActions, msg.data);
    }

    function lock(address tub_, bytes32 cup, uint wad_) external {
        tub_;cup;wad_;
        proxy.execute(basicActions, msg.data);
    }

    function free(address tub_, bytes32 cup, uint wad_) external {
        tub_;cup;wad_;
        proxy.execute(basicActions, msg.data);
    }

    function draw(address tub_, bytes32 cup, uint wad_) external {
        tub_;cup;wad_;
        proxy.execute(basicActions, msg.data);
    }

    function wipe(address tub_, bytes32 cup, uint wad_) external {
        tub_;cup;wad_;
        proxy.execute(basicActions, msg.data);
    }

    function shut(address tub_, bytes32 cup) external {
        tub_;cup;
        proxy.execute(basicActions, msg.data);
    }

    function bite(address tub_, bytes32 cup) external {
        tub_;cup;
        proxy.execute(basicActions, msg.data);
    }

    function bust(address tap_, uint wad_) external {
        tap_;wad_;
        proxy.execute(basicActions, msg.data);
    }

    function boom(address tap_, uint wad_) external {
        tap_;wad_;
        proxy.execute(basicActions, msg.data);
    }

    function cash(address tap_, uint wad_) external {
        tap_;wad_;
        proxy.execute(basicActions, msg.data);
    }

    function mock(address tap_, uint wad_) external {
        tap_;wad_;
        proxy.execute(basicActions, msg.data);
    }

    function approve(address tub_, address guy, uint wad_) external {
        tub_;guy;wad_;
        proxy.execute(tokenActions, msg.data);
    }

    function approve(address token, address guy, bool wat) external {
        token;guy;wat;
        proxy.execute(tokenActions, msg.data);
    }

    function transfer(address token, address guy, uint wad_) external {
        token;guy;wad_;
        proxy.execute(tokenActions, msg.data);
    }

    function deposit(address token, uint wad_) external {
        token;wad_;
        proxy.execute(tokenActions, msg.data);
    }

    function withdraw(address token, uint wad_) external {
        token;wad_;
        proxy.execute(tokenActions, msg.data);
    }

    function lockAndDraw(address tub_, uint wad_) external payable {
        tub_;wad_;
        assert(address(proxy).call.value(msg.value)(bytes4(keccak256("execute(address,bytes)")), customActions, uint256(0x40), msg.data.length, msg.data));
    }

    function lockAndDraw(address tub_, bytes32 cup, uint wad_) external payable {
        tub_;cup;wad_;
        assert(address(proxy).call.value(msg.value)(bytes4(keccak256("execute(address,bytes)")), customActions, uint256(0x40), msg.data.length, msg.data));
    }

    function wipeAndFree(address tub_, bytes32 cup, uint jam, uint wad_) external payable {
        tub_;cup;jam;wad_;
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
        bytes32 cup1 = this.open(tub);
        assertEq(cup1, bytes32(1));

        assertEq(tub.lad(cup1), proxy);
        assertEq(tub.ink(cup1), 0);
        assertEq(tub.tab(cup1), 0);

        bytes32 cup2 = this.open(tub);
        assertEq(cup2, bytes32(2));
    }

    function testProxyGive() public {
        bytes32 cup = this.open(tub);

        assertEq(tub.lad(cup), proxy);
        this.give(tub, cup, this);
        assertEq(tub.lad(cup), this);
    }

    function testProxyLock() public {
        bytes32 cup = this.open(tub);
        this.join(tub, 50 ether);

        assertEq(skr.balanceOf(proxy), 50 ether);
        assertEq(tub.ink(cup), 0);
        this.lock(tub, cup, 50 ether);
        assertEq(skr.balanceOf(proxy),  0 ether);
        assertEq(tub.ink(cup), 50 ether);
    }

    function testProxyFree() public {
        bytes32 cup = this.open(tub);
        this.join(tub, 50 ether);
        this.lock(tub, cup, 50 ether);

        assertEq(skr.balanceOf(proxy), 0 ether);
        assertEq(tub.ink(cup), 50 ether);
        this.free(tub, cup, 20 ether);
        assertEq(skr.balanceOf(proxy), 20 ether);
        assertEq(tub.ink(cup), 30 ether);
    }

    function testProxyDraw() public {
        bytes32 cup = this.open(tub);
        this.join(tub, 50 ether);
        this.lock(tub, cup, 50 ether);

        assertEq(sai.balanceOf(proxy),  0 ether);
        assertEq(tub.tab(cup),  0 ether);
        this.draw(tub, cup, 10 ether);
        assertEq(sai.balanceOf(proxy), 10 ether);
        assertEq(tub.tab(cup), 10 ether);
    }

    function testProxyWipe() public {
        bytes32 cup = this.open(tub);
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
        bytes32 cup = this.open(tub);
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
        bytes32 cup = this.open(tub);
        this.lock(tub, cup, 10 ether);

        mark(3 ether);
        this.draw(tub, cup, 16 ether);  // 125% collat
        mark(2 ether);

        assertTrue(!tub.safe(cup));
        tub.bite(cup);

        // get 2 skr, pay 4 sai (25% of the debt)
        uint sai_before = sai.balanceOf(proxy);
        uint skr_before = skr.balanceOf(proxy);
        assertEq(sai_before, 16 ether);
        this.bust(tap, 2 ether);
        uint sai_after = sai.balanceOf(proxy);
        uint skr_after = skr.balanceOf(proxy);
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
        bytes32 cup = this.open(tub);
        this.lock(tub, cup, 10 ether);
        this.draw(tub, cup, 5 ether);
        uint price = wdiv(1 ether, 2 ether);  // 100% collat
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

    function testProxyLockAndDraw() public {
        uint initialBalance = address(this).balance;
        assert(address(this).call.value(10 ether)(bytes4(keccak256("lockAndDraw(address,uint256)")), tub, 5 ether));
        assertEq(initialBalance - 10 ether, address(this).balance);
        assertEq(sai.balanceOf(this), 5 ether);
    }

    function testProxyLockAndDrawCupCreated() public {
        this.open(tub);
        uint initialBalance = address(this).balance;
        assert(address(this).call.value(10 ether)(bytes4(keccak256("lockAndDraw(address,bytes32,uint256)")), tub, 1, 5 ether));
        assertEq(initialBalance - 10 ether, address(this).balance);
        assertEq(sai.balanceOf(this), 5 ether);
    }

    function testProxyWipeAndDraw() public {
        this.open(tub);
        assert(address(this).call.value(10 ether)(bytes4(keccak256("lockAndDraw(address,bytes32,uint256)")), tub, 1, 5 ether));
        uint initialBalance = address(this).balance;
        sai.approve(proxy, uint(-1));
        this.wipeAndFree(tub, 1, 10 ether, 5 ether);
        assertEq(initialBalance + 10 ether, address(this).balance);
        assertEq(sai.balanceOf(this), 0);
    }

    function testProxyWipeAndDrawWarp() public {
        this.open(tub);
        assert(address(this).call.value(10 ether)(bytes4(keccak256("lockAndDraw(address,bytes32,uint256)")), tub, 1, 5 ether));
        uint initialBalance = address(this).balance;
        sai.approve(proxy, uint(-1));
        gov.approve(proxy, uint(-1));
        assertEq(gov.balanceOf(this), 0);
        mom.setFee(10001 * 10 ** 23);
        gov.mint(wdiv(rmul(1 * 10 ** 23, 5 ether), uint(pep.read())));
        warp(1 seconds);
        this.wipeAndFree(tub, 1, 10 ether, 5 ether);
        assertEq(initialBalance + 10 ether, address(this).balance);
        assertEq(sai.balanceOf(this), 0);
        assertEq(gov.balanceOf(this), 0);
        assertEq(gov.balanceOf(proxy), 0);
    }

    function() public payable {
    }
}
