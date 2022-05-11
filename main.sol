/*
Matching on Staking
20% 15% 15%
3 level

Reinvest??
*/
pragma solidity>0.8.0;//SPDX-License-Identifier:None
interface IERC20{function transferFrom(address a,address b,uint256 c)external;}
interface IERC20AC{function transferFrom(address a,address b,uint256 c)external;}
contract simpleMLM{
    address[]private enumUser;
    address private _owner;
    /*** TO BE REPLACED WITH USDT & TOKEN ADDRESS ***/
    address private constant _USDT=0x55d398326f99059fF775485246999027B3197955;
    address private constant _TOKEN=0x73a2aa8E0718975Ac05766e0818c36e19b9620B0;
    struct User{
        address upline;
        uint wallet;
        uint lastClaimed;
        uint dateJoined;
        uint package; 
    }
    mapping(address=>User)public user;
    constructor(){
        _owner=user[msg.sender].upline=msg.sender;
    }
    function Deposit(address referral,uint amount,uint package)external payable{unchecked{
        require(referral!=msg.sender);
        /*** SET APPROVAL FROM WEB3 FIRST ***/
        IERC20(_USDT).transferFrom(msg.sender,address(this),amount*1e18);
        (user[msg.sender].upline,user[msg.sender].package)=
            (referral==address(0)?_owner:referral,package);
        /*** GET THE TOKEN PRICE FROM PANCAKE SWAP ***/
        /*** USDT to pay to upline directly ***/
        user[msg.sender].dateJoined=user[msg.sender].lastClaimed=block.timestamp;
        enumUser.push(msg.sender);
    }}
    function Staking()external{unchecked{
        for(uint i=0;i<enumUser.length;i++){
            address d0=enumUser[i];
            if(user[d0].lastClaimed>=730 hours&& //31,536,000 seconds a year=exactly 730 hours
                user[d0].dateJoined<=(user[d0].package+1)*730 hours){ //Expire contract no money
                address d1=user[d0].upline;
                address d2=user[d1].upline;
                address d3=user[d2].upline;
                uint percent=(user[d0].package==3?2:user[d0].package==6?3:4)/100; //3 mth=2%, 6 mths=3%, 9 mth=4%
                uint amt=user[d0].wallet*percent;
                (user[d1].wallet+=amt*1/20,user[d2].wallet+=amt*3/100,user[d3].wallet+=amt*1/50); //Token=5,3,2 
                    //user[d1].token+=amt*1/50,user[d2].token+=amt*3/20,user[d3].token+=amt/10); //Token=20,15,10
                user[d0].lastClaimed=block.timestamp;
            }
        }
    }}
    function Withdraw(uint amount)external{unchecked{
        if(user[msg.sender].dateJoined>user[msg.sender].package*730 hours){
            IERC20(_USDT).transferFrom(address(this),msg.sender,amount*1e18);
            IERC20AC(_TOKEN).transferFrom(address(this),msg.sender,amount*1e18);
        }
    }}
}