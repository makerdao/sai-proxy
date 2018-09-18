pragma solidity ^0.4.23;

import "./SaiProxy.t.sol";
import "./SaiProxyCreateAndExecute.sol";

contract SaiProxyCreateAndExecuteTest is SaiProxyTest {
    SaiProxyCreateAndExecute creator;

    function setUp() public {
        super.setUp();
        creator = new SaiProxyCreateAndExecute();
    }

    function testCreateAndOpen() public {
        uint initialBalance = address(this).balance;
        address newProxy;
        (newProxy,) = creator.createAndOpen(factory, tub);
        assertEq(initialBalance, address(this).balance);
        assertEq(sai.balanceOf(this), 0);
        assertEq(DSProxy(newProxy).owner(), this);
    }

    function testCreateOpenAndLock() public {
        uint initialBalance = address(this).balance;
        address newProxy;
        (newProxy,) = creator.createOpenAndLock.value(10 ether)(factory, tub);
        assertEq(initialBalance - 10 ether, address(this).balance);
        assertEq(sai.balanceOf(this), 0);
        assertEq(DSProxy(newProxy).owner(), this);
    }

    function testCreateOpenLockAndDraw() public {
        uint initialBalance = address(this).balance;
        address newProxy;
        (newProxy,) = creator.createOpenLockAndDraw.value(10 ether)(factory, tub, 5 ether);
        assertEq(initialBalance - 10 ether, address(this).balance);
        assertEq(sai.balanceOf(this), 5 ether);
        assertEq(DSProxy(newProxy).owner(), this);
    }

    function testFailSendFunds() public {
        assert(address(creator).call.value(1 ether)());
    }

    function() public payable {}
}
