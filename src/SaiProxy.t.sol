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
        code = hex"6060604052341561000f57600080fd5b6103bf8061001e6000396000f300606060405263ffffffff60e060020a6000350416631e4e56eb811461002357600080fd5b341561002e57600080fd5b610048600160a060020a036004358116906024351661004a565b005b600080600084600160a060020a0316637bd2bea76000604051602001526040518163ffffffff1660e060020a028152600401602060405180830381600087803b151561009557600080fd5b6102c65a03f115156100a657600080fd5b5050506040518051935050600160a060020a038516630f8a771e6000604051602001526040518163ffffffff1660e060020a028152600401602060405180830381600087803b15156100f757600080fd5b6102c65a03f1151561010857600080fd5b5050506040518051925050600160a060020a038516639166cba46000604051602001526040518163ffffffff1660e060020a028152600401602060405180830381600087803b151561015957600080fd5b6102c65a03f1151561016a57600080fd5b5050506040518051915050600160a060020a0383166306262f1b86600160405160e060020a63ffffffff8516028152600160a060020a03909216600483015215156024820152604401600060405180830381600087803b15156101cc57600080fd5b6102c65a03f115156101dd57600080fd5b50505081600160a060020a03166306262f1b86600160405160e060020a63ffffffff8516028152600160a060020a03909216600483015215156024820152604401600060405180830381600087803b151561023757600080fd5b6102c65a03f1151561024857600080fd5b50505080600160a060020a03166306262f1b86600160405160e060020a63ffffffff8516028152600160a060020a03909216600483015215156024820152604401600060405180830381600087803b15156102a257600080fd5b6102c65a03f115156102b357600080fd5b50505081600160a060020a03166306262f1b85600160405160e060020a63ffffffff8516028152600160a060020a03909216600483015215156024820152604401600060405180830381600087803b151561030d57600080fd5b6102c65a03f1151561031e57600080fd5b50505080600160a060020a03166306262f1b85600160405160e060020a63ffffffff8516028152600160a060020a03909216600483015215156024820152604401600060405180830381600087803b151561037857600080fd5b6102c65a03f1151561038957600080fd5b50505050505050505600a165627a7a723058200f9362809e6fc0d5707d2da7bf7696bbf965e061851b984d4e231a783c8b23f60029";
        data = msg.data;
        execute();
    }
    function join(address tub, uint wad) external {
        code = hex"6060604052341561000f57600080fd5b6101178061001e6000396000f300606060405263ffffffff7c01000000000000000000000000000000000000000000000000000000006000350416633b4da69f8114603b57600080fd5b3415604557600080fd5b606773ffffffffffffffffffffffffffffffffffffffff600435166024356069565b005b8173ffffffffffffffffffffffffffffffffffffffff1663049878f3826040517c010000000000000000000000000000000000000000000000000000000063ffffffff84160281526004810191909152602401600060405180830381600087803b151560d457600080fd5b6102c65a03f1151560e457600080fd5b50505050505600a165627a7a723058209995bfaf2998a0f7cc27f42f0f6df145200d0df49c04fedd69982c4e90a1f1cd0029";
        data = msg.data;
        execute();
    }
    function exit(address tub, uint wad) external {
        code = hex"6060604052341561000f57600080fd5b6101178061001e6000396000f300606060405263ffffffff7c0100000000000000000000000000000000000000000000000000000000600035041663ef693bed8114603b57600080fd5b3415604557600080fd5b606773ffffffffffffffffffffffffffffffffffffffff600435166024356069565b005b8173ffffffffffffffffffffffffffffffffffffffff16637f8661a1826040517c010000000000000000000000000000000000000000000000000000000063ffffffff84160281526004810191909152602401600060405180830381600087803b151560d457600080fd5b6102c65a03f1151560e457600080fd5b50505050505600a165627a7a72305820b359d812cfce1e17d12fa26456fdb0b6e2f394186d67ef1fab6a44803c04ee560029";
        data = msg.data;
        execute();
    }
    function open(address tub) external returns (bytes32) {
        code = hex"6060604052341561000f57600080fd5b6101348061001e6000396000f300606060405263ffffffff7c0100000000000000000000000000000000000000000000000000000000600035041663b95460f8811461003c57600080fd5b341561004757600080fd5b61006873ffffffffffffffffffffffffffffffffffffffff6004351661007a565b60405190815260200160405180910390f35b60008173ffffffffffffffffffffffffffffffffffffffff1663fcfff16f6000604051602001526040518163ffffffff167c0100000000000000000000000000000000000000000000000000000000028152600401602060405180830381600087803b15156100e857600080fd5b6102c65a03f115156100f957600080fd5b505050604051805193925050505600a165627a7a723058202afe78a3f424cd1930c7d9af6ece33f87ed742019ba2948d8141ca8d877473980029";
        data = msg.data;
        return execute();
    }
    function give(address tub, bytes32 cup, address lad) external {
        code = hex"6060604052341561000f57600080fd5b6101418061001e6000396000f300606060405263ffffffff7c0100000000000000000000000000000000000000000000000000000000600035041663da93dfcf811461003c57600080fd5b341561004757600080fd5b61007273ffffffffffffffffffffffffffffffffffffffff6004358116906024359060443516610074565b005b8273ffffffffffffffffffffffffffffffffffffffff1663baa8529c83836040517c010000000000000000000000000000000000000000000000000000000063ffffffff8516028152600481019290925273ffffffffffffffffffffffffffffffffffffffff166024820152604401600060405180830381600087803b15156100fc57600080fd5b6102c65a03f1151561010d57600080fd5b5050505050505600a165627a7a72305820bcd361a1f9c0a17b6eed07900ae869031127555ec6656c422ea7f7714960fda80029";
        data = msg.data;
        execute();
    }
    function lock(address tub, bytes32 cup, uint wad) external {
        code = hex"6060604052341561000f57600080fd5b6101218061001e6000396000f300606060405263ffffffff7c0100000000000000000000000000000000000000000000000000000000600035041663a80de0e88114603b57600080fd5b3415604557600080fd5b606a73ffffffffffffffffffffffffffffffffffffffff60043516602435604435606c565b005b8273ffffffffffffffffffffffffffffffffffffffff1663b3b77a5183836040517c010000000000000000000000000000000000000000000000000000000063ffffffff851602815260048101929092526024820152604401600060405180830381600087803b151560dd57600080fd5b6102c65a03f1151560ed57600080fd5b5050505050505600a165627a7a723058207e31992fc69491822a4655ce5de06cab8042209f2b062a970f92503bf2ac1c270029";
        data = msg.data;
        execute();
    }
    function free(address tub, bytes32 cup, uint wad) external {
        code = hex"6060604052341561000f57600080fd5b6101218061001e6000396000f300606060405263ffffffff7c0100000000000000000000000000000000000000000000000000000000600035041663f9ef04be8114603b57600080fd5b3415604557600080fd5b606a73ffffffffffffffffffffffffffffffffffffffff60043516602435604435606c565b005b8273ffffffffffffffffffffffffffffffffffffffff1663a5cd184e83836040517c010000000000000000000000000000000000000000000000000000000063ffffffff851602815260048101929092526024820152604401600060405180830381600087803b151560dd57600080fd5b6102c65a03f1151560ed57600080fd5b5050505050505600a165627a7a7230582011cb044f1eaeed1c69f705389051bd09d46dece31e494f70cbd6dbc9ed7780030029";
        data = msg.data;
        execute();
    }
    function draw(address tub, bytes32 cup, uint wad) external {
        code = hex"6060604052341561000f57600080fd5b6101218061001e6000396000f300606060405263ffffffff7c01000000000000000000000000000000000000000000000000000000006000350416630344a36f8114603b57600080fd5b3415604557600080fd5b606a73ffffffffffffffffffffffffffffffffffffffff60043516602435604435606c565b005b8273ffffffffffffffffffffffffffffffffffffffff1663440f19ba83836040517c010000000000000000000000000000000000000000000000000000000063ffffffff851602815260048101929092526024820152604401600060405180830381600087803b151560dd57600080fd5b6102c65a03f1151560ed57600080fd5b5050505050505600a165627a7a723058203b9b54c830c4a95702a40fa910f4b28e899dba803906fb62736ac40ab27a9c3a0029";
        data = msg.data;
        execute();
    }
    function wipe(address tub, bytes32 cup, uint wad) external {
        code = hex"6060604052341561000f57600080fd5b6101218061001e6000396000f300606060405263ffffffff7c0100000000000000000000000000000000000000000000000000000000600035041663a3dc65a78114603b57600080fd5b3415604557600080fd5b606a73ffffffffffffffffffffffffffffffffffffffff60043516602435604435606c565b005b8273ffffffffffffffffffffffffffffffffffffffff166373b3810183836040517c010000000000000000000000000000000000000000000000000000000063ffffffff851602815260048101929092526024820152604401600060405180830381600087803b151560dd57600080fd5b6102c65a03f1151560ed57600080fd5b5050505050505600a165627a7a72305820bd148f73b42229bb6fc1f564b7992c1e78e04f0ebcba3eec7dc9febfca41fd7d0029";
        data = msg.data;
        execute();
    }
    function shut(address tub, bytes32 cup) external {
        code = hex"6060604052341561000f57600080fd5b6101178061001e6000396000f300606060405263ffffffff7c0100000000000000000000000000000000000000000000000000000000600035041663bc244c118114603b57600080fd5b3415604557600080fd5b606773ffffffffffffffffffffffffffffffffffffffff600435166024356069565b005b8173ffffffffffffffffffffffffffffffffffffffff1663b84d2106826040517c010000000000000000000000000000000000000000000000000000000063ffffffff84160281526004810191909152602401600060405180830381600087803b151560d457600080fd5b6102c65a03f1151560e457600080fd5b50505050505600a165627a7a72305820c1049b5b0713f6ec68e519ad9d83512e9f89c797d1840312afd2dbedefaa31900029";
        data = msg.data;
        execute();
    }
    function saisaisai(address tub, uint jam, uint wad) external {
        code = hex"6060604052341561000f57600080fd5b6103ad8061001e6000396000f300606060405263ffffffff60e060020a600035041663a93bcc58811461002357600080fd5b341561002e57600080fd5b610048600160a060020a036004351660243560443561005a565b60405190815260200160405180910390f35b600083818080600160a060020a038416637bd2bea782604051602001526040518163ffffffff1660e060020a028152600401602060405180830381600087803b15156100a557600080fd5b6102c65a03f115156100b657600080fd5b5050506040518051935050600160a060020a038416630f8a771e6000604051602001526040518163ffffffff1660e060020a028152600401602060405180830381600087803b151561010757600080fd5b6102c65a03f1151561011857600080fd5b5050506040518051925050600160a060020a0383166306262f1b85600160405160e060020a63ffffffff8516028152600160a060020a03909216600483015215156024820152604401600060405180830381600087803b151561017a57600080fd5b6102c65a03f1151561018b57600080fd5b50505081600160a060020a03166306262f1b85600160405160e060020a63ffffffff8516028152600160a060020a03909216600483015215156024820152604401600060405180830381600087803b15156101e557600080fd5b6102c65a03f115156101f657600080fd5b50505083600160a060020a031663049878f38860405160e060020a63ffffffff84160281526004810191909152602401600060405180830381600087803b151561023f57600080fd5b6102c65a03f1151561025057600080fd5b50505083600160a060020a031663fcfff16f6000604051602001526040518163ffffffff1660e060020a028152600401602060405180830381600087803b151561029957600080fd5b6102c65a03f115156102aa57600080fd5b5050506040518051915050600160a060020a03841663b3b77a51828960405160e060020a63ffffffff851602815260048101929092526024820152604401600060405180830381600087803b151561030157600080fd5b6102c65a03f1151561031257600080fd5b50505083600160a060020a031663440f19ba828860405160e060020a63ffffffff851602815260048101929092526024820152604401600060405180830381600087803b151561036157600080fd5b6102c65a03f1151561037257600080fd5b509199985050505050505050505600a165627a7a7230582059cf0749032c38be276fe082f7c71e9c59f0ac8eda9b8f446fd71f6558f7a8bb0029";
        data = msg.data;
        execute();
    }
    function approve(address tub, address guy, uint wad) external {
        code = hex"6060604052341561000f57600080fd5b61013f8061001e6000396000f300606060405263ffffffff7c0100000000000000000000000000000000000000000000000000000000600035041663e1f21c67811461003c57600080fd5b341561004757600080fd5b61007173ffffffffffffffffffffffffffffffffffffffff60043581169060243516604435610073565b005b8273ffffffffffffffffffffffffffffffffffffffff1663095ea7b383836040517c010000000000000000000000000000000000000000000000000000000063ffffffff851602815273ffffffffffffffffffffffffffffffffffffffff90921660048301526024820152604401600060405180830381600087803b15156100fa57600080fd5b6102c65a03f1151561010b57600080fd5b5050505050505600a165627a7a7230582031efbc0dac4018e79510f8e22b1bf46e9eba6c578632c3f61d2058f3cc4a801c0029";
        data = msg.data;
        execute();
    }
    function trust(address tub, address guy, bool wat) external {
        code = hex"6060604052341561000f57600080fd5b6101438061001e6000396000f300606060405263ffffffff7c0100000000000000000000000000000000000000000000000000000000600035041663aaaf8ab2811461003c57600080fd5b341561004757600080fd5b61007373ffffffffffffffffffffffffffffffffffffffff600435811690602435166044351515610075565b005b8273ffffffffffffffffffffffffffffffffffffffff166306262f1b83836040517c010000000000000000000000000000000000000000000000000000000063ffffffff851602815273ffffffffffffffffffffffffffffffffffffffff909216600483015215156024820152604401600060405180830381600087803b15156100fe57600080fd5b6102c65a03f1151561010f57600080fd5b5050505050505600a165627a7a7230582023c35c45d22a811605d4630d26373e6ffed94893f25ff66fc32c1ba4608c7d5f0029";
        data = msg.data;
        execute();
    }
    function transfer(address token, address guy, uint wad) external {
        code = hex"6060604052341561000f57600080fd5b61014f8061001e6000396000f300606060405263ffffffff7c0100000000000000000000000000000000000000000000000000000000600035041663beabacc8811461003c57600080fd5b341561004757600080fd5b61007173ffffffffffffffffffffffffffffffffffffffff60043581169060243516604435610073565b005b8273ffffffffffffffffffffffffffffffffffffffff1663a9059cbb83836000604051602001526040517c010000000000000000000000000000000000000000000000000000000063ffffffff851602815273ffffffffffffffffffffffffffffffffffffffff90921660048301526024820152604401602060405180830381600087803b151561010357600080fd5b6102c65a03f1151561011457600080fd5b505050604051805150505050505600a165627a7a723058200f432a25a3619b35d26e315b33c4d2f1e84bcb1afd838b298fdc2f0f3e0e16770029";
        data = msg.data;
        execute();
    }
    function deposit(address token, uint wad) external {
        code = hex"6060604052341561000f57600080fd5b60f98061001d6000396000f300606060405263ffffffff60e060020a60003504166347e7ef248114602257600080fd5b604473ffffffffffffffffffffffffffffffffffffffff600435166024356046565b005b8173ffffffffffffffffffffffffffffffffffffffff16816040517f6465706f736974282900000000000000000000000000000000000000000000008152600901604051809103902060e060020a9004906040518263ffffffff1660e060020a02815260040160006040518083038185886187965a03f19350505050151560c957fe5b50505600a165627a7a723058208b46775ab20436dd1b40d2bfa4712754e913e49a73973f8f99970f2850ade7650029";
        data = msg.data;
        execute();
    }
    function withdraw(address token, uint wad) external {
        code = hex"6060604052341561000f57600080fd5b6101178061001e6000396000f300606060405263ffffffff7c0100000000000000000000000000000000000000000000000000000000600035041663f3fef3a38114603b57600080fd5b3415604557600080fd5b606773ffffffffffffffffffffffffffffffffffffffff600435166024356069565b005b8173ffffffffffffffffffffffffffffffffffffffff16632e1a7d4d826040517c010000000000000000000000000000000000000000000000000000000063ffffffff84160281526004810191909152602401600060405180830381600087803b151560d457600080fd5b6102c65a03f1151560e457600080fd5b50505050505600a165627a7a723058205526bb9fea8b2fd0497993b31439b25f9843c1f46a8de6f6837555ed8ecb87040029";
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
