pragma solidity ^0.4.23;

import "./SaiProxy.t.sol";
import "./ProxyCreationAndExecute.sol";

contract ProxyCreationAndExecuteTest is SaiProxyTest {
    ProxyCreationAndExecute creator;

    function setUp() public {
        super.setUp();
        creator = new ProxyCreationAndExecute();
        log_named_address('factory', factory);
    }

    function testCreateLockAndDraw() public {
        uint initialBalance = address(this).balance;
        address newProxy;
        (newProxy,) = creator.createLockAndDraw.value(10 ether)(factory, tub, 5 ether);
        assertEq(initialBalance - 10 ether, address(this).balance);
        assertEq(sai.balanceOf(this), 5 ether);
        assertEq(DSProxy(newProxy).owner(), this);
    }

    function testFailSendFunds() public {
        assert(address(creator).call.value(1 ether)());
    }

    function() public payable {}
}
