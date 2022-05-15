pragma solidity>0.8.0;//SPDX-License-Identifier:None
contract ERC20AC{
    event Transfer(address indexed from,address indexed to,uint256 value);
    event Approval(address indexed owner,address indexed spender,uint256 value);
    mapping(address=>uint)private _balances;
    mapping(address=>mapping(address=>uint))private _allowances;
    constructor(address a){
        _balances[a]=totalSupply();
        emit Transfer(address(this),a,totalSupply());
    }
    function name()external pure returns(string memory){return"93N Token";}
    function symbol()external pure returns(string memory){return"93N";}
    function decimals()external pure returns(uint){return 18;}
    function totalSupply()public pure returns(uint){return 13e26;} //1.3 billion with 18 trailing decimal
    function balanceOf(address a)external view returns(uint){return _balances[a];}
    function allowance(address a,address b)external view returns(uint){return _allowances[a][b];}
    function approve(address a,uint b)external returns(bool){
        _allowances[msg.sender][a]=b;
        emit Approval(msg.sender,a,b);
        return true;
    }
    function transfer(address a,uint b)external returns(bool){
        transferFrom(msg.sender,a,b);
        return true;
    }
    function transferFrom(address a,address b,uint c)public returns(bool){unchecked{
        require(_balances[a]>=c);
        require(a==msg.sender||_allowances[a][b]>=c);
        (_balances[a]-=c,_balances[b]+=c);
        emit Transfer(a,b,c);
        return true;
    }}
}