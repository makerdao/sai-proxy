pragma solidity ^0.4.23;

import "./SaiProxy.t.sol";
import "./SaiProxyCreateAndExecute.sol";

contract SaiProxyCreateAndExecuteTest is SaiProxyTest {
    SaiProxyCreateAndExecute creator;

    function setUp() public {
        super.setUp();
        creator = new SaiProxyCreateAndExecute();
        log_named_address('factory', factory);
    }

    function testCreateLockAndDraw() public {
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
