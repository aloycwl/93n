pragma solidity>0.8.0;//SPDX-License-Identifier:None
interface IERC721{event Transfer(address indexed from,address indexed to,uint indexed tokenId);event Approval(address indexed owner,address indexed approved,uint indexed tokenId);event ApprovalForAll(address indexed owner,address indexed operator,bool approved);function balanceOf(address)external view returns(uint);function safeTransferFrom(address,address,uint)external;function transferFrom(address,address,uint)external;function approve(address,uint)external;function getApproved(uint)external view returns(address);function setApprovalForAll(address,bool)external;function isApprovedForAll(address,address)external view returns(bool);function safeTransferFrom(address,address,uint,bytes calldata)external;}
interface IERC721Metadata{function name()external view returns(string memory);function symbol()external view returns(string memory);function tokenURI(uint)external view returns(string memory);}
interface IERC20{function transferFrom(address,address,uint)external;}
interface IPCSV2{function getAmountsOut(uint,address[]memory)external returns(uint[]memory);}
contract ERC721AC_93N is IERC721,IERC721Metadata{
    event Payout(address indexed to,uint amount,uint indexed payType);
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
        address[] downline;
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
    function name()external pure override returns(string memory){return"Ninety Three N";}
    function symbol()external pure override returns(string memory){return"93N";}
    function tokenURI(uint a)external view override returns(string memory){
        uint months=user[_owners[a]].months;
        return months>6?"ipfs://9months":months>3?"ipfs://6months":"ipfs://3months";
    }
    function supportsInterface(bytes4 a)external pure returns(bool){return a==type(IERC721).interfaceId||a==type(IERC721Metadata).interfaceId;}
    function balanceOf(address a)external view override returns(uint){return user[a].balances;}
    function ownerOf(uint a)external view returns(address){return _owners[a];}
    function owner()external view returns(address){return _owner;}
    function approve(address a,uint b)external override{require(msg.sender==_owners[b]||isApprovedForAll(_owners[b],msg.sender));_tokenApprovals[b]=a;emit Approval(_owners[b],a,b);}
    function setApprovalForAll(address a,bool b)external override{_operatorApprovals[msg.sender][a]=b;emit ApprovalForAll(msg.sender,a,b);}
    function getApproved(uint a)public view override returns(address){return _tokenApprovals[a];}
    function isApprovedForAll(address a,address b)public view override returns(bool){return _operatorApprovals[a][b];}
    function safeTransferFrom(address a,address b,uint c)external override{transferFrom(a,b,c);}
    function safeTransferFrom(address a,address b,uint c,bytes memory d)external override{transferFrom(a,b,c);d;}
    function transferFrom(address a,address b,uint c)public override{unchecked{
        require(a==_owners[c]||getApproved(c)==a||isApprovedForAll(_owners[c],a));
        (_tokenApprovals[c]=address(0),user[a].balances-=1,user[b].balances+=1,_owners[c]=b);
        emit Approval(_owners[c],b,c);
        emit Transfer(a,b,c);
    }}

    function Deposit(address referral,uint amount,uint months)external payable{unchecked{
        require(referral!=msg.sender); /*** SET APPROVAL FROM WEB3 FIRST ***/
        IERC20(_USDT).transferFrom(msg.sender,address(this),amount); //Deduct package amount

        address[]memory pair=new address[](2); //Getting the current token price
        (pair[0],pair[1])=(_TOKEN,_USDT);
        uint[]memory currentPrice=IPCSV2(_PCSV2).getAmountsOut(amount,pair);
        uint tokens=amount/currentPrice[0];

        User storage u=user[msg.sender]; //Setting user account & mint NFT
        (u.upline=referral==address(0)?_owner:referral,u.months=months,u.wallet=tokens,
        u.dateJoined=block.timestamp,u.lastClaimed=block.timestamp);
        enumUser.push(msg.sender);

        if(u.balances<0){ //Only mint when user has less than 1 NFT for reinvest
            (u.balances+=1,_owners[_count]=msg.sender,_count++);
            emit Transfer(address(0),msg.sender,_count);
        }

        uint existed;//Set downline if not existed
        for(uint i=0;i<user[referral].downline.length;i++)if(msg.sender==user[referral].downline[i])existed=1;
        if(existed<1)user[referral].downline.push(msg.sender);

        (address d1,address d2,address d3)=getUplines(msg.sender); //Paying uplines 2%|5%, 3%|10%, 5%|15% & tech 1%
        IERC20(_USDT).transferFrom(address(this),d1,amount*1/50);
        IERC20(_USDT).transferFrom(address(this),d2,amount*3/100);
        IERC20(_USDT).transferFrom(address(this),d3,amount*1/20);
        IERC20(_USDT).transferFrom(address(this),_TECH,amount*1/100);
        IERC20(_TOKEN).transferFrom(address(this),d1,tokens*1/20);
        IERC20(_TOKEN).transferFrom(address(this),d2,tokens*1/10);
        IERC20(_TOKEN).transferFrom(address(this),d3,tokens*3/20);
    }}

    function Staking()external{unchecked{
        for(uint i=0;i<enumUser.length;i++){
            address d0=enumUser[i]; //31,536,000 seconds a year=exactly 730 hours
            (uint timeClaimed,uint timeJoined,uint wallet)=
            (block.timestamp-user[d0].lastClaimed,block.timestamp-user[d0].dateJoined,user[msg.sender].wallet);
            if(timeJoined<(user[d0].months+1)*730 hours){ //Still within contract
                if(timeClaimed>=1 hours){
                    (address d1,address d2,address d3)=getUplines(user[d0].upline);
                    uint amt=timeClaimed/730*user[d0].wallet*(user[d0].months==3?2:user[d0].months==6?3:4)/100;
                    //Prorate + 15%,10%,5%
                    IERC20(_TOKEN).transferFrom(address(this),d1,amt*1/20);
                    IERC20(_TOKEN).transferFrom(address(this),d2,amt*1/10);
                    IERC20(_TOKEN).transferFrom(address(this),d3,amt*3/20);
                    user[d0].lastClaimed=block.timestamp;
                }
            }else if(wallet>0){ //Slowly release 40-30-30, ranging from 3rd, 2nd, 1st month
                if(timeJoined>=(user[d0].months+3)*730 hours)wallet=wallet;
                else if(timeJoined>=(user[d0].months+2)*730 hours)wallet=wallet*3/10;
                else wallet=wallet*2/5;
                IERC20(_TOKEN).transferFrom(address(this),msg.sender,wallet);
                user[msg.sender].wallet-=wallet;
            }
        }
    }}

    //function private 

    function getUplines(address a)private view returns(address d1,address d2,address d3){
        d1=user[a].upline;
        d2=user[d1].upline;
        d3=user[d2].upline;
    }

    function getDownlines(address a)external view returns(address[]memory b,address[]memory c,address[]memory d){
        uint d2Length; //Get counts first
        uint d3Length;
        b=user[a].downline;
        for(uint i=0;i<b.length;i++){
            address[]memory c1=user[b[i]].downline;
            for(uint j=0;j<c1.length;j++){
                address[]memory d1=user[c1[j]].downline;
                d2Length++;
                for(uint k=0;k<d1.length;k++)d3Length++;
            }
        }
        (c,d)=(new address[](d2Length),new address[](d2Length)); //Fill in each downlines
        (d2Length,d3Length)=(0,0);
        for(uint i=0;i<b.length;i++){
            address[]memory c1=user[b[i]].downline;
            for(uint j=0;j<c1.length;j++){
                address[]memory d1=user[c1[j]].downline;
                (c[d2Length]=d1[j],d2Length++);
                for(uint k=0;k<d1.length;k++) (d[d3Length]=user[d1[j]].downline[k],d3Length++);
                
            }
        }
    }
}
