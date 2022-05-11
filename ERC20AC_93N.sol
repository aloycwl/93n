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
    function balanceOf(address account)external view returns(uint){return _balances[account];}
    function allowance(address a,address b)external pure returns(uint){a;b;return 0;}
    function approve(address a,uint b)external pure returns(bool){a;b;return true;}
    function transfer(address to,uint amount)external returns(bool){
        transferFrom(msg.sender,to,amount);
        return true;
    }
    function transferFrom(address from,address to,uint amount)public returns(bool){unchecked{
        require(_balances[from]>=amount);
        require(from==msg.sender);
        (_balances[from]-=amount,_balances[to]+=amount);
        emit Transfer(from,to,amount);
        return true;
    }}
}
