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
contract simpleMLM{
    uint constant INVEST_AMOUNT=1000;
    address constant ADMIN=0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
    struct User{
        address upline;
        uint USDT;
        uint token;
    }
    mapping(address=>User)user;

    function Join(address referral)external payable{
         /*** TO BE REPLACED WITH USDT ADDRESS ***/
         /*** SET APPROVAL FROM WEB3 FIRST ***/
        IERC20 usdt=IERC20(address(0xd2a5bC10698FD955D1Fe6cb468a17809A08fd005));
        usdt.transferFrom(msg.sender,address(this),INVEST_AMOUNT*1e18);

    }

    function Withdraw()external payable{
        //IERC20 usdt=IERC20(address(0x7EF2e0048f5bAeDe046f6BF797943daF4ED8CB47));
        //usdt.transferFrom(0x5B38Da6a701c568545dCfcB03FcB875f56beddC4,1000);
    }
}