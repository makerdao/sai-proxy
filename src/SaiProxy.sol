pragma solidity ^0.4.16;

import "ds-thing/thing.sol";

contract TubInterface {
    function open() returns (bytes32);
    function join(uint128);
    function lock(bytes32, uint128);
    function draw(bytes32, uint128);
    function cups(bytes32) returns (address, uint128, uint128);
    function gem() returns (address);
    function skr() returns (address);
    function sai() returns (address);
    function jar() returns (address);
    function tip() returns (address);
    function mat() returns (uint128);
    function tab(bytes32) returns (uint128);
    function chi() returns (uint128);
}

contract TokenInterface {
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
    TubInterface public tub;
    TokenInterface gem;
    TokenInterface skr;
    TokenInterface sai;
    JarInterface   jar;
    TipInterface   tip;

    function SaiProxy(address _tub) {
        tub = TubInterface(_tub);
        gem = TokenInterface(tub.gem());
        skr = TokenInterface(tub.skr());
        sai = TokenInterface(tub.sai());
        jar = JarInterface(tub.jar());
        tip = TipInterface(tub.tip());
    }

    function pull(address tok, uint128 wad) auth {
        assert(TokenInterface(tok).transfer(owner, wad));
    }

    // function push(address tok, uint128 wad) auth {
    //     assert(TokenInterface(tok).transferFrom(owner, this, wad));
    // }

    /**
    * Draws 'wad' amount of SAI locking enough SKR to keep the CDP with 'mat' percentage of collateralization
    *
    * @param    cup    CDP ID
    * @param    wad    Amount of SAI to draw
    * @param    mat    collateralization of CDP after drawing
    */
    function draw(bytes32 cup, uint128 wad, uint128 mat) auth {
        require(mat >= tub.mat());
        var (,cart,cink) = tub.cups(cup);
        uint128 ink = hsub(wdiv(rmul(wmul(tip.par(), rmul(hadd(wad, cart), tub.chi())), mat), jar.tag()), cink);
        uint128 jam = rmul(ink, jar.per());
        gem.approve(jar, jam);
        tub.join(jam);
        skr.approve(jar, ink);
        tub.lock(cup, ink);
        tub.draw(cup, wad);
    }

    function draw(uint128 wad, uint128 ratio) auth {
        var cup = tub.open();
        draw(cup, wad, ratio);
    }

    /**
    * Wipes 'wad' amount of SAI leaving enough locked SKR to keep the CDP with 'mat' percentage of collateralization
    *
    * @param    cup    CDP ID
    * @param    wad    Amount of SAI to wipe
    * @param    mat    collateralization of CDP after wiping
    */
    // function wipe(bytes32 cup, uint128 wad, uint128 mat) auth {
    //     require(mat >= tub.mat());
    //     var (,cart,cink) = tub.cups(cup);
    // }
}
