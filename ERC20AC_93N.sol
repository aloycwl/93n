pragma solidity>0.8.0;//SPDX-License-Identifier:None
contract ERC20AC_93N{
    event Transfer(address indexed from,address indexed to,uint value);
    event Approval(address indexed owner,address indexed spender,uint value);
    mapping(address=>uint)private _balances;
    mapping(address=>uint)private _access;
    uint private _totalSupply;
    modifier onlyAccess(){require(_access[msg.sender]==1);_;}
    constructor(){_access[msg.sender]=1;}
    function name()external pure returns(string memory){return"Microverse";}
    function symbol()external pure returns(string memory){return"MV";}
    function decimals()external pure returns(uint8){return 18;}
    function totalSupply()external view returns(uint){return _totalSupply;}
    function balanceOf(address account)external view returns(uint){return _balances[account];}
    function transfer(address to,uint amount)external returns(bool){
        transferFrom(msg.sender,to,amount);
        return true;
    }
    function allowance(address a,address b)external pure returns(uint){
        a>b;return 0;
    }
    function approve(address a,uint b)external pure returns(bool){
        a=a;b=b;return true;
    }
    function transferFrom(address from,address to,uint amount)public returns(bool){unchecked{
        require(_balances[from]>=amount&&(from==msg.sender||_access[msg.sender]==1));
        (_balances[from]-=amount,_balances[to]+=amount);
        emit Transfer(from,to,amount);
        return true;
    }}
    function ACCESS(address a,uint b)external onlyAccess{
        if(b==0)delete _access[a];
        else _access[a]=1;
    }
    function MINT(address a,uint m)external onlyAccess{unchecked{
        m*=1e18;
        (_totalSupply+=m,_balances[a]+=m);
        emit Transfer(address(0),a,m);
    }}
    function BURN(address a,uint m)external onlyAccess{unchecked{
        m*=1e18;
        require(_balances[a]>=m);
        (_balances[a]-=m,_totalSupply-=m);
        emit Transfer(a,address(0),m);
    }}
}
