pragma solidity ^0.4.16;

import "ds-thing/thing.sol";

contract TubInterface {
    function open() returns (bytes32);
    function join(uint);
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
    function transfer(address, uint) returns (bool);
    function transferFrom(address, address, uint) returns (bool);
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
