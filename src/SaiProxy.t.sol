pragma solidity ^0.4.20;

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

contract SaiProxyTest is DSTest, DSMath {
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
    address saiProxy;

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

        saiProxy = address(new SaiProxy());
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

    function open(address tub_) external returns (bytes32 cup) {
        tub_;
        cup = proxy.execute(saiProxy, msg.data);
    }

    function give(address tub_, bytes32 cup_, address lad_) external {
        tub_;cup_;lad_;
        proxy.execute(saiProxy, msg.data);
    }

    function lock(address tub_, bytes32 cup_) external payable {
        tub_;cup_;
        assert(address(proxy).call.value(msg.value)(bytes4(keccak256("execute(address,bytes)")), saiProxy, uint256(0x40), msg.data.length, msg.data));
    }

    function draw(address tub_, bytes32 cup_, uint wad_) external {
        tub_;cup_;wad_;
        proxy.execute(saiProxy, msg.data);
    }

    function wipe(address tub_, bytes32 cup_, uint wad_) external {
        tub_;cup_;wad_;
        proxy.execute(saiProxy, msg.data);
    }

    function free(address tub_, bytes32 cup_, uint wad_) external {
        tub_;cup_;wad_;
        proxy.execute(saiProxy, msg.data);
    }

    function lockAndDraw(address tub_, bytes32 cup_, uint wad_) external payable {
        tub_;cup_;wad_;
        assert(address(proxy).call.value(msg.value)(bytes4(keccak256("execute(address,bytes)")), saiProxy, uint256(0x40), msg.data.length, msg.data));
    }

    function lockAndDraw(address tub_, uint wad_) external payable {
        tub_;wad_;
        assert(address(proxy).call.value(msg.value)(bytes4(keccak256("execute(address,bytes)")), saiProxy, uint256(0x40), msg.data.length, msg.data));
    }

    function wipeAndFree(address tub_, bytes32 cup_, uint jam_, uint wad_) external payable {
        tub_;cup_;jam_;wad_;
        proxy.execute(saiProxy, msg.data);
    }

    function shut(address tub_, bytes32 cup_) external {
        tub_;cup_;
        proxy.execute(saiProxy, msg.data);
    }

    function testSaiProxyOpen() public {
        bytes32 cup1 = this.open(tub);
        assertEq(cup1, bytes32(1));

        assertEq(tub.lad(cup1), proxy);
        assertEq(tub.ink(cup1), 0);
        assertEq(tub.tab(cup1), 0);

        bytes32 cup2 = this.open(tub);
        assertEq(cup2, bytes32(2));
    }

    function testSaiProxyGive() public {
        bytes32 cup = this.open(tub);

        assertEq(tub.lad(cup), proxy);
        this.give(tub, cup, this);
        assertEq(tub.lad(cup), this);
    }

    function testSaiProxyLock() public {
        bytes32 cup = this.open(tub);
        this.lock.value(50 ether)(tub, cup);

        assertEq(skr.balanceOf(this),  0 ether);
        assertEq(skr.balanceOf(proxy),  0 ether);
        assertEq(tub.ink(cup), 50 ether);
    }

    function testSaiProxyDraw() public {
        bytes32 cup = this.open(tub);
        this.lock.value(50 ether)(tub, cup);

        assertEq(sai.balanceOf(this),  0 ether);
        assertEq(sai.balanceOf(proxy),  0 ether);
        assertEq(tub.tab(cup),  0 ether);
        this.draw(tub, cup, 10 ether);
        assertEq(sai.balanceOf(this), 10 ether);
        assertEq(sai.balanceOf(proxy), 0 ether);
        assertEq(tub.tab(cup), 10 ether);
    }

    function testSaiProxyWipe() public {
        bytes32 cup = this.open(tub);
        this.lock.value(50 ether)(tub, cup);
        this.draw(tub, cup, 10 ether);

        assertEq(sai.balanceOf(this), 10 ether);
        assertEq(tub.tab(cup), 10 ether);
        sai.approve(proxy, uint(-1));
        this.wipe(tub, cup, 3 ether);
        assertEq(sai.balanceOf(this),  7 ether);
        assertEq(tub.tab(cup), 7 ether);
    }

    function testSaiProxyFree() public {
        bytes32 cup = this.open(tub);
        this.lock.value(50 ether)(tub, cup);
        assertEq(tub.ink(cup), 50 ether);
        uint initialBalance = address(this).balance;
        this.free(tub, cup, 20 ether);
        assertEq(address(this).balance, initialBalance + 20 ether);
        assertEq(tub.ink(cup), 30 ether);
    }

    function testSaiProxyLockAndDrawCupCreated() public {
        this.open(tub);
        uint initialBalance = address(this).balance;
        assert(address(this).call.value(10 ether)(bytes4(keccak256("lockAndDraw(address,bytes32,uint256)")), tub, 1, 5 ether));
        assertEq(initialBalance - 10 ether, address(this).balance);
        assertEq(sai.balanceOf(this), 5 ether);
    }

    function testSaiProxyLockAndDraw() public {
        uint initialBalance = address(this).balance;
        assert(address(this).call.value(10 ether)(bytes4(keccak256("lockAndDraw(address,uint256)")), tub, 5 ether));
        assertEq(initialBalance - 10 ether, address(this).balance);
        assertEq(sai.balanceOf(this), 5 ether);
    }

    function testSaiProxyWipeAndDraw() public {
        this.open(tub);
        assert(address(this).call.value(10 ether)(bytes4(keccak256("lockAndDraw(address,bytes32,uint256)")), tub, 1, 5 ether));
        uint initialBalance = address(this).balance;
        sai.approve(proxy, uint(-1));
        this.wipeAndFree(tub, 1, 10 ether, 5 ether);
        assertEq(initialBalance + 10 ether, address(this).balance);
        assertEq(sai.balanceOf(this), 0);
    }

    function testSaiProxyWipeAndDrawWarp() public {
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

    function testSaiProxyShut() public {
        bytes32 cup = this.open(tub);
        this.lock.value(50 ether)(tub, cup);
        this.draw(tub, cup, 10 ether);

        assertEq(tub.ink(cup), 50 ether);
        assertEq(tub.tab(cup), 10 ether);
        sai.approve(proxy, uint(-1));
        this.shut(tub, cup);
        assertEq(tub.ink(cup),  0 ether);
        assertEq(tub.tab(cup),  0 ether);
    }

    function() public payable {
    }
}
