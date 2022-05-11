pragma solidity>0.8.0;//SPDX-License-Identifier:None
interface IERC721{
    event Transfer(address indexed a,address indexed b,uint256 indexed c);
    event Approval(address indexed a,address indexed b,uint256 indexed c);
    event ApprovalForAll(address indexed a,address indexed b,bool c);
    function balanceOf(address a)external view returns(uint256 b);
    function ownerOf(uint256 a)external view returns(address b);
    function safeTransferFrom(address a,address b,uint256 c)external;
    function transferFrom(address a,address b,uint256 c)external;
    function approve(address a,uint256 b)external;
    function getApproved(uint256 a)external view returns(address b);
    function setApprovalForAll(address a,bool b)external;
    function isApprovedForAll(address a,address b)external view returns(bool);
    function safeTransferFrom(address a,address b,uint256 c,bytes calldata d)external;
}
interface IERC721Metadata{
    function name()external view returns(string memory);
    function symbol()external view returns(string memory);
    function tokenURI(uint256 a)external view returns(string memory);
}
interface IERC20{function transferFrom(address a,address b,uint256 c)external;}
interface IERC20AC{function transferFrom(address a,address b,uint256 c)external;}
interface IPCSV2{function getAmountsOut(uint amountIn,address[]memory path)external returns(uint[]memory);}
contract ERC721AC_93N is IERC721,IERC721Metadata{
    address private _owner;
    address[]private enumUser;
    /*** TO BE REPLACED WITH USDT & TOKEN ADDRESS ***/
    address private constant _USDT=0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee;
    address private constant _TOKEN=0xE02dF9e3e622DeBdD69fb838bB799E3F168902c5;
    address private constant _PCSV2=0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
    mapping(uint256=>address)private _owners;
    mapping(uint256=>address)private _tokenApprovals;
    mapping(address=>mapping(address=>bool))private _operatorApprovals;
    struct User{
        address upline;
        uint wallet;
        uint lastClaimed;
        uint dateJoined;
        uint package;
        uint balances;
    }
    mapping(address=>User)public user;
    constructor(){
        _owner=user[msg.sender].upline=msg.sender;
    }
    function name()external pure override returns(string memory){return "Ninety Three N";}
    function symbol()external pure override returns(string memory){return "93N";}
    function tokenURI(uint256 a)external pure override returns(string memory){
        a;
        return"";
    }
    function supportsInterface(bytes4 a)external pure returns(bool){return a==type(IERC721).interfaceId||a==type(IERC721Metadata).interfaceId;}
    function balanceOf(address a)external view override returns(uint256){return user[a].balances;}
    function ownerOf(uint256 a)public view override returns(address){return _owners[a];}
    function owner()external view returns(address){return _owner;}
    function approve(address a,uint256 b)external override{
        require(msg.sender==ownerOf(b)||isApprovedForAll(ownerOf(b),msg.sender));
        _tokenApprovals[b]=a;
        emit Approval(ownerOf(b),a,b);
    }
    function setApprovalForAll(address a,bool b)external override{
        _operatorApprovals[msg.sender][a]=b;
        emit ApprovalForAll(msg.sender,a,b);
    }
    function getApproved(uint256 a)public view override returns(address){return _tokenApprovals[a];}
    function isApprovedForAll(address a,address b)public view override returns(bool){return _operatorApprovals[a][b];}
    function transferFrom(address a,address b,uint256 c)public override{unchecked{
        require(a==ownerOf(c)||getApproved(c)==a||isApprovedForAll(ownerOf(c),a));
        (_tokenApprovals[c]=address(0),user[a].balances-=1,user[b].balances+=1,_owners[c]=b);
        emit Approval(ownerOf(c),b,c);
        emit Transfer(a,b,c);
    }}
    function safeTransferFrom(address a,address b,uint256 c)external override{
        transferFrom(a,b,c);
    }
    function safeTransferFrom(address a,address b,uint256 c,bytes memory d)external override{
        transferFrom(a,b,c);d;
    }
    function MINT(address a,uint256 b)public{unchecked{
        (user[a].balances+=1,_owners[b]=a);
        emit Transfer(address(0),a,b);
    }}
    function Deposit(address referral,uint amount,uint package)external payable{unchecked{
        require(referral!=msg.sender);
        /*** SET APPROVAL FROM WEB3 FIRST ***/
        IERC20(_USDT).transferFrom(msg.sender,address(this),amount*1e18);
        (user[msg.sender].upline,user[msg.sender].package)=
            (referral==address(0)?_owner:referral,package);
        address[]memory pair=new address[](2);
        (pair[0],pair[1])=(_TOKEN,_USDT);
        uint[]memory currentPrice=IPCSV2(_PCSV2).getAmountsOut(amount,pair);

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
            IERC20AC(_TOKEN).transferFrom(address(this),msg.sender,amount*1e18);
        }
    }}
}
