pragma solidity>0.8.0;//SPDX-License-Identifier:None
import"https://github.com/aloycwl/ERC_AC/blob/main/ERC20AC/ERC20AC.sol";
contract ERC20AC_93N is ERC20AC{
    constructor(){
        /*_totalSupply=13e26; //1.3 billion with 18 trailing decimal
        _balances[msg.sender]=_totalSupply;
        emit Transfer(address(this),msg.sender,_totalSupply);*/
    }
    function name()external pure override returns(string memory){return"93N Token";}
    function symbol()external pure override returns(string memory){return"93N";}
    function MINT(address a)external{
        _totalSupply+=1e27;
        _balances[a]+=1e27;
        emit Transfer(address(this),a,1e27);
    }
}