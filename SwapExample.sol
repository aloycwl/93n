pragma solidity>0.8.0;//SPDX-License-Identifier:None
contract SwapExample{
    function getAmountsOut(uint a,address[]memory)external pure returns(uint[]memory c){
        c=new uint[](2);
        c[0]=a/10;
    }
}