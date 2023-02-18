// SPDX-License-Identifier: Unlicensed

pragma solidity >=0.7.0 <0.9.0;

contract CampaignFactory {
    
    address[] public _deployedCampaigns;
    address payable public _admin;

    event CampaignCreatedEvent( 
        address indexed owner,
        string indexed indexedCategory,
        uint indexed timestamp, 
        string title, 
        uint requiredAmount,
        address campignAddress, 
        string imgHash,
        string descHash,
        string category,
        string email
    );

    constructor()
    {
        _admin = payable(msg.sender);
    }
    function CreateCampaignFunc(string memory title,uint requiredAmount,string memory imageHash,string memory descURL,string memory category,string memory email ) public
    {
        
        Campaign newCampaign= new Campaign(title,requiredAmount,imageHash,descURL,category,msg.sender,_admin,email);
        _deployedCampaigns.push(address(newCampaign));

        emit CampaignCreatedEvent(
            msg.sender,
            category,
            block.timestamp,
            title,
            requiredAmount,
            address(newCampaign),
            imageHash,
            descURL,
            category,
            email
        );

    }
}
contract Campaign {

    string public _title;
    uint public _requiredAmount;
    string public _imageHash;
    string public _descHash;
    address payable public _owner;
    uint public _receivedAmount;
    string public _category;
    bool public _isApproved;
    address payable public _admin;
    address payable[] public _donarsAddresses;
    uint[] public _donarsAmount;
    uint public _rewardDistributed;
    string public _email;

    constructor(string memory title,uint requiredAmount,string memory imageHash,string memory storyHash,string memory category,address campignOwner,address admin,string memory email)
    {
        _title = title;
        _requiredAmount = requiredAmount;
        _imageHash = imageHash;
        _descHash = storyHash;
        _category = category;
        _owner = payable(campignOwner);
        _admin = payable(admin);
        _isApproved = false;
        _email = email;
    }

    event DonatedEvent (address indexed donar, uint indexed amount, uint indexed timestamp);
    event UpdateEvent (string  tittle, string dsecription, uint indexed timestamp);

    function DonateFunc()public payable{
        require(_isApproved,"Campign Not Approved");
        require(_requiredAmount!=_receivedAmount,"Required Amount Fulfilled");
        require(_requiredAmount>=_receivedAmount+msg.value,"Amount exceeded the required Amount");
        _owner.transfer(msg.value);
        _receivedAmount += msg.value;
        emit DonatedEvent(msg.sender,msg.value,block.timestamp);
        _rewardDistributed += msg.value;
        for(uint i=0;i<_donarsAddresses.length;i++)
        {
            if(msg.sender==_donarsAddresses[i])
            {
                _donarsAmount[i] += msg.value;
                return;
            }
        }
        _donarsAddresses.push(payable(msg.sender));
        _donarsAmount.push(msg.value);
    }

    function ApproveFunc()public {
         require(msg.sender==_admin,"Only Admin Can Approve Campigns");
         require(!_isApproved,"Campign already approved");
         emit UpdateEvent("Campaign Started","Campaign is started and is approved from Admin",block.timestamp);
        _isApproved = true;
    }
    function UpdateProgress(string memory tittle, string memory description)public {
        require(msg.sender==_owner,"Only campaign Owner can update status");
        require(_isApproved,"Campign Not Approved");
        emit UpdateEvent(tittle,description,block.timestamp);
   }
   function DistributeReward()public payable{
        require(msg.sender==_owner,"Only campaign Owner can distribute reward");
        require(_isApproved,"Campign Not Approved");
         require(_requiredAmount!=_receivedAmount,"Campaign Not Completed");
        string memory stringValue = uintToString(msg.value);
        string memory arg = " distibuted among the donars";

        for(uint i=0;i<_donarsAddresses.length;i++)
        {
            _donarsAddresses[i].transfer(msg.value/_donarsAddresses.length);
        }

        emit UpdateEvent("Reward Distributed", string(abi.encodePacked(stringValue, arg)),block.timestamp);
   }

    function uintToString(uint v) public pure returns (string memory) {
        uint maxlength = 100;
        bytes memory reversed = new bytes(maxlength);
        uint i = 0;
        while (v != 0) {
            uint remainder = v % 10;
            v = v / 10;
            reversed[i++] = bytes1(uint8(48 + remainder));
        }
        bytes memory s = new bytes(i); 
        for (uint j = 0; j < i; j++) {
            s[j] = reversed[i - j - 1]; 
        }
        string memory str = string(s);  
        return str;
    }
}