pragma solidity ^0.4.16;

import "ds-thing/thing.sol";

contract TubInterface {
    function open() returns (bytes32);
    function join(uint);
    function exit(uint);
    function lock(bytes32, uint);
    function free(bytes32, uint);
    function draw(bytes32, uint);
    function wipe(bytes32, uint);
    function give(bytes32, address);
    function shut(bytes32);
    function cups(bytes32) returns (address, uint, uint);
    function gem() returns (TokenInterface);
    function skr() returns (TokenInterface);
    function sai() returns (TokenInterface);
    function vox() returns (VoxInterface);
    function mat() returns (uint);
    function chi() returns (uint);
    function tab(bytes32) returns (uint);
    function per() returns (uint);
    function pip() returns (uint);
    function tag() returns (uint);
}

contract TokenInterface {
    function balanceOf(address) returns (uint);
    function approve(address, uint);
    function trust(address, bool);
    function transfer(address, uint) returns (bool);
    function transferFrom(address, address, uint) returns (bool);
    function withdraw(uint);
}

contract VoxInterface {
    function par() returns (uint);
}

contract SaiProxy is DSThing {
    function processInk(TubInterface tub, bytes32 cup, uint wad, uint mat) internal {
        // Calculate necessary SKR for specific 'wad' amount of SAI and leave CDP with 'mat' percentage collateralized
        uint ink = wdiv(rmul(wmul(tub.vox().par(), rmul(wad, tub.chi())), mat), tub.tag());
        var (,cink,) = tub.cups(cup);
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
            tub.skr().approve(tub, sub(ink, cink));
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
    function draw(TubInterface tub, bytes32 cup, uint wad, uint mat) auth {
        // Require desired 'mat' is equal or higher than minimum defined in TUB
        require(mat >= tub.mat());
        // Bring cup values
        var (,,cart) = tub.cups(cup);
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
    function draw(TubInterface tub, uint wad, uint mat) auth {
        var cup = tub.open();
        draw(tub, cup, wad, mat);
    }

    /**
    * Wipes 'wad' amount of SAI leaving enough locked SKR to keep the CDP with 'mat' percentage of collateralization
    *
    * @param    tub    TUB Address
    * @param    cup    CUP ID (CDP)
    * @param    wad    Amount of SAI to wipe
    * @param    mat    collateralization of CDP after wiping
    */
    function wipe(TubInterface tub, bytes32 cup, uint wad, uint mat) auth {
        // Require desired 'mat' is equal or higher than minimum defined in TUB
        require(mat >= tub.mat());
        // Bring cup values
        var (,,cart) = tub.cups(cup);
        assert(cart >= rdiv(wad, tub.chi()));
        tub.sai().approve(tub, wad);
        tub.wipe(cup, wad);
        processInk(tub, cup, sub(cart, rdiv(wad, tub.chi())), mat);
    }

    /**
    * Transfers CDP to 'lad' new owner
    *
    * @param    tub    TUB Address
    * @param    cup    CUP ID (CDP)
    * @param    lad    Address of new owner
    */
    function give(TubInterface tub, bytes32 cup, address lad) auth {
        tub.give(cup, lad);
    }

    /**
    * Closes CDP
    *
    * @param    tub    TUB Address
    * @param    cup    CUP ID (CDP)
    */
    function shut(TubInterface tub, bytes32 cup) auth {
        tub.shut(cup);
    }
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

contract SaiJoin {
    function join(address tub, uint wad) {
        TubInterface(tub).join(wad);
    }
}
contract SaiExit {
    function exit(address tub, uint wad) {
        TubInterface(tub).exit(wad);
    }
}

contract SaiOpen {
    function open(address tub) returns (bytes32) {
        return TubInterface(tub).open();
    }
}
contract SaiGive {
    function give(address tub, bytes32 cup, address lad) {
        TubInterface(tub).give(cup, lad);
    }
}

contract SaiLock {
    function lock(address tub, bytes32 cup, uint wad) {
        TubInterface(tub).lock(cup, wad);
    }
}
contract SaiFree {
    function free(address tub, bytes32 cup, uint wad) {
        TubInterface(tub).free(cup, wad);
    }
}

contract SaiDraw {
    function draw(address tub, bytes32 cup, uint wad) {
        TubInterface(tub).draw(cup, wad);
    }
}
contract SaiWipe {
    function wipe(address tub, bytes32 cup, uint wad) {
        TubInterface(tub).wipe(cup, wad);
    }
}

contract SaiShut {
    function shut(address tub, bytes32 cup) {
        TubInterface(tub).shut(cup);
    }
}


/// Multi act proxy functions

// Trust the whole system
contract SaiTrustAll {
    function trustAll(address tub, address tap) {
        var gem = TubInterface(tub).gem();
        var skr = TubInterface(tub).skr();
        var sai = TubInterface(tub).sai();

        gem.trust(tub, true);
        skr.trust(tub, true);
        sai.trust(tub, true);

        skr.trust(tap, true);
        sai.trust(tap, true);
    }
}

// Go from W-ETH to Sai via join, lock, draw
contract SaiSaiSai {  // lol, naming
    function saisaisai(address tub_, uint jam, uint wad) returns (bytes32) {
        var tub = TubInterface(tub_);

        // trust could arguably be separated out
        var gem = TubInterface(tub).gem();
        var skr = TubInterface(tub).skr();
        gem.trust(tub, true);
        skr.trust(tub, true);

        tub.join(jam);
        var cup = tub.open();
        tub.lock(cup, jam);
        tub.draw(cup, wad);

        return cup;
    }
}

// transfer tokens from the proxy to arbitrary places
contract ProxyTransfer {
    function transfer(address token, address guy, uint wad) {
        TokenInterface(token).transfer(guy, wad);
    }
}

contract ProxyApprove {
    function approve(address token, address guy, uint wad) {
        TokenInterface(token).approve(guy, wad);
    }
}

contract ProxyTrust {
    function trust(address token, address guy, bool wat) {
        TokenInterface(token).trust(guy, wat);
    }
}

contract ProxyDeposit {
    function deposit(address token, uint wad) payable {
        assert(token.call.value(wad)(bytes4(sha3("deposit()"))));
    }
}

contract ProxyWithdraw {
    function withdraw(address token, uint wad) {
        TokenInterface(token).withdraw(wad);
    }
}
