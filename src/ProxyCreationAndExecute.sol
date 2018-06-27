pragma solidity ^0.4.23;

import "./SaiProxy.sol";
import "ds-proxy/proxy.sol";

contract ProxyCreationAndExecute is SaiProxy {
    function createLockAndDraw(address factory_, address tub_, uint wad) public payable returns (address proxy, bytes32 cup) {
        proxy = DSProxyFactory(factory_).build(msg.sender);
        cup = open(tub_);
        lockAndDraw(tub_, cup, wad);
        TubInterface(tub_).give(cup, proxy);
    }
}
