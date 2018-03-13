pragma solidity ^0.4.20;

import "ds-math/math.sol";

contract TubInterface {
    function open() public returns (bytes32);
    function join(uint) public;
    function exit(uint) public;
    function lock(bytes32, uint) public;
    function free(bytes32, uint) public;
    function draw(bytes32, uint) public;
    function wipe(bytes32, uint) public;
    function give(bytes32, address) public;
    function shut(bytes32) public;
    function bite(bytes32) public;
    function cups(bytes32) public returns (address, uint, uint, uint);
    function gem() public returns (TokenInterface);
    function gov() public returns (TokenInterface);
    function skr() public returns (TokenInterface);
    function sai() public returns (TokenInterface);
    function vox() public returns (VoxInterface);
    function ask(uint) public returns (uint);
    function mat() public returns (uint);
    function chi() public returns (uint);
    function ink(bytes32) public returns (uint);
    function tab(bytes32) public returns (uint);
    function rap(bytes32) public returns (uint);
    function per() public returns (uint);
    function pip() public returns (PipInterface);
    function pep() public returns (PepInterface);
    function tag() public returns (uint);
    function drip() public;
}

contract TapInterface {
    function skr() public returns (TokenInterface);
    function sai() public returns (TokenInterface);
    function tub() public returns (TubInterface);
    function bust(uint) public;
    function boom(uint) public;
    function cash(uint) public;
    function mock(uint) public;
    function heal() public;
}

contract TokenInterface {
    function allowance(address, address) public returns (uint);
    function balanceOf(address) public returns (uint);
    function approve(address, uint) public;
    function transfer(address, uint) public returns (bool);
    function transferFrom(address, address, uint) public returns (bool);
    function deposit() public payable;
    function withdraw(uint) public;
}

contract VoxInterface {
    function par() public returns (uint);
}

contract PipInterface {
    function read() public returns (bytes32);
}

contract PepInterface {
    function peek() public returns (bytes32, bool);
}

contract SaiProxy is DSMath {
    function open(address tub_) public returns (bytes32) {
        return TubInterface(tub_).open();
    }

    function give(address tub_, bytes32 cup, address lad) public {
        TubInterface(tub_).give(cup, lad);
    }

    function lock(address tub_, bytes32 cup) public payable {
        TubInterface tub = TubInterface(tub_);

        tub.gem().deposit.value(msg.value)();

        uint ink = rdiv(msg.value, tub.per());
        if (tub.gem().allowance(this, tub) != uint(-1)) {
            tub.gem().approve(tub, uint(-1));
        }
        tub.join(ink);

        if (tub.skr().allowance(this, tub) != uint(-1)) {
            tub.skr().approve(tub, uint(-1));
        }
        tub.lock(cup, ink);
    }

    function draw(address tub_, bytes32 cup, uint wad) public {
        TubInterface tub = TubInterface(tub_);
        tub.draw(cup, wad);
        tub.sai().transfer(msg.sender, wad);
    }

    function wipe(address tub_, bytes32 cup, uint wad) public {
        TubInterface tub = TubInterface(tub_);

        tub.sai().transferFrom(msg.sender, this, wad);
        bytes32 val;
        bool ok;
        (val, ok) = tub.pep().peek();
        if (ok && val != 0) tub.gov().transferFrom(msg.sender, this, wdiv(rmul(wad, rdiv(tub.rap(cup), tub.tab(cup))), uint(val)));

        if (tub.sai().allowance(this, tub) != uint(-1)) {
            tub.sai().approve(tub, uint(-1));
        }
        if (tub.gov().allowance(this, tub) != uint(-1)) {
            tub.gov().approve(tub, uint(-1));
        }
        tub.wipe(cup, wad);
    }

    function free(address tub_, bytes32 cup, uint jam) public {
        TubInterface tub = TubInterface(tub_);
        uint ink = rdiv(jam, tub.per());
        tub.free(cup, ink);
        tub.exit(ink);
        tub.gem().withdraw(jam);
        address(msg.sender).transfer(jam);
    }

    function lockAndDraw(address tub_, bytes32 cup, uint wad) public payable {
        lock(tub_, cup);
        draw(tub_, cup, wad);
    }

    function lockAndDraw(address tub_, uint wad) public payable returns (bytes32 cup) {
        cup = open(tub_);
        lockAndDraw(tub_, cup, wad);
        return cup;
    }

    function wipeAndFree(address tub_, bytes32 cup, uint jam, uint wad) public payable {
        wipe(tub_, cup, wad);
        free(tub_, cup, jam);
    }

    function shut(address tub_, bytes32 cup) public {
        TubInterface tub = TubInterface(tub_);
        wipeAndFree(tub_, cup, rmul(tub.ink(cup), tub.per()), tub.tab(cup));
        tub.shut(cup);
    }
}
