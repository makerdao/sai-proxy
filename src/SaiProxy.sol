pragma solidity ^0.4.16;

import "ds-thing/thing.sol";

contract TubInterface {
    function open() returns (bytes32);
    function join(uint128);
    function lock(bytes32, uint128);
    function free(bytes32, uint128);
    function draw(bytes32, uint128);
    function wipe(bytes32, uint128);
    function give(bytes32, address);
    function shut(bytes32);
    function cups(bytes32) returns (address, uint128, uint128);
    function gem() returns (TokenInterface);
    function skr() returns (TokenInterface);
    function sai() returns (TokenInterface);
    function jar() returns (JarInterface);
    function tip() returns (TipInterface);
    function pot() returns (address);
    function mat() returns (uint128);
    function chi() returns (uint128);
    function tab(bytes32) returns (uint128);
}

contract TokenInterface {
    function balanceOf(address) returns (uint);
    function approve(address, uint);
    function transfer(address, uint) returns (bool);
    function transferFrom(address, address, uint) returns (bool);
}

contract JarInterface {
    function per() returns (uint128);
    function tag() returns (uint128);
}

contract TipInterface {
    function par() returns (uint128);
}

contract SaiProxy is DSThing {
    function processInk(TubInterface tub, bytes32 cup, uint128 wad, uint128 mat) internal {
        // Calculate necessary SKR for specific 'wad' amount of SAI and leave CDP with 'mat' percentage collateralized
        uint128 ink = wdiv(rmul(wmul(tub.tip().par(), rmul(wad, tub.chi())), mat), tub.jar().tag());
        var (,,cink) = tub.cups(cup);
        // Check if SKR needs to be locked or freed
        if (ink > cink) {
            // Check if there is already skr in balance to be locked
            if (hsub(ink, cink) > tub.skr().balanceOf(this)) {
                // Change GEM to SKR via 'join'
                var jam = rmul(hsub(hsub(ink, cink), uint128(tub.skr().balanceOf(this))), tub.jar().per());
                tub.gem().approve(tub.jar(), jam);
                tub.join(jam);
            }
            // Lock SKR
            tub.skr().approve(tub.jar(), hsub(ink, cink));
            tub.lock(cup, hsub(ink, cink));
        } else if (cink > ink) {
            tub.free(cup, hsub(cink, ink));
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
    function draw(TubInterface tub, bytes32 cup, uint128 wad, uint128 mat) auth {
        // Require desired 'mat' is equal or higher than minimum defined in TUB
        require(mat >= tub.mat());
        // Bring cup values
        var (,cart,) = tub.cups(cup);
        processInk(tub, cup, hadd(rdiv(wad, tub.chi()), cart), mat);
        tub.draw(cup, wad);
    }

    /**
    * Draws 'wad' amount of SAI locking enough SKR to keep the CDP with 'mat' percentage of collateralization (creating a new CDP)
    *
    * @param    tub    TUB Address
    * @param    wad    Amount of SAI to draw
    * @param    mat    collateralization of CDP after drawing
    */
    function draw(TubInterface tub, uint128 wad, uint128 mat) auth {
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
    function wipe(TubInterface tub, bytes32 cup, uint128 wad, uint128 mat) auth {
        // Require desired 'mat' is equal or higher than minimum defined in TUB
        require(mat >= tub.mat());
        // Bring cup values
        var (,cart,) = tub.cups(cup);
        assert(cart >= rdiv(wad, tub.chi()));
        tub.sai().approve(tub.pot(), wad);
        tub.wipe(cup, wad);
        processInk(tub, cup, hsub(cart, rdiv(wad, tub.chi())), mat);
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

    /**
    * Transfers 'wad' amount from 'tok' token to 'guy' address
    *
    * @param    tok    Token Address
    * @param    guy    Address which will receive the amount
    * @param    wad    Amount to be transferred
    */
    function pull(TokenInterface tok, address guy, uint128 wad) auth {
        tok.transfer(guy, wad);
    }

    /**
    * Transfers 'wad' amount from 'tok' token to msg.sender
    *
    * @param    tok    Token Address
    * @param    wad    Amount to be transferred
    */
    function pull(TokenInterface tok, uint128 wad) auth {
        tok.transfer(msg.sender, wad);
    }
}
