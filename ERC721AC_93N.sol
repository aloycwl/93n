/***
[DEPLOYMENT] CHANGE TOKEN ADDRESSES
[QUERIES]
1. If user redeposit before his tenure ends, can the total amount be override?
2. Or each purchase must be in USDT and is a unique piece, if so the any limit?
3. Must be weekly pay out? If that way I will add variables to put out
***/
pragma solidity>0.8.0;//SPDX-License-Identifier:None
import"https://github.com/aloycwl/ERC_AC/blob/main/ERC721AC/ERC721AC.sol";
interface IERC20{function transferFrom(address,address,uint)external;function testMint()external;}
interface IPCSV2{function getAmountsOut(uint,address[]memory)external returns(uint[]memory);}
contract ERC721AC_93N is ERC721AC{
    /*
    The status to be emitted 0-in USDT, 1-in 93N, 2-stake, 3-out
    */
    event Payout(address indexed from,address indexed to,uint amount,uint indexed status);
    uint public Split;
    uint private _count;
    address[]private users;
    /*
    Require all the addresses to get live price from PanCakeSwap
    And to transfer using interface directly
    */
    address private _USDT;
    address private _TOKEN;
    //address private constant _PCSV2=0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
    address private constant _TECH=0xdD870fA1b7C4700F2BD7f44238821C26f7392148;
    struct User{
        address upline;
        address[]downline;
        uint wallet;
        uint lastClaimed;
        uint dateJoined;
        uint months;
        uint totalDeposit;
    }
    mapping(address=>User)public user;
    constructor(address _U, address _T){
        _owner=user[msg.sender].upline=msg.sender;
        (_USDT,_TOKEN)=(_U,_T);
    }
    function name()external pure override returns(string memory){return"Ninety Three N";}
    function symbol()external pure override returns(string memory){return"93N";}
    function tokenURI(uint a)external view override returns(string memory){
        uint total=user[_owners[a]].totalDeposit;
        return total>=1e23?"ipfs://bafybeigjnlikmsm3mjvhx6ijk26bedd5lrvi3yfjlwgytzzj3h5ao6i57i/red.json":
        total>=1e22?"ipfs://bafybeiaubm73azo4beh7am63wkua3zj4ijgy6n4gjc7spe3okwuxrt66t4/gold.json":
        "ipfs://bafybeibtgqc26sv74erbgm6grtivjvfglffol4an4nvhorbv3ljgamg4uu/black.json";
    }
    function balanceOf(address a)external view override returns(uint){return user[a].dateJoined>0?1:0;}
    function transferFrom(address a,address b,uint c)public override{unchecked{
        /*
        Normal ERC721 token applies
        User can only transfer to not an existing user
        */
        require(a==_owners[c]||getApproved(c)==a||isApprovedForAll(_owners[c],a));
        require(user[b].dateJoined<1);
        /*
        Entire user will be duplicated to the new user where
        The old user will be deleted
        Enum will be updated too for each week's payout
        */
        (_tokenApprovals[c]=address(0),_owners[c]=b,user[b]=user[a]);
        delete user[a];
        for(uint i=0;i<users.length;i++)if(users[i]==a){
            users[i]=users[users.length-1];
            users.pop();
        }
        emit Approval(_owners[c],b,c);
        emit Transfer(a,b,c);
    }}
    function Deposit(address referral,uint amount,uint months)external{unchecked{
        require(referral!=msg.sender);
        require(user[referral].upline!=address(0));
        /*
        Connect to PanCakeSwap to get the live price
        Issue the number of tokens in equivalent to USDT
        Initiate new user
        */
        /*address[]memory pair=new address[](2); 
        (pair[0],pair[1])=(_TOKEN,_USDT);
        uint[]memory currentPrice=IPCSV2(_PCSV2).getAmountsOut(amount,pair);
        (uint tokens,User storage u)=(amount/currentPrice[0],user[msg.sender]);*/
        (uint tokens,User storage u)=(amount,user[msg.sender]);
        (u.months=months,u.wallet=tokens,u.dateJoined=u.lastClaimed=block.timestamp,u.totalDeposit+=amount);
        /*
        Only mint and set variable when user is new
        Only set upline and downline when user is new
        Add user into enumUser for counting purposes
        */
        if(u.upline==address(0)){
            u.upline=referral==address(0)?_owner:referral;
            (_owners[_count]=msg.sender,_count++);
            user[referral].downline.push(msg.sender);
            users.push(msg.sender);
            emit Transfer(address(0),msg.sender,_count);
        }
        /*
        Uplines & tech to get USDT 5%, 3%, 2% & tech 1%
        Uplines to get tokens 5%, 10%, 15%
        Getting uplines for payout
        */
        (address d1,address d2,address d3)=getUplines(msg.sender); 
        _payment(_USDT,msg.sender,msg.sender,address(this),amount,0);
        _payment4(_USDT,address(this),msg.sender,[d1,d2,d3,_TECH],[amount*1/20,amount*3/100,amount*1/50,amount*1/100],0);
        _payment4(_TOKEN,address(this),msg.sender,[d1,d2,d3,address(0)],[tokens*1/20,tokens*1/10,tokens*3/20,0],1);
    }}
    function _payment(address con,address from,address usr,address to,uint amt,uint status)private{
        /*
        Custom connection to the various token address
        Emit events for history
        */
        IERC20(con).transferFrom(from,to,amt);
        emit Payout(usr,to,amt,status);
    }
    function _payment4(address con,address from,address usr,address[4]memory to,uint[4]memory amt,uint status)private{unchecked{
        /*
        Payout loop of 4 iterations
        Exit fuction (for payment of USDT) if no address found
        */
        for(uint i=0;i<4;i++){
            if(to[i]==address(0))return;
            _payment(con,from,usr,to[i],amt[i],status);
        }
    }}
    function Staking()external{unchecked{
        /*
        Go through every users and pay them and their upline accordingly
        31,536,000 seconds a year=exactly 730 hours
        Get last claim and time joined to accurately payout
        */
        for(uint i=0;i<users.length;i++){
            address d0=users[i];
            (uint timeClaimed,uint timeJoined,uint wallet)=
            (block.timestamp-user[d0].lastClaimed,block.timestamp-user[d0].dateJoined,user[msg.sender].wallet);
            /*
            As long as user still in contract
            Pro-rated payment in case this function is being called more than once a week
            Token payment direct to wallet in term of 15%, 10%, 5%
            Update user last claim if claimed
            */
            if(timeJoined<(user[d0].months+1)*730 hours){
                if(timeClaimed>=1 hours){
                    uint amt=timeClaimed/730*user[d0].wallet*(user[d0].months==3?2:user[d0].months==6?3:4)/100;
                    (address d1,address d2,address d3)=getUplines(d0); 
                    _payment4(_TOKEN,address(this),d0,[d1,d2,d3,d0],[amt*1/20,amt*1/10,amt*3/20,amt],2);
                    user[d0].lastClaimed=block.timestamp;
                }
            /*
            If user decided not to continue
            Release to 4-3-3 in month
            Months are divided if split is modified
            */
            }else if(wallet>0){
                if(timeJoined>=(user[d0].months+3*Split)*730 hours)wallet=wallet/Split;
                else wallet*=wallet*2/5/Split;
                user[d0].wallet-=wallet;
                _payment(_TOKEN,address(this),address(this),d0,wallet,3);
            }
        }
    }}
    function SetSplit(uint num)external{
        /*
        Modifying the split to slow down the withdrawal
        */
        require(msg.sender==_owner);
        Split=num;
    }
    function getUplines(address a)private view returns(address d1,address d2,address d3){
        /*
        Get direct first
        Use previous direct to get next direct and so on
        */
        (d1=user[a].upline,d2=user[d1].upline,d3=user[d2].upline);
    }
    function getDownlines(address a)external view returns(address[]memory b,address[]memory c,address[]memory d){unchecked{
        uint d2Length;
        uint d3Length;
        b=user[a].downline;
        /*
        Loop through all level 2 and level 3 downlines
        Create new array counts
        Set length and reset variables for later use
        */
        for(uint i=0;i<b.length;i++){
            address[]memory c1=user[b[i]].downline;
            d2Length+=c1.length;
            for(uint j=0;j<c1.length;j++)d3Length+=user[c1[j]].downline.length;
        }
        (c=new address[](d2Length),d=new address[](d3Length),d2Length=d3Length=0);
        /*
        Fill the count with actual address
        */
        for(uint i=0;i<b.length;i++){
            address[]memory c1=user[b[i]].downline;
            for(uint j=0;j<c1.length;j++){
                (c[d2Length]=c1[j],d2Length++);
                for(uint k=0;k<user[c1[j]].downline.length;k++)(d[d3Length]=user[c1[j]].downline[k],d3Length++);
            }
        }
    }}
}
