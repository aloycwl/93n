pragma solidity>0.8.0;//SPDX-License-Identifier:None
interface IERC721{
    event Transfer(address indexed a,address indexed b,uint indexed c);
    event Approval(address indexed a,address indexed b,uint indexed c);
    event ApprovalForAll(address indexed a,address indexed b,bool c);
    function balanceOf(address a)external view returns(uint b);
    function ownerOf(uint a)external view returns(address b);
    function safeTransferFrom(address a,address b,uint c)external;
    function transferFrom(address a,address b,uint c)external;
    function approve(address a,uint b)external;
    function getApproved(uint a)external view returns(address b);
    function setApprovalForAll(address a,bool b)external;
    function isApprovedForAll(address a,address b)external view returns(bool);
    function safeTransferFrom(address a,address b,uint c,bytes calldata d)external;
}
interface IERC721Metadata{
    function name()external view returns(string memory);
    function symbol()external view returns(string memory);
    function tokenURI(uint a)external view returns(string memory);
}
interface IERC20{function transferFrom(address a,address b,uint c)external;}
interface IERC20AC{function transferFrom(address a,address b,uint c)external;}
interface IPCSV2{function getAmountsOut(uint amountIn,address[]memory path)external returns(uint[]memory);}
contract ERC721AC_93N is IERC721,IERC721Metadata{
    uint private _count;
    address private _owner;
    address[]private enumUser;
    /*** TO BE REPLACED WITH USDT & TOKEN ADDRESS ***/
    address private constant _USDT=0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee;
    address private constant _TOKEN=0xE02dF9e3e622DeBdD69fb838bB799E3F168902c5;
    address private constant _PCSV2=0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
    address private constant _TECH=0x15eD406870dB283E810D5885e432d315C94DD0dd;
    mapping(uint=>address)private _owners;
    mapping(uint=>address)private _tokenApprovals;
    mapping(address=>mapping(address=>bool))private _operatorApprovals;
    struct User{
        address upline;
        uint wallet;
        uint lastClaimed;
        uint dateJoined;
        uint months;
        uint balances;
    }
    mapping(address=>User)public user;
    constructor(){
        _owner=user[msg.sender].upline=msg.sender;
    }
    function name()external pure override returns(string memory){return "Ninety Three N";}
    function symbol()external pure override returns(string memory){return "93N";}
    function tokenURI(uint a)external view override returns(string memory){
        uint months=user[_owners[a]].months;
        return months>6?"ipfs://9months":months>3?"ipfs://6months":"ipfs://3months";
    }
    function supportsInterface(bytes4 a)external pure returns(bool){return a==type(IERC721).interfaceId||a==type(IERC721Metadata).interfaceId;}
    function balanceOf(address a)external view override returns(uint){return user[a].balances;}
    function ownerOf(uint a)public view override returns(address){return _owners[a];}
    function owner()external view returns(address){return _owner;}
    function approve(address a,uint b)external override{
        require(msg.sender==ownerOf(b)||isApprovedForAll(ownerOf(b),msg.sender));
        _tokenApprovals[b]=a;
        emit Approval(ownerOf(b),a,b);
    }
    function setApprovalForAll(address a,bool b)external override{
        _operatorApprovals[msg.sender][a]=b;
        emit ApprovalForAll(msg.sender,a,b);
    }
    function getApproved(uint a)public view override returns(address){return _tokenApprovals[a];}
    function isApprovedForAll(address a,address b)public view override returns(bool){return _operatorApprovals[a][b];}
    function transferFrom(address a,address b,uint c)public override{unchecked{
        require(a==ownerOf(c)||getApproved(c)==a||isApprovedForAll(ownerOf(c),a));
        (_tokenApprovals[c]=address(0),user[a].balances-=1,user[b].balances+=1,_owners[c]=b);
        emit Approval(ownerOf(c),b,c);
        emit Transfer(a,b,c);
    }}
    function safeTransferFrom(address a,address b,uint c)external override{transferFrom(a,b,c);}
    function safeTransferFrom(address a,address b,uint c,bytes memory d)external override{transferFrom(a,b,c);d;}

    function Deposit(address referral,uint amount,uint months)external payable{unchecked{
        require(referral!=msg.sender);
        /*** SET APPROVAL FROM WEB3 FIRST ***/
        IERC20(_USDT).transferFrom(msg.sender,address(this),amount*1e18); //Deduct package amount

        address[]memory pair=new address[](2); //Getting the current token price
        (pair[0],pair[1])=(_TOKEN,_USDT);
        uint[]memory currentPrice=IPCSV2(_PCSV2).getAmountsOut(amount,pair);

        User storage u=user[msg.sender]; //Setting user account & mint NFT
        (u.upline=referral==address(0)?_owner:referral,u.months=months,u.wallet=amount/currentPrice[0],
        u.dateJoined=block.timestamp,u.lastClaimed=block.timestamp,u.balances+=1,_owners[_count]=msg.sender);
        enumUser.push(msg.sender);
        emit Transfer(address(0),msg.sender,_count);

        (address d1,address d2,address d3)=getUplines(msg.sender); //Paying uplines 5%, 3%, 2% & tech 1%
        IERC20(_USDT).transferFrom(address(this),d1,amount*1/20*1e18);
        IERC20(_USDT).transferFrom(address(this),d2,amount*3/100*1e18);
        IERC20(_USDT).transferFrom(address(this),d3,amount*1/50*1e18);
        IERC20(_USDT).transferFrom(address(this),_TECH,amount*1/100*1e18);
    }}

    function Staking()external{unchecked{
        for(uint i=0;i<enumUser.length;i++){
            address d0=enumUser[i];
            if(user[d0].lastClaimed>=730 hours&& //31,536,000 seconds a year=exactly 730 hours
            user[d0].dateJoined<=(user[d0].months+1)*730 hours){ //Expire contract no money
                (address d1,address d2,address d3)=getUplines(user[d0].upline);
                uint percent=(user[d0].months==3?2:user[d0].months==6?3:4)/100; //3 mth=2%, 6 mths=3%, 9 mth=4%
                uint amt=user[d0].wallet*percent;
                (user[d1].wallet+=amt*1/20,user[d2].wallet+=amt*3/100,user[d3].wallet+=amt*1/50); //Token=5,3,2 
                    //user[d1].token+=amt*1/50,user[d2].token+=amt*3/20,user[d3].token+=amt/10); //Token=20,15,10
                user[d0].lastClaimed=block.timestamp;
            }
        }
    }}
    function Withdraw(uint amount)external{unchecked{
        if(user[msg.sender].dateJoined>user[msg.sender].months*730 hours){
            IERC20AC(_TOKEN).transferFrom(address(this),msg.sender,amount*1e18);
        }
    }}
    function getUplines(address a)public view returns(address d1,address d2,address d3){
        d1=user[a].upline;
        d2=user[d1].upline;
        d3=user[d2].upline;
    }
}
