/*
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
        uint package; //3 months (2%), 6 months (3%), 9 months (4%)
    }
    mapping(address=>User)public user;
    constructor(){
        _owner=msg.sender;
        user[msg.sender].upline=msg.sender;
    }
    function Deposit(address referral,uint amount,uint package)external payable{
        require(referral!=msg.sender);
        /*** TO BE REPLACED WITH USDT ADDRESS && SET APPROVAL FROM WEB3 FIRST ***/
        IERC20(_USDT).transferFrom(msg.sender,address(this),amount*1e18);
        (user[msg.sender].upline,user[msg.sender].package)=
            (referral==0x0000000000000000000000000000000000000000?_owner:referral,package);
        user[msg.sender].dateJoined=user[msg.sender].lastClaimed=block.timestamp;
        enumUser.push(msg.sender);
    }
    function Staking()external{
        for(uint i=0;i<enumUser.length;i++)
            if(user[enumUser[i]].lastClaimed>=730 hours&& //31,536,000 seconds a year=exactly 730 hours
                user[enumUser[i]].dateJoined<=user[enumUser[i]].package*730 hours){ //Expire contract no money
                address d1=user[enumUser[i]].upline;
                address d2=user[d1].upline;
                address d3=user[d2].upline;
                uint percent=(user[enumUser[i]].package==3?2:user[enumUser[i]].package==6?3:4)/100;
                uint amt=user[enumUser[i]].investAmt*percent;
                (user[d1].USDT+=amt*1/20,user[d2].USDT+=amt*3/100,user[d3].USDT+=amt*1/50, //USDT=5,3,2 
                    user[d1].token+=amt*1/50,user[d2].token+=amt*3/20,user[d3].token+=amt/10); //Token=20,15,10
                user[enumUser[i]].lastClaimed=block.timestamp;
            }
    }
    function Withdraw(uint amount)external{
        if(user[msg.sender].dateJoined>user[msg.sender].package*730 hours){
            IERC20(_USDT).transferFrom(address(this),msg.sender,amount*1e18);
            IERC20AC(_TOKEN).transferFrom(address(this),msg.sender,amount*1e18);
        }
    }
}