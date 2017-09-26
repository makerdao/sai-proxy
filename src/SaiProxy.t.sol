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
    function trust(address tub, address tap) external {
        code = hex"6060604052341561000f57600080fd5b61060f8061001e6000396000f30060606040526000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff168063171c342a1461003d57600080fd5b341561004857600080fd5b610093600480803573ffffffffffffffffffffffffffffffffffffffff1690602001909190803573ffffffffffffffffffffffffffffffffffffffff16906020019091905050610095565b005b60008060008473ffffffffffffffffffffffffffffffffffffffff16637bd2bea76000604051602001526040518163ffffffff167c0100000000000000000000000000000000000000000000000000000000028152600401602060405180830381600087803b151561010657600080fd5b6102c65a03f1151561011757600080fd5b5050506040518051905092508473ffffffffffffffffffffffffffffffffffffffff16630f8a771e6000604051602001526040518163ffffffff167c0100000000000000000000000000000000000000000000000000000000028152600401602060405180830381600087803b151561018f57600080fd5b6102c65a03f115156101a057600080fd5b5050506040518051905091508473ffffffffffffffffffffffffffffffffffffffff16639166cba46000604051602001526040518163ffffffff167c0100000000000000000000000000000000000000000000000000000000028152600401602060405180830381600087803b151561021857600080fd5b6102c65a03f1151561022957600080fd5b5050506040518051905090508273ffffffffffffffffffffffffffffffffffffffff166306262f1b8660016040518363ffffffff167c0100000000000000000000000000000000000000000000000000000000028152600401808373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020018215151515815260200192505050600060405180830381600087803b15156102dc57600080fd5b6102c65a03f115156102ed57600080fd5b5050508173ffffffffffffffffffffffffffffffffffffffff166306262f1b8660016040518363ffffffff167c0100000000000000000000000000000000000000000000000000000000028152600401808373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020018215151515815260200192505050600060405180830381600087803b151561039757600080fd5b6102c65a03f115156103a857600080fd5b5050508073ffffffffffffffffffffffffffffffffffffffff166306262f1b8660016040518363ffffffff167c0100000000000000000000000000000000000000000000000000000000028152600401808373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020018215151515815260200192505050600060405180830381600087803b151561045257600080fd5b6102c65a03f1151561046357600080fd5b5050508173ffffffffffffffffffffffffffffffffffffffff166306262f1b8560016040518363ffffffff167c0100000000000000000000000000000000000000000000000000000000028152600401808373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020018215151515815260200192505050600060405180830381600087803b151561050d57600080fd5b6102c65a03f1151561051e57600080fd5b5050508073ffffffffffffffffffffffffffffffffffffffff166306262f1b8560016040518363ffffffff167c0100000000000000000000000000000000000000000000000000000000028152600401808373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020018215151515815260200192505050600060405180830381600087803b15156105c857600080fd5b6102c65a03f115156105d957600080fd5b50505050505050505600a165627a7a723058204cffd9fa4460eaaca52c76bbd7d75b4de1619065e5e1a665a97a0ad751fd4fb20029";
        data = msg.data;
        execute();
    }
    function join(address tub, uint wad) external {
        code = hex"6060604052341561000f57600080fd5b6101318061001e6000396000f30060606040526000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff1680633b4da69f1461003d57600080fd5b341561004857600080fd5b61007d600480803573ffffffffffffffffffffffffffffffffffffffff1690602001909190803590602001909190505061007f565b005b8173ffffffffffffffffffffffffffffffffffffffff1663049878f3826040518263ffffffff167c010000000000000000000000000000000000000000000000000000000002815260040180828152602001915050600060405180830381600087803b15156100ed57600080fd5b6102c65a03f115156100fe57600080fd5b50505050505600a165627a7a72305820b8be9fa7651cb9a11b37c9da52e15500a2c05ddd90daf51af75de5ed3652733a0029";
        data = msg.data;
        execute();
    }
    function exit(address tub, uint wad) external {
        code = hex"6060604052341561000f57600080fd5b6101318061001e6000396000f30060606040526000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff168063ef693bed1461003d57600080fd5b341561004857600080fd5b61007d600480803573ffffffffffffffffffffffffffffffffffffffff1690602001909190803590602001909190505061007f565b005b8173ffffffffffffffffffffffffffffffffffffffff16637f8661a1826040518263ffffffff167c010000000000000000000000000000000000000000000000000000000002815260040180828152602001915050600060405180830381600087803b15156100ed57600080fd5b6102c65a03f115156100fe57600080fd5b50505050505600a165627a7a72305820d4f01566def79e91c1d29a8b5ccf3e577e37591f2ae1afd979d025fb4398f9220029";
        data = msg.data;
        execute();
    }
    function open(address tub) external returns (bytes32) {
        code = hex"6060604052341561000f57600080fd5b61014e8061001e6000396000f30060606040526000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff168063b95460f81461003d57600080fd5b341561004857600080fd5b610074600480803573ffffffffffffffffffffffffffffffffffffffff16906020019091905050610092565b60405180826000191660001916815260200191505060405180910390f35b60008173ffffffffffffffffffffffffffffffffffffffff1663fcfff16f6000604051602001526040518163ffffffff167c0100000000000000000000000000000000000000000000000000000000028152600401602060405180830381600087803b151561010057600080fd5b6102c65a03f1151561011157600080fd5b5050506040518051905090509190505600a165627a7a72305820d859855ae3513a85854824381dfcd35baab39d34c6d7cf49cac0b8a3dd3f8a1c0029";
        data = msg.data;
        return execute();
    }
    function give(address tub, bytes32 cup, address lad) external {
        code = hex"6060604052341561000f57600080fd5b6101918061001e6000396000f30060606040526000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff168063da93dfcf1461003d57600080fd5b341561004857600080fd5b6100a0600480803573ffffffffffffffffffffffffffffffffffffffff169060200190919080356000191690602001909190803573ffffffffffffffffffffffffffffffffffffffff169060200190919050506100a2565b005b8273ffffffffffffffffffffffffffffffffffffffff1663baa8529c83836040518363ffffffff167c01000000000000000000000000000000000000000000000000000000000281526004018083600019166000191681526020018273ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200192505050600060405180830381600087803b151561014c57600080fd5b6102c65a03f1151561015d57600080fd5b5050505050505600a165627a7a7230582000f8e3a3fbab8a4f85e2445e106f2201dbb743b740d2d9646afacb72526faefa0029";
        data = msg.data;
        execute();
    }
    function lock(address tub, bytes32 cup, uint wad) external {
        code = hex"6060604052341561000f57600080fd5b61014f8061001e6000396000f30060606040526000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff168063a80de0e81461003d57600080fd5b341561004857600080fd5b61008a600480803573ffffffffffffffffffffffffffffffffffffffff169060200190919080356000191690602001909190803590602001909190505061008c565b005b8273ffffffffffffffffffffffffffffffffffffffff1663b3b77a5183836040518363ffffffff167c010000000000000000000000000000000000000000000000000000000002815260040180836000191660001916815260200182815260200192505050600060405180830381600087803b151561010a57600080fd5b6102c65a03f1151561011b57600080fd5b5050505050505600a165627a7a72305820cfb7adefe8893794fec92e2331a84e99e630777e19c653ca58e3fb7ba29fb9b80029";
        data = msg.data;
        execute();
    }
    function free(address tub, bytes32 cup, uint wad) external {
        code = hex"6060604052341561000f57600080fd5b61014f8061001e6000396000f30060606040526000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff168063f9ef04be1461003d57600080fd5b341561004857600080fd5b61008a600480803573ffffffffffffffffffffffffffffffffffffffff169060200190919080356000191690602001909190803590602001909190505061008c565b005b8273ffffffffffffffffffffffffffffffffffffffff1663a5cd184e83836040518363ffffffff167c010000000000000000000000000000000000000000000000000000000002815260040180836000191660001916815260200182815260200192505050600060405180830381600087803b151561010a57600080fd5b6102c65a03f1151561011b57600080fd5b5050505050505600a165627a7a72305820c1e86527a987f14663e71c0f55a005d2389aaa546b5d2dbae3c28421538e85630029";
        data = msg.data;
        execute();
    }
    function draw(address tub, bytes32 cup, uint wad) external {
        code = hex"6060604052341561000f57600080fd5b61014f8061001e6000396000f30060606040526000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff1680630344a36f1461003d57600080fd5b341561004857600080fd5b61008a600480803573ffffffffffffffffffffffffffffffffffffffff169060200190919080356000191690602001909190803590602001909190505061008c565b005b8273ffffffffffffffffffffffffffffffffffffffff1663440f19ba83836040518363ffffffff167c010000000000000000000000000000000000000000000000000000000002815260040180836000191660001916815260200182815260200192505050600060405180830381600087803b151561010a57600080fd5b6102c65a03f1151561011b57600080fd5b5050505050505600a165627a7a723058203f2c6f02d377d4584be9cbc05e5153372b7dc53fceecc25d9fe8412a7515bc8a0029";
        data = msg.data;
        execute();
    }
    function wipe(address tub, bytes32 cup, uint wad) external {
        code = hex"6060604052341561000f57600080fd5b61014f8061001e6000396000f30060606040526000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff168063a3dc65a71461003d57600080fd5b341561004857600080fd5b61008a600480803573ffffffffffffffffffffffffffffffffffffffff169060200190919080356000191690602001909190803590602001909190505061008c565b005b8273ffffffffffffffffffffffffffffffffffffffff166373b3810183836040518363ffffffff167c010000000000000000000000000000000000000000000000000000000002815260040180836000191660001916815260200182815260200192505050600060405180830381600087803b151561010a57600080fd5b6102c65a03f1151561011b57600080fd5b5050505050505600a165627a7a72305820a1ace1a9f838efa4cb0b64019387bea20810588127ce1e8453f7f85af692974e0029";
        data = msg.data;
        execute();
    }
    function shut(address tub, bytes32 cup) external {
        code = hex"6060604052341561000f57600080fd5b61013d8061001e6000396000f30060606040526000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff168063bc244c111461003d57600080fd5b341561004857600080fd5b610081600480803573ffffffffffffffffffffffffffffffffffffffff1690602001909190803560001916906020019091905050610083565b005b8173ffffffffffffffffffffffffffffffffffffffff1663b84d2106826040518263ffffffff167c0100000000000000000000000000000000000000000000000000000000028152600401808260001916600019168152602001915050600060405180830381600087803b15156100f957600080fd5b6102c65a03f1151561010a57600080fd5b50505050505600a165627a7a72305820c10c4b56fe71c528fcfacf12d337026c711d182015e66c1d82b2ffd074a0e8ca0029";
        data = msg.data;
        execute();
    }
    function saisaisai(address tub, uint jam, uint wad) external {
        code = hex"6060604052341561000f57600080fd5b6105a08061001e6000396000f30060606040526000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff168063a93bcc581461003d57600080fd5b341561004857600080fd5b610086600480803573ffffffffffffffffffffffffffffffffffffffff169060200190919080359060200190919080359060200190919050506100a4565b60405180826000191660001916815260200191505060405180910390f35b60008060008060008793508373ffffffffffffffffffffffffffffffffffffffff16637bd2bea76000604051602001526040518163ffffffff167c0100000000000000000000000000000000000000000000000000000000028152600401602060405180830381600087803b151561011b57600080fd5b6102c65a03f1151561012c57600080fd5b5050506040518051905092508373ffffffffffffffffffffffffffffffffffffffff16630f8a771e6000604051602001526040518163ffffffff167c0100000000000000000000000000000000000000000000000000000000028152600401602060405180830381600087803b15156101a457600080fd5b6102c65a03f115156101b557600080fd5b5050506040518051905091508273ffffffffffffffffffffffffffffffffffffffff166306262f1b8560016040518363ffffffff167c0100000000000000000000000000000000000000000000000000000000028152600401808373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020018215151515815260200192505050600060405180830381600087803b151561026857600080fd5b6102c65a03f1151561027957600080fd5b5050508173ffffffffffffffffffffffffffffffffffffffff166306262f1b8560016040518363ffffffff167c0100000000000000000000000000000000000000000000000000000000028152600401808373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020018215151515815260200192505050600060405180830381600087803b151561032357600080fd5b6102c65a03f1151561033457600080fd5b5050508373ffffffffffffffffffffffffffffffffffffffff1663049878f3886040518263ffffffff167c010000000000000000000000000000000000000000000000000000000002815260040180828152602001915050600060405180830381600087803b15156103a557600080fd5b6102c65a03f115156103b657600080fd5b5050508373ffffffffffffffffffffffffffffffffffffffff1663fcfff16f6000604051602001526040518163ffffffff167c0100000000000000000000000000000000000000000000000000000000028152600401602060405180830381600087803b151561042557600080fd5b6102c65a03f1151561043657600080fd5b5050506040518051905090508373ffffffffffffffffffffffffffffffffffffffff1663b3b77a5182896040518363ffffffff167c010000000000000000000000000000000000000000000000000000000002815260040180836000191660001916815260200182815260200192505050600060405180830381600087803b15156104c057600080fd5b6102c65a03f115156104d157600080fd5b5050508373ffffffffffffffffffffffffffffffffffffffff1663440f19ba82886040518363ffffffff167c010000000000000000000000000000000000000000000000000000000002815260040180836000191660001916815260200182815260200192505050600060405180830381600087803b151561055257600080fd5b6102c65a03f1151561056357600080fd5b5050508094505050505093925050505600a165627a7a72305820fac0e13172161273daa09dad4e6a8ef73501eb609b2091a2019bd562148c00fe0029";
        data = msg.data;
        execute();
    }

    function testProxyTrust() public {
        assertTrue(!gem.trusted(proxy, tub));
        assertTrue(!skr.trusted(proxy, tub));
        assertTrue(!sai.trusted(proxy, tub));

        assertTrue(!skr.trusted(proxy, tap));
        assertTrue(!sai.trusted(proxy, tap));

        this.trust(tub, tap);

        assertTrue(gem.trusted(proxy, tub));
        assertTrue(skr.trusted(proxy, tub));
        assertTrue(sai.trusted(proxy, tub));

        assertTrue(skr.trusted(proxy, tap));
        assertTrue(sai.trusted(proxy, tap));
    }
    function testProxyJoin() public {
        this.trust(tub, tap);

        assertEq(skr.balanceOf(proxy),  0 ether);

        this.join(tub, 50 ether);

        assertEq(skr.balanceOf(proxy), 50 ether);
    }
    function testProxyExit() public {
        this.trust(tub, tap);
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
        this.trust(tub, tap);
        var cup = this.open(tub);
        this.join(tub, 50 ether);

        assertEq(skr.balanceOf(proxy), 50 ether);
        assertEq(tub.ink(cup), 0);
        this.lock(tub, cup, 50 ether);
        assertEq(skr.balanceOf(proxy),  0 ether);
        assertEq(tub.ink(cup), 50 ether);
    }
    function testProxyFree() public {
        this.trust(tub, tap);
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
        this.trust(tub, tap);
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
        this.trust(tub, tap);
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
        this.trust(tub, tap);
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
