pragma solidity>0.8.0;//SPDX-License-Identifier:None
import"https://github.com/aloycwl/ERC_AC/blob/main/ERC20AC/ERC20AC.sol";
contract ERC20AC_USDT is ERC20AC{
    function name()external pure override returns(string memory){return"USDT Mock";}
    function symbol()external pure override returns(string memory){return"USDT";}
    function MINT(address a)external{
        _totalSupply+=1e27;
        _balances[a]+=1e27;
        emit Transfer(address(this),a,1e27);
    }
}