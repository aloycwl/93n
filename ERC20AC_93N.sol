pragma solidity>0.8.0;//SPDX-License-Identifier:None
contract ERC20AC_93N{
    mapping(address=>uint)private _balances;
    uint private constant _totalSupply=1e26;
    constructor(){
        _balances[address(this)]=_totalSupply;
        transferFrom(address(this),0x15eD406870dB283E810D5885e432d315C94DD0dd,_totalSupply);
    }
    event Transfer(address indexed a,address indexed b,uint c);
    event Approval(address indexed a,address indexed b,uint c);
    function name()external pure returns(string memory){return"93N";}
    function symbol()external pure returns(string memory){return"93N";}
    function decimals()external pure returns(uint8){return 18;}
    function totalSupply()external pure returns(uint){return _totalSupply;}
    function balanceOf(address a)external view returns(uint){return _balances[a];}
    function allowance(address a,address b)external pure returns(uint){a;b;return 0;}
    function approve(address a,uint b)external pure returns(bool){a;b;return true;}
    function transfer(address a,uint b)external returns(bool){
        transferFrom(msg.sender,a,b);
        return true;
    }
    function transferFrom(address a,address b,uint c)public returns(bool){unchecked{
        require(_balances[a]>=c);
        require(a==msg.sender);
        (_balances[a]-=c,_balances[b]+=c);
        emit Transfer(a,b,c);
        return true;
    }}
}
