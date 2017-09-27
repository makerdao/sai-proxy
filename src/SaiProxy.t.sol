pragma solidity ^0.4.16;

import "ds-test/test.sol";
import "ds-proxy/proxy.sol";

import "sai/tub.sol";
import {SaiTestBase} from "sai/sai.t.sol";

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

contract SaiDSProxyTest is SaiTestBase {
    DSProxy    proxy;

    bytes code;
    bytes data;

    function setUp() public {
        super.setUp();
        DSProxyFactory factory = new DSProxyFactory();
        proxy = factory.build();

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
    function execute() logs_gas returns (bytes32) {
        return proxy.execute(code, data);
    }
    // n.b. `code` given below *are not optimised*. To use in a
    // frontend, compile this project with SOLC_FLAGS=--optimize and
    // copy from the corresponding files.

    // TODO: we should have some checks that the `code` here is actually
    // the same as that in the deployed contract, otherwise changes to
    // the proxy functions will be ahead of the `code`.
    function trustAll(address tub, address tap) external {
        code = hex"6060604052341561000f57600080fd5b5b6103c18061001f6000396000f300606060405263ffffffff60e060020a6000350416631e4e56eb8114610024575b600080fd5b341561002f57600080fd5b610049600160a060020a036004358116906024351661004b565b005b600080600084600160a060020a0316637bd2bea76000604051602001526040518163ffffffff1660e060020a028152600401602060405180830381600087803b151561009657600080fd5b6102c65a03f115156100a757600080fd5b5050506040518051935050600160a060020a038516630f8a771e6000604051602001526040518163ffffffff1660e060020a028152600401602060405180830381600087803b15156100f857600080fd5b6102c65a03f1151561010957600080fd5b5050506040518051925050600160a060020a038516639166cba46000604051602001526040518163ffffffff1660e060020a028152600401602060405180830381600087803b151561015a57600080fd5b6102c65a03f1151561016b57600080fd5b5050506040518051915050600160a060020a0383166306262f1b86600160405160e060020a63ffffffff8516028152600160a060020a03909216600483015215156024820152604401600060405180830381600087803b15156101cd57600080fd5b6102c65a03f115156101de57600080fd5b50505081600160a060020a03166306262f1b86600160405160e060020a63ffffffff8516028152600160a060020a03909216600483015215156024820152604401600060405180830381600087803b151561023857600080fd5b6102c65a03f1151561024957600080fd5b50505080600160a060020a03166306262f1b86600160405160e060020a63ffffffff8516028152600160a060020a03909216600483015215156024820152604401600060405180830381600087803b15156102a357600080fd5b6102c65a03f115156102b457600080fd5b50505081600160a060020a03166306262f1b85600160405160e060020a63ffffffff8516028152600160a060020a03909216600483015215156024820152604401600060405180830381600087803b151561030e57600080fd5b6102c65a03f1151561031f57600080fd5b50505080600160a060020a03166306262f1b85600160405160e060020a63ffffffff8516028152600160a060020a03909216600483015215156024820152604401600060405180830381600087803b151561037957600080fd5b6102c65a03f1151561038a57600080fd5b5050505b50505050505600a165627a7a723058208dff0c8fbac3d7cabd778e4c62d2578082271e664049deb7ef1168006e7f5d960029";
        data = msg.data;
        execute();
    }
    function join(address tub, uint wad) external {
        code = hex"6060604052341561000f57600080fd5b5b6101198061001f6000396000f300606060405263ffffffff7c01000000000000000000000000000000000000000000000000000000006000350416633b4da69f8114603c575b600080fd5b3415604657600080fd5b606873ffffffffffffffffffffffffffffffffffffffff60043516602435606a565b005b8173ffffffffffffffffffffffffffffffffffffffff1663049878f3826040517c010000000000000000000000000000000000000000000000000000000063ffffffff84160281526004810191909152602401600060405180830381600087803b151560d557600080fd5b6102c65a03f1151560e557600080fd5b5050505b50505600a165627a7a72305820ed4479dd7299933970686554e805030db89bfc364bd4b5443e2a42233dde57aa0029";
        data = msg.data;
        execute();
    }
    function exit(address tub, uint wad) external {
        code = hex"6060604052341561000f57600080fd5b5b6101198061001f6000396000f300606060405263ffffffff7c0100000000000000000000000000000000000000000000000000000000600035041663ef693bed8114603c575b600080fd5b3415604657600080fd5b606873ffffffffffffffffffffffffffffffffffffffff60043516602435606a565b005b8173ffffffffffffffffffffffffffffffffffffffff16637f8661a1826040517c010000000000000000000000000000000000000000000000000000000063ffffffff84160281526004810191909152602401600060405180830381600087803b151560d557600080fd5b6102c65a03f1151560e557600080fd5b5050505b50505600a165627a7a723058206e1cb8eb0c1323cbd1cb624faf0d4f0f5e18e68bd5b68ac64a62e73d2f348b2d0029";
        data = msg.data;
        execute();
    }
    function open(address tub) external returns (bytes32) {
        code = hex"6060604052341561000f57600080fd5b5b6101378061001f6000396000f300606060405263ffffffff7c0100000000000000000000000000000000000000000000000000000000600035041663b95460f8811461003d575b600080fd5b341561004857600080fd5b61006973ffffffffffffffffffffffffffffffffffffffff6004351661007b565b60405190815260200160405180910390f35b60008173ffffffffffffffffffffffffffffffffffffffff1663fcfff16f6000604051602001526040518163ffffffff167c0100000000000000000000000000000000000000000000000000000000028152600401602060405180830381600087803b15156100e957600080fd5b6102c65a03f115156100fa57600080fd5b50505060405180519150505b9190505600a165627a7a72305820e5c32a67e526fc00986a8439888e33e087f09d5c39fba4fedda4bcdff228554a0029";
        data = msg.data;
        return execute();
    }
    function give(address tub, bytes32 cup, address lad) external {
        code = hex"6060604052341561000f57600080fd5b5b6101438061001f6000396000f300606060405263ffffffff7c0100000000000000000000000000000000000000000000000000000000600035041663da93dfcf811461003d575b600080fd5b341561004857600080fd5b61007373ffffffffffffffffffffffffffffffffffffffff6004358116906024359060443516610075565b005b8273ffffffffffffffffffffffffffffffffffffffff1663baa8529c83836040517c010000000000000000000000000000000000000000000000000000000063ffffffff8516028152600481019290925273ffffffffffffffffffffffffffffffffffffffff166024820152604401600060405180830381600087803b15156100fd57600080fd5b6102c65a03f1151561010e57600080fd5b5050505b5050505600a165627a7a72305820d20937b4c2a8fea9d37a9e196f26afcba271de6dcab791645775d5a4f0dc5ac80029";
        data = msg.data;
        execute();
    }
    function lock(address tub, bytes32 cup, uint wad) external {
        code = hex"6060604052341561000f57600080fd5b5b6101238061001f6000396000f300606060405263ffffffff7c0100000000000000000000000000000000000000000000000000000000600035041663a80de0e88114603c575b600080fd5b3415604657600080fd5b606b73ffffffffffffffffffffffffffffffffffffffff60043516602435604435606d565b005b8273ffffffffffffffffffffffffffffffffffffffff1663b3b77a5183836040517c010000000000000000000000000000000000000000000000000000000063ffffffff851602815260048101929092526024820152604401600060405180830381600087803b151560de57600080fd5b6102c65a03f1151560ee57600080fd5b5050505b5050505600a165627a7a723058209297e5f45b7c97d0a21f1b9b439b6aa81c9f2a076dadf2e6408691bf578c61ee0029";
        data = msg.data;
        execute();
    }
    function free(address tub, bytes32 cup, uint wad) external {
        code = hex"6060604052341561000f57600080fd5b5b6101238061001f6000396000f300606060405263ffffffff7c0100000000000000000000000000000000000000000000000000000000600035041663f9ef04be8114603c575b600080fd5b3415604657600080fd5b606b73ffffffffffffffffffffffffffffffffffffffff60043516602435604435606d565b005b8273ffffffffffffffffffffffffffffffffffffffff1663a5cd184e83836040517c010000000000000000000000000000000000000000000000000000000063ffffffff851602815260048101929092526024820152604401600060405180830381600087803b151560de57600080fd5b6102c65a03f1151560ee57600080fd5b5050505b5050505600a165627a7a723058205257063db42687181bc2c722095b9ca77703c8ab77a648ca3242ceb2e6dfa2000029";
        data = msg.data;
        execute();
    }
    function draw(address tub, bytes32 cup, uint wad) external {
        code = hex"6060604052341561000f57600080fd5b5b6101238061001f6000396000f300606060405263ffffffff7c01000000000000000000000000000000000000000000000000000000006000350416630344a36f8114603c575b600080fd5b3415604657600080fd5b606b73ffffffffffffffffffffffffffffffffffffffff60043516602435604435606d565b005b8273ffffffffffffffffffffffffffffffffffffffff1663440f19ba83836040517c010000000000000000000000000000000000000000000000000000000063ffffffff851602815260048101929092526024820152604401600060405180830381600087803b151560de57600080fd5b6102c65a03f1151560ee57600080fd5b5050505b5050505600a165627a7a72305820108df29e85d425a4e040c42463845b8647edc7b5da94d4fb29cc2121353510580029";
        data = msg.data;
        execute();
    }
    function wipe(address tub, bytes32 cup, uint wad) external {
        code = hex"6060604052341561000f57600080fd5b5b6101238061001f6000396000f300606060405263ffffffff7c0100000000000000000000000000000000000000000000000000000000600035041663a3dc65a78114603c575b600080fd5b3415604657600080fd5b606b73ffffffffffffffffffffffffffffffffffffffff60043516602435604435606d565b005b8273ffffffffffffffffffffffffffffffffffffffff166373b3810183836040517c010000000000000000000000000000000000000000000000000000000063ffffffff851602815260048101929092526024820152604401600060405180830381600087803b151560de57600080fd5b6102c65a03f1151560ee57600080fd5b5050505b5050505600a165627a7a723058202f3085a6ad86c754cc40c864554f473d982950de25781d6a1d1c83befb6f9e410029";
        data = msg.data;
        execute();
    }
    function shut(address tub, bytes32 cup) external {
        code = hex"6060604052341561000f57600080fd5b5b6101198061001f6000396000f300606060405263ffffffff7c0100000000000000000000000000000000000000000000000000000000600035041663bc244c118114603c575b600080fd5b3415604657600080fd5b606873ffffffffffffffffffffffffffffffffffffffff60043516602435606a565b005b8173ffffffffffffffffffffffffffffffffffffffff1663b84d2106826040517c010000000000000000000000000000000000000000000000000000000063ffffffff84160281526004810191909152602401600060405180830381600087803b151560d557600080fd5b6102c65a03f1151560e557600080fd5b5050505b50505600a165627a7a7230582097608ea53e54efc1f198b1d44e30a37a34933a6ca439f2c0f888531e332f08920029";
        data = msg.data;
        execute();
    }
    function saisaisai(address tub, uint jam, uint wad) external {
        code = hex"6060604052341561000f57600080fd5b5b6103b18061001f6000396000f300606060405263ffffffff60e060020a600035041663a93bcc588114610024575b600080fd5b341561002f57600080fd5b610049600160a060020a036004351660243560443561005b565b60405190815260200160405180910390f35b600083818080600160a060020a038416637bd2bea782604051602001526040518163ffffffff1660e060020a028152600401602060405180830381600087803b15156100a657600080fd5b6102c65a03f115156100b757600080fd5b5050506040518051935050600160a060020a038416630f8a771e6000604051602001526040518163ffffffff1660e060020a028152600401602060405180830381600087803b151561010857600080fd5b6102c65a03f1151561011957600080fd5b5050506040518051925050600160a060020a0383166306262f1b85600160405160e060020a63ffffffff8516028152600160a060020a03909216600483015215156024820152604401600060405180830381600087803b151561017b57600080fd5b6102c65a03f1151561018c57600080fd5b50505081600160a060020a03166306262f1b85600160405160e060020a63ffffffff8516028152600160a060020a03909216600483015215156024820152604401600060405180830381600087803b15156101e657600080fd5b6102c65a03f115156101f757600080fd5b50505083600160a060020a031663049878f38860405160e060020a63ffffffff84160281526004810191909152602401600060405180830381600087803b151561024057600080fd5b6102c65a03f1151561025157600080fd5b50505083600160a060020a031663fcfff16f6000604051602001526040518163ffffffff1660e060020a028152600401602060405180830381600087803b151561029a57600080fd5b6102c65a03f115156102ab57600080fd5b5050506040518051915050600160a060020a03841663b3b77a51828960405160e060020a63ffffffff851602815260048101929092526024820152604401600060405180830381600087803b151561030257600080fd5b6102c65a03f1151561031357600080fd5b50505083600160a060020a031663440f19ba828860405160e060020a63ffffffff851602815260048101929092526024820152604401600060405180830381600087803b151561036257600080fd5b6102c65a03f1151561037357600080fd5b5050508094505b5050505093925050505600a165627a7a723058202a36195dda08d27c39c58642b94157baf1a35e1d01a90d64f578f356db48240c0029";
        data = msg.data;
        execute();
    }
    function approve(address tub, address guy, uint wad) external {
        code = hex"6060604052341561000f57600080fd5b5b6101418061001f6000396000f300606060405263ffffffff7c0100000000000000000000000000000000000000000000000000000000600035041663e1f21c67811461003d575b600080fd5b341561004857600080fd5b61007273ffffffffffffffffffffffffffffffffffffffff60043581169060243516604435610074565b005b8273ffffffffffffffffffffffffffffffffffffffff1663095ea7b383836040517c010000000000000000000000000000000000000000000000000000000063ffffffff851602815273ffffffffffffffffffffffffffffffffffffffff90921660048301526024820152604401600060405180830381600087803b15156100fb57600080fd5b6102c65a03f1151561010c57600080fd5b5050505b5050505600a165627a7a7230582051ce954c88dfbad63615b216e1dfb128b613f8a0e281beb6f2a0e3902632f2000029";
        data = msg.data;
        execute();
    }
    function trust(address tub, address guy, bool wat) external {
        code = hex"6060604052341561000f57600080fd5b5b6101458061001f6000396000f300606060405263ffffffff7c0100000000000000000000000000000000000000000000000000000000600035041663aaaf8ab2811461003d575b600080fd5b341561004857600080fd5b61007473ffffffffffffffffffffffffffffffffffffffff600435811690602435166044351515610076565b005b8273ffffffffffffffffffffffffffffffffffffffff166306262f1b83836040517c010000000000000000000000000000000000000000000000000000000063ffffffff851602815273ffffffffffffffffffffffffffffffffffffffff909216600483015215156024820152604401600060405180830381600087803b15156100ff57600080fd5b6102c65a03f1151561011057600080fd5b5050505b5050505600a165627a7a72305820d9183c88358edb0dba48e7547bdd3697f9369eb019a8051d66e6118b028f6f180029";
        data = msg.data;
        execute();
    }
    function transfer(address token, address guy, uint wad) external {
        code = hex"6060604052341561000f57600080fd5b5b6101518061001f6000396000f300606060405263ffffffff7c0100000000000000000000000000000000000000000000000000000000600035041663beabacc8811461003d575b600080fd5b341561004857600080fd5b61007273ffffffffffffffffffffffffffffffffffffffff60043581169060243516604435610074565b005b8273ffffffffffffffffffffffffffffffffffffffff1663a9059cbb83836000604051602001526040517c010000000000000000000000000000000000000000000000000000000063ffffffff851602815273ffffffffffffffffffffffffffffffffffffffff90921660048301526024820152604401602060405180830381600087803b151561010457600080fd5b6102c65a03f1151561011557600080fd5b505050604051805150505b5050505600a165627a7a72305820d700b085e59071e8806762812e8c3e1bcb1b488bf956254a1aa70e58cd87749e0029";
        data = msg.data;
        execute();
    }
    function deposit(address token, uint wad) external {
        code = hex"6060604052341561000f57600080fd5b5b60f78061001e6000396000f300606060405263ffffffff60e060020a600035041663f340fa0181146023575b600080fd5b604273ffffffffffffffffffffffffffffffffffffffff600435166044565b005b8073ffffffffffffffffffffffffffffffffffffffff16346040517f6465706f736974282900000000000000000000000000000000000000000000008152600901604051809103902060e060020a9004906040518263ffffffff1660e060020a02815260040160006040518083038185886187965a03f19350505050151560c757fe5b5b505600a165627a7a72305820e8f18f76a658ee1547e5a6d23ccb0d271d80bbcf67955acab9e0a33a50ac955a0029";
        data = msg.data;
        execute();
    }
    function withdraw(address token, uint wad) external {
        code = hex"6060604052341561000f57600080fd5b5b6101198061001f6000396000f300606060405263ffffffff7c0100000000000000000000000000000000000000000000000000000000600035041663f3fef3a38114603c575b600080fd5b3415604657600080fd5b606873ffffffffffffffffffffffffffffffffffffffff60043516602435606a565b005b8173ffffffffffffffffffffffffffffffffffffffff16632e1a7d4d826040517c010000000000000000000000000000000000000000000000000000000063ffffffff84160281526004810191909152602401600060405180830381600087803b151560d557600080fd5b6102c65a03f1151560e557600080fd5b5050505b50505600a165627a7a723058202dc943ee50bcb7138669b59b2107338c53777162e055d605325bfb99577e4d210029";
        data = msg.data;
        execute();
    }
    function testProxyTrust() public {
        assertTrue(!gem.trusted(proxy, tub));
        this.trust(gem, tub, true);
        assertTrue(gem.trusted(proxy, tub));
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
    function testProxyTrustAll() public {
        assertTrue(!gem.trusted(proxy, tub));
        assertTrue(!skr.trusted(proxy, tub));
        assertTrue(!sai.trusted(proxy, tub));

        assertTrue(!skr.trusted(proxy, tap));
        assertTrue(!sai.trusted(proxy, tap));

        this.trustAll(tub, tap);

        assertTrue(gem.trusted(proxy, tub));
        assertTrue(skr.trusted(proxy, tub));
        assertTrue(sai.trusted(proxy, tub));

        assertTrue(skr.trusted(proxy, tap));
        assertTrue(sai.trusted(proxy, tap));
    }
    function testProxyJoin() public {
        this.trustAll(tub, tap);

        assertEq(skr.balanceOf(proxy),  0 ether);

        this.join(tub, 50 ether);

        assertEq(skr.balanceOf(proxy), 50 ether);
    }
    function testProxyExit() public {
        this.trustAll(tub, tap);
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
        this.trustAll(tub, tap);
        var cup = this.open(tub);
        this.join(tub, 50 ether);

        assertEq(skr.balanceOf(proxy), 50 ether);
        assertEq(tub.ink(cup), 0);
        this.lock(tub, cup, 50 ether);
        assertEq(skr.balanceOf(proxy),  0 ether);
        assertEq(tub.ink(cup), 50 ether);
    }
    function testProxyFree() public {
        this.trustAll(tub, tap);
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
        this.trustAll(tub, tap);
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
        this.trustAll(tub, tap);
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
        this.trustAll(tub, tap);
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
    function testProxySaiSaiSai() public {
        // put in 10 ether, get 10 skr, lock it all and draw 5 sai
        this.saisaisai(tub, 10 ether, 5 ether);
        assertEq(sai.balanceOf(proxy), 5 ether);
    }
}
