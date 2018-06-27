pragma solidity ^0.4.23;

import "ds-test/test.sol";
import "ds-proxy/proxy.sol";
import "ds-token/token.sol";

import "./TokenProxy.sol";

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

contract TokenProxyTest is DSTest, DSMath {
    DSProxy proxy;
    address tokenProxy;
    WETH gem;
    address target;

    function setUp() public {
        DSProxyFactory factory = new DSProxyFactory();
        proxy = factory.build();
        tokenProxy = new TokenProxy();
        gem = new WETH();
        target = address(0x123);
    }

    // These tests work by calling `this.foo(args)`, to set the code and
    // data state vars with the corresponding contract code and calldata
    // (including the args), followed by `execute()` to actually make
    // the proxy call. `foo` needs to have the same call signature as
    // the actual proxy function that is being tested.
    //
    // The main reason for the `this.foo` abstraction is easy
    // construction of the correct calldata.

    function approve(address token_, address guy_, uint wad_) external {
        token_;guy_;wad_;
        proxy.execute(tokenProxy, msg.data);
    }

    function approve(address token_, address guy_, bool wat) external {
        token_;guy_;wat;
        proxy.execute(tokenProxy, msg.data);
    }

    function transfer(address token_, address guy_, uint wad_) external {
        token_;guy_;wad_;
        proxy.execute(tokenProxy, msg.data);
    }

    function deposit(address token_) external payable {
        token_;
        assert(address(proxy).call.value(msg.value)(bytes4(keccak256("execute(address,bytes)")), tokenProxy, uint256(0x40), msg.data.length, msg.data));
    }

    function withdraw(address token_, uint wad_) external {
        token_;wad_;
        proxy.execute(tokenProxy, msg.data);
    }

    function testTokenProxyApprove() public {
        assertEq(gem.allowance(proxy, target), 0);
        this.approve(gem, target, 10);
        assertEq(gem.allowance(proxy, target), 10);
    }

    function testTokenProxyTransfer() public {
        gem.mint(1);
        gem.transfer(proxy, 1);
        assertEq(gem.balanceOf(proxy), 1);
        assertEq(gem.balanceOf(address(0x1)), 0);
        this.transfer(gem, address(0x1), 1);
        assertEq(gem.balanceOf(proxy), 0);
        assertEq(gem.balanceOf(address(0x1)), 1);
    }

    function testTokenProxyDeposit() public {
        uint initialBalance = address(this).balance;
        assertEq(gem.balanceOf(proxy), 0);
        this.deposit.value(10)(gem);
        assertEq(gem.balanceOf(proxy), 10);
        assertEq(address(this).balance, initialBalance - 10);
    }

    function testTokenProxyWithdraw() public {
        this.deposit.value(10)(gem);
        uint initialBalance = address(proxy).balance;
        this.withdraw(gem, 6);
        assertEq(gem.balanceOf(proxy), 4);
        assertEq(address(proxy).balance, initialBalance + 6);
    }
}
