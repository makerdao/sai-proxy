pragma solidity ^0.4.16;

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

// Writing more proxy functions: for now these need to not take any
// constructor args, as there isn't a way to pass them in at creation.
//
// The examples given here are small and self-contained. ds-proxy has
// caching, so the first time one of these is used will be expensive,
// but subsequent calls will have little overhead.
//
// You could make multi function versions; you could also have setters
// for state variables - but then you may need to think about e.g.
// restricting access via auth.
//
// To use these via a frontend or in testing, `dapp build` the contracts
// and then copy the contents of e.g. `out/SaiDraw.bin` to where it will
// be used.


/// Single act proxy functions for the base acts (assumes proxy as funds holder - no `transferFrom` from account)
contract ProxySaiBasicActions {
    function join(address tub, uint wad) public {
        if (TubInterface(tub).gem().allowance(this, tub) != uint(-1)) {
            TubInterface(tub).gem().approve(tub, uint(-1));
        }
        TubInterface(tub).join(wad);
    }

    function exit(address tub, uint wad) public {
        if (TubInterface(tub).skr().allowance(this, tub) != uint(-1)) {
            TubInterface(tub).skr().approve(tub, uint(-1));
        }
        TubInterface(tub).exit(wad);
    }

    function open(address tub) public returns (bytes32) {
        return TubInterface(tub).open();
    }

    function give(address tub, bytes32 cup, address lad) public {
        TubInterface(tub).give(cup, lad);
    }

    function lock(address tub, bytes32 cup, uint wad) public {
        if (TubInterface(tub).skr().allowance(this, tub) != uint(-1)) {
            TubInterface(tub).skr().approve(tub, uint(-1));
        }
        TubInterface(tub).lock(cup, wad);
    }

    function free(address tub, bytes32 cup, uint wad) public {
        TubInterface(tub).free(cup, wad);
    }

    function draw(address tub, bytes32 cup, uint wad) public {
        TubInterface(tub).draw(cup, wad);
    }

    function wipe(address tub, bytes32 cup, uint wad) public {
        if (TubInterface(tub).sai().allowance(this, tub) != uint(-1)) {
            TubInterface(tub).sai().approve(tub, uint(-1));
        }
        if (TubInterface(tub).gov().allowance(this, tub) != uint(-1)) {
            TubInterface(tub).gov().approve(tub, uint(-1));
        }
        TubInterface(tub).wipe(cup, wad);
    }

    function shut(address tub, bytes32 cup) public {
        if (TubInterface(tub).sai().allowance(this, tub) != uint(-1)) {
            TubInterface(tub).sai().approve(tub, uint(-1));
        }
        if (TubInterface(tub).gov().allowance(this, tub) != uint(-1)) {
            TubInterface(tub).gov().approve(tub, uint(-1));
        }
        TubInterface(tub).shut(cup);
    }

    function bite(address tub, bytes32 cup) public {
        TubInterface(tub).bite(cup);
    }

    function drip(address tub) public {
        TubInterface(tub).drip();
    }

    function bust(address tap, uint wad) public {
        if (TapInterface(tap).sai().allowance(this, tap) != uint(-1)) {
            TapInterface(tap).sai().approve(tap, uint(-1));
        }
        TapInterface(tap).bust(wad);
    }

    function boom(address tap, uint wad) public {
        if (TapInterface(tap).skr().allowance(this, tap) != uint(-1)) {
            TapInterface(tap).skr().approve(tap, uint(-1));
        }
        TapInterface(tap).boom(wad);
    }

    function cash(address tap, uint wad) public {
        if (TapInterface(tap).sai().allowance(this, tap) != uint(-1)) {
            TapInterface(tap).sai().approve(tap, uint(-1));
        }
        TapInterface(tap).cash(wad);
    }

    function mock(address tap, uint wad) public {
        if (TapInterface(tap).tub().gem().allowance(this, tap) != uint(-1)) {
            TapInterface(tap).tub().gem().approve(tap, uint(-1));
        }
        TapInterface(tap).mock(wad);
    }

    function heal(address tap) public {
        TapInterface(tap).heal();
    }
}


/// Multi act proxy functions (assumes account as holder)
contract ProxySaiCustomActions is DSMath {
    function lock(address tub_, bytes32 cup) public payable {
        TubInterface tub = TubInterface(tub_);

        tub.gem().deposit.value(msg.value)();

        uint jam = rmul(msg.value, tub.per());
        if (tub.gem().allowance(this, tub) != uint(-1)) {
            tub.gem().approve(tub, uint(-1));
        }
        tub.join(jam);

        if (tub.skr().allowance(this, tub) != uint(-1)) {
            tub.skr().approve(tub, uint(-1));
        }
        tub.lock(cup, jam);
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
        tub.free(cup, rdiv(jam, tub.per()));
        tub.exit(jam);
        tub.gem().withdraw(jam);
        address(msg.sender).transfer(jam);
    }

    function lockAndDraw(address tub_, bytes32 cup, uint wad) public payable {
        lock(tub_, cup);
        draw(tub_, cup, wad);
    }

    function lockAndDraw(address tub_, uint wad) public payable returns (bytes32 cup) {
        cup = TubInterface(tub_).open();
        lockAndDraw(tub_, cup, wad);
        return cup;
    }

    function wipeAndFree(address tub_, bytes32 cup, uint jam, uint wad) public payable {
        wipe(tub_, cup, wad);
        free(tub_, cup, jam);
    }
}

contract ProxyTokenActions {
    function transfer(address token, address guy, uint wad) public {
        require(TokenInterface(token).transfer(guy, wad));
    }

    function approve(address token, address guy, bool wat) public {
        TokenInterface(token).approve(guy, wat ? uint(-1) : uint(0));
    }

    function approve(address token, address guy, uint wad) public {
        TokenInterface(token).approve(guy, wad);
    }

    function deposit(address token) public payable {
        TokenInterface(token).deposit.value(msg.value)();
    }

    function withdraw(address token, uint wad) public {
        TokenInterface(token).withdraw(wad);
    }
}
