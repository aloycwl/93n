/*
Token 
Direct Referral A
5% 3% 2% 
3 level in USDT

Direct Referral B
10% 15% 20% 
3 level in tokens

Staking contract 3 6 9 months
3 Months 2% 
6 Months 3%
9 Months 4%

Matching on Staking
20% 15% 15%
3 level*/
pragma solidity>0.8.0;//SPDX-License-Identifier:None
interface IERC20{
    function transferFrom(address from,address to,uint256 amount)external returns(bool);
}
interface IERC20AC{
    function transferFrom(address from,address to,uint256 amount)external returns(bool);
}
contract simpleMLM{
    uint[3]private USDT_P=[5,3,2]; //Direct referral in USDT
    uint[3]private token_P=[20,15,10]; //Direct referral in token
    address private _owner;
    address[]private enumUser;
    struct User{
        address upline;
        uint investAmt;
        uint USDT;
        uint token;
        uint dateJoined;
        uint lastClaimed;
        uint package;
    }
    mapping(address=>User)public user;
    constructor(){
        _owner=msg.sender;
        user[msg.sender].upline=msg.sender;
    }
    function Join(address referral,uint amount)external payable{
        require(referral!=msg.sender);
        /*** TO BE REPLACED WITH USDT ADDRESS && SET APPROVAL FROM WEB3 FIRST ***/
        IERC20 usdt=IERC20(address(0xd2a5bC10698FD955D1Fe6cb468a17809A08fd005));
        usdt.transferFrom(msg.sender,address(this),amount*1e18);
        user[msg.sender].upline=referral==0x0000000000000000000000000000000000000000?_owner:referral;
        user[msg.sender].dateJoined=user[msg.sender].lastClaimed=block.timestamp;
        enumUser.push(msg.sender);
    }
    function Staking()external{
        for(uint i=0;i<enumUser.length;i++){
            address d1=user[enumUser[i]].upline;
            address d2=user[d1].upline;
            address d3=user[d2].upline;
            uint amt=user[enumUser[i]].investAmt;
            (user[d1].USDT+=amt*USDT_P[0]/100,user[d2].USDT+=amt*USDT_P[1]/100,
                user[d3].USDT+=amt*USDT_P[2]/100,user[d1].token+=amt*token_P[0]/100,
                user[d2].token+=amt*token_P[1]/100,user[d3].token+=amt*token_P[2]/100);
        }
    }

    function Withdraw()external payable{
        //IERC20 usdt=IERC20(address(0x7EF2e0048f5bAeDe046f6BF797943daF4ED8CB47));
        //usdt.transferFrom(0x5B38Da6a701c568545dCfcB03FcB875f56beddC4,1000);
    }
}