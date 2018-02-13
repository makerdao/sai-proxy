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
    function per() public returns (uint);
    function pip() public returns (PipInterface);
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
    function withdraw(uint) public;
}

contract VoxInterface {
    function par() public returns (uint);
}

contract PipInterface {
    function read() public returns (bytes32);
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

/// Single act proxy functions for the base acts

// n.b. if you change these, you need to update the corresponding `code`
// in the tests :s

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


/// Multi act proxy functions

// Approve the whole system
contract ProxySaiCustomActions is DSMath {
    // Go from W-ETH to Sai via join, lock, draw
    function drawAmount(address tub_, uint jam, uint wad) public returns (bytes32 cup) {
        var tub = TubInterface(tub_);
        cup = tub.open();
        drawAmount(tub_, cup, jam, wad);

        return cup;
    }

    function drawAmount(address tub_, bytes32 cup, uint jam, uint wad) public {
        var tub = TubInterface(tub_);

        if (tub.gem().allowance(this, tub) != uint(-1)) {
            tub.gem().approve(tub, uint(-1));
        }
        if (tub.skr().allowance(this, tub) != uint(-1)) {
            tub.skr().approve(tub, uint(-1));
        }

        tub.join(jam);
        tub.lock(cup, jam);
        tub.draw(cup, wad);
    }

    function processInk(TubInterface tub, bytes32 cup, uint wad, uint mat) internal {
        // Calculate necessary SKR for specific 'wad' amount of SAI and leave CDP with 'mat' percentage collateralized
        uint ink = wdiv(rmul(wmul(tub.vox().par(), rmul(wad, tub.chi())), mat), tub.tag());
        var (,cink,,) = tub.cups(cup);
        // Check if SKR needs to be locked or freed
        if (ink > cink) {
            // Check if there is already skr in balance to be locked
            if (sub(ink, cink) > tub.skr().balanceOf(this)) {
                // Change GEM to SKR via 'join'
                var jam = rmul(sub(sub(ink, cink), tub.skr().balanceOf(this)), tub.per());
                tub.gem().approve(tub, jam);
                tub.join(jam);
            }
            // Lock SKR
            tub.skr().approve(tub, uint(-1));
            tub.lock(cup, sub(ink, cink));
        } else if (cink > ink) {
            tub.free(cup, sub(cink, ink));
        }
    }

    /**
    * Draws 'wad' amount of SAI locking enough SKR to keep the CDP with 'mat' percentage of collateralization (in an existing CDP)
    *
    * @param    tub    TUB Address
    * @param    cup    CUP ID (CDP)
    * @param    wad    Amount of SAI to draw
    * @param    mat    collateralization of CDP after drawing
    */
    function drawAmountAtMargin(TubInterface tub, bytes32 cup, uint wad, uint mat) public {
        // Require desired 'mat' is equal or higher than minimum defined in TUB
        require(mat >= tub.mat());
        // Bring cup values
        var (,,cart,) = tub.cups(cup);
        processInk(tub, cup, add(rdiv(wad, tub.chi()), cart), mat);
        tub.draw(cup, wad);
    }

    /**
    * Draws 'wad' amount of SAI locking enough SKR to keep the CDP with 'mat' percentage of collateralization (creating a new CDP)
    *
    * @param    tub    TUB Address
    * @param    wad    Amount of SAI to draw
    * @param    mat    collateralization of CDP after drawing
    */
    function drawAmountAtMargin(TubInterface tub, uint wad, uint mat) public {
        var cup = tub.open();
        drawAmountAtMargin(tub, cup, wad, mat);
    }

    /**
    * Wipes 'wad' amount of SAI leaving enough locked SKR to keep the CDP with 'mat' percentage of collateralization
    *
    * @param    tub    TUB Address
    * @param    cup    CUP ID (CDP)
    * @param    wad    Amount of SAI to wipe
    * @param    mat    collateralization of CDP after wiping
    */
    function wipeAmountAtMargin(TubInterface tub, bytes32 cup, uint wad, uint mat) public {
        // Require desired 'mat' is equal or higher than minimum defined in TUB
        require(mat >= tub.mat());
        // Bring cup values
        var (,,cart) = tub.cups(cup);
        assert(cart >= rdiv(wad, tub.chi()));
        tub.sai().approve(tub, wad);
        tub.wipe(cup, wad);
        processInk(tub, cup, sub(cart, rdiv(wad, tub.chi())), mat);
    }

    function approveAll(address tub, address tap, bool wat) public {
        var gem = TubInterface(tub).gem();
        var gov = TubInterface(tub).gov();
        var skr = TubInterface(tub).skr();
        var sai = TubInterface(tub).sai();

        gem.approve(tub, wat ? uint(-1) : uint(0));
        gov.approve(tub, wat ? uint(-1) : uint(0));
        skr.approve(tub, wat ? uint(-1) : uint(0));
        sai.approve(tub, wat ? uint(-1) : uint(0));

        gem.approve(tap, wat ? uint(-1) : uint(0));
        skr.approve(tap, wat ? uint(-1) : uint(0));
        sai.approve(tap, wat ? uint(-1) : uint(0));
    }
}

// transfer tokens from the proxy to arbitrary places
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

    function deposit(address token, uint wad) public payable {
        assert(token.call.value(wad)(bytes4(keccak256("deposit()"))));
    }

    function withdraw(address token, uint wad) public {
        TokenInterface(token).withdraw(wad);
    }
}
