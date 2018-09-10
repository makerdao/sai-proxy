pragma solidity ^0.4.23;

import "./SaiProxy.sol";

contract ProxyRegistryInterface {
    function build(address) public returns (address);
}

contract SaiProxyCreateAndExecute is SaiProxy {
    function createOpenLockAndDraw(address registry_, address tub_, uint wad) public payable returns (address proxy, bytes32 cup) {
        proxy = ProxyRegistryInterface(registry_).build(msg.sender);
        cup = open(tub_);
        lockAndDraw(tub_, cup, wad);
        TubInterface(tub_).give(cup, proxy);
    }
}
