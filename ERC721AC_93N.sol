/*** [DEPLOYMEN] CHANGE TOKEN ADDRESSES & WEB3 APPROVAL FIRST ***/
pragma solidity>0.8.0;//SPDX-License-Identifier:None
import"https://github.com/aloycwl/ERC_AC/blob/main/ERC721AC/ERC721AC.sol";
interface IERC20{function transferFrom(address,address,uint)external;}
interface IPCSV2{function getAmountsOut(uint,address[]memory)external returns(uint[]memory);}
contract ERC721AC_93N is ERC721AC{
    event Payout(address indexed from,address indexed to,uint amount,uint indexed status); //0in,1n,2stake,3out
    uint public Split;
    uint private _count;
    address[]private enumUser;
    address private constant _USDT=0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee;
    address private constant _TOKEN=0xE02dF9e3e622DeBdD69fb838bB799E3F168902c5;
    address private constant _PCSV2=0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
    address private constant _TECH=0x15eD406870dB283E810D5885e432d315C94DD0dd;
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
    constructor(){
        _owner=user[msg.sender].upline=msg.sender;
    }
    function name()external pure override returns(string memory){return"Ninety Three N";}
    function symbol()external pure override returns(string memory){return"93N";}
    function tokenURI(uint a)external view override returns(string memory){
        uint total=user[_owners[a]].totalDeposit;
        return total>=1e23?"ipfs://bafybeigotmg4hsqw6dunfu5is5wfobk7wtikzk4uimbtd43wbr56pf7aba/red.png":
        total>=1e22?"ipfs://bafybeig4vcqmyuxdsv7jwrrh22mznoqbqv2pd75yucltc5wqid2oia6tr4/gold.png":
        "ipfs://https://ipfs.io/ipfs/bafybeiampsworvim5pktw6iuji2rwceltrunpzjndahdarb4ydtri644ha/black.png";
    }
    function balanceOf(address a)external view override returns(uint){return user[a].dateJoined>0?1:0;}
    function transferFrom(address a,address b,uint c)public override{unchecked{
        require(a==_owners[c]||getApproved(c)==a||isApprovedForAll(_owners[c],a));
        require(user[b].dateJoined<1); //Cannot transfer to existing member
        (_tokenApprovals[c]=address(0),_owners[c]=b,user[b]=user[a]); //Full transfer begins
        delete user[a];
        for(uint i=0;i<enumUser.length;i++)if(enumUser[i]==a){ //Less one for scanning
            enumUser[i]=enumUser[enumUser.length-1];
            enumUser.pop();
        }
        emit Approval(_owners[c],b,c);
        emit Transfer(a,b,c);
    }}
    function Deposit(address referral,uint amount,uint months)external payable{unchecked{
        require(referral!=msg.sender);
        /*
        Uplines & tech to get USDT 5%, 3%, 2% & tech 1%
        Getting uplines for payout
        */
        (address d1,address d2,address d3)=getUplines(msg.sender); 
        _payment(_USDT,msg.sender,address(this),amount,0);
        _payment4(_USDT,address(this),[d1,d2,d3,_TECH],[amount*1/20,amount*3/100,amount*1/50,amount*1/100],0);
        /*
        Connect to PanCakeSwap to get the live price
        Issue the number of tokens in equivalent to USDT
        Initiate new user
        Uplines to get tokens 5%, 10%, 15%
        */
        address[]memory pair=new address[](2); 
        (pair[0],pair[1])=(_TOKEN,_USDT);
        uint[]memory currentPrice=IPCSV2(_PCSV2).getAmountsOut(amount,pair);
        (uint tokens,User storage u)=(amount/currentPrice[0],user[msg.sender]);
        (u.months=months,u.wallet=tokens,u.dateJoined=u.lastClaimed=block.timestamp,u.totalDeposit+=amount);
        _payment4(_TOKEN,address(this),[d1,d2,d3,address(0)],[tokens*1/20,tokens*1/10,tokens*3/20,0],0);
        /*
        Only mint and set variable when user is new
        Only set upline and downline when user is new
        Add user into enumUser for counting purposes
        */
        if(u.dateJoined<1){
            u.upline=referral==address(0)?_owner:referral;
            (_owners[_count]=msg.sender,_count++);
            user[referral].downline.push(msg.sender);
            enumUser.push(msg.sender);
            emit Transfer(address(0),msg.sender,_count);
        }
    }}
    function getUplines(address a)private view returns(address d1,address d2,address d3){
        (d1=user[a].upline,d2=user[d1].upline,d3=user[d2].upline);
    }
    function _payment(address con,address from,address to,uint amt,uint status)private{
        IERC20(con).transferFrom(from,to,amt);
        emit Payout(from,to,amt,status);
    }
    function _payment4(address con,address from,address[4]memory to,uint[4]memory amt,uint status)private{
        for(uint i=0;i<5;i++){
            if(to[i]==address(0))return;
            _payment(con,from,to[i],amt[i],status);
        }
    }
    function Staking()external{unchecked{
        for(uint i=0;i<enumUser.length;i++){
            address d0=enumUser[i]; //31,536,000 seconds a year=exactly 730 hours
            (uint timeClaimed,uint timeJoined,uint wallet)=
            (block.timestamp-user[d0].lastClaimed,block.timestamp-user[d0].dateJoined,user[msg.sender].wallet);
            if(timeJoined<(user[d0].months+1)*730 hours){ //Still within contract
                if(timeClaimed>=1 hours){
                    uint amt=timeClaimed/730*user[d0].wallet*(user[d0].months==3?2:user[d0].months==6?3:4)/100;
                    (address d1,address d2,address d3)=getUplines(d0); //Prorate + 15%,10%,5%
                    _payment4(_TOKEN,address(this),[d1,d2,d3,d0],[amt*1/20,amt*1/10,amt*3/20,amt],2);
                    user[d0].lastClaimed=block.timestamp;
                }
            }else if(wallet>0){ //Release 4-3-3 / Split
                if(timeJoined>=(user[d0].months+3*Split)*730 hours)wallet=wallet/Split;
                else wallet*=wallet*2/5/Split;
                user[d0].wallet-=wallet;
                _payment(_TOKEN,address(this),d0,wallet,3);
            }
        }
    }}
    function SetSplit(uint num)external{
        require(msg.sender==_owner);
        Split=num;
    }
    function getDownlines(address a)external view returns(address[]memory b,address[]memory c,address[]memory d){
        uint d2Length;
        uint d3Length;
        b=user[a].downline;
        for(uint i=0;i<b.length;i++){ //Get total level 2 and 3 counts
            address[]memory c1=user[b[i]].downline;
            for(uint j=0;j<c1.length;j++){
                address[]memory d1=user[c1[j]].downline;
                d2Length++;
                for(uint k=0;k<d1.length;k++)d3Length++;
            }
        }
        (c,d,d2Length,d3Length)=(new address[](d2Length),new address[](d2Length),0,0); //Fill in each downlines
        for(uint i=0;i<b.length;i++){
            address[]memory c1=user[b[i]].downline;
            for(uint j=0;j<c1.length;j++){
                address[]memory d1=user[c1[j]].downline;
                (c[d2Length]=d1[j],d2Length++);
                for(uint k=0;k<d1.length;k++)(d[d3Length]=user[d1[j]].downline[k],d3Length++);
            }
        }
    }
}
