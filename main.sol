/*
Staking contract 3 6 9 months
3 Months 2% 
6 Months 3%
9 Months 4%

Matching on Staking
20% 15% 15%
3 level*/
pragma solidity>0.8.0;//SPDX-License-Identifier:None
interface IERC20{function transferFrom(address a,address b,uint256 c)external;}
interface IERC20AC{function transferFrom(address a,address b,uint256 c)external;}
contract simpleMLM{
    address private _owner;
    address[]private enumUser;
    address constant private _USDT=0x540d7E428D5207B30EE03F2551Cbb5751D3c7569;
    address constant private _TOKEN=0x540d7E428D5207B30EE03F2551Cbb5751D3c7569;
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
    function Deposit(address referral,uint amount)external payable{
        require(referral!=msg.sender);
        /*** TO BE REPLACED WITH USDT ADDRESS && SET APPROVAL FROM WEB3 FIRST ***/
        IERC20(_USDT).transferFrom(msg.sender,address(this),amount*1e18);
        user[msg.sender].upline=referral==0x0000000000000000000000000000000000000000?_owner:referral;
        user[msg.sender].dateJoined=user[msg.sender].lastClaimed=block.timestamp;
        enumUser.push(msg.sender);
    }
    function Staking()external{
        // Detect every 730 hours since the date start (divided to exactly 31,536,000 seconds in a year)
        // Update lastClaimed
        for(uint i=0;i<enumUser.length;i++){
            address d1=user[enumUser[i]].upline;
            address d2=user[d1].upline;
            address d3=user[d2].upline;
            uint amt=user[enumUser[i]].investAmt;
            (user[d1].USDT+=amt*1/20,user[d2].USDT+=amt*3/100,user[d3].USDT+=amt*1/50, //USDT=5,3,2 
                user[d1].token+=amt*1/50,user[d2].token+=amt*3/20,user[d3].token+=amt/10); //Token=20,15,10
        }
    }
    function Withdraw(uint amount)external{
        /*** SET WITHDRAWAL CONDITION ***/
        IERC20(_USDT).transferFrom(address(this),msg.sender,amount*1e18);
        IERC20AC(_TOKEN).transferFrom(address(this),msg.sender,amount*1e18);
    }
}