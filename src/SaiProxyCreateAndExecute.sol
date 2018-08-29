pragma solidity ^0.4.23;

import "./SaiProxy.sol";

contract ProxyFactoryInterface {
    function build(address) public returns (address);
}

contract SaiProxyCreateAndExecute is SaiProxy {
    function createLockAndDraw(address factory_, address tub_, uint wad) public payable returns (address proxy, bytes32 cup) {
        proxy = ProxyFactoryInterface(factory_).build(msg.sender);
        cup = open(tub_);
        lockAndDraw(tub_, cup, wad);
        TubInterface(tub_).give(cup, proxy);
    }
}
