//SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

contract CharitableDonation {

    // Struct to hold charitable donors

    struct Donor {
        string name;
        uint amount;
    }

    // Struct for each charity that can receive donations

    struct Charity {
        address payable charityAddr;
        string name;
        uint donationsAccumulated;
        uint targetAmount;
        // a mapping of an individual donor address to a Donor struct which tracks their donation
        mapping(address=>Donor) donors;
    }

    // The charity
    Charity public charity;

    address public administrator;

    // Constructor

    constructor(address payable charityAddress,  string memory charityName) {
        administrator = msg.sender;
        charity.charityAddr = charityAddress;        
        charity.name = charityName;        
    }

    // set the donation target amount
    function setTargetAmount(uint _targetAmount) public {
        require(msg.sender == administrator, "Only the administrator can set the donation target amount!");
        charity.targetAmount = _targetAmount;
    }

    //A function to allow for a donor to make a donation and track the accumulated donations

    event DonationEvent(address indexed donorAddress, uint indexed amount);

    function makeDonationAndTrack(string calldata _donorName) external payable{
        uint amount = msg.value;
        address donorAddress = msg.sender;
        Donor memory donorRecord = charity.donors[donorAddress];
        //add amount to donor donations if it is not donor's first donation
        if(donorRecord.amount != 0){
            if(keccak256(bytes(donorRecord.name)) == keccak256(bytes(_donorName))){
                revert("Donor name is not matching with our records");
            }
            else{
                
                donorRecord.amount+=amount;
                emit DonationEvent(donorAddress, donorRecord.amount);
            }
        } 
        else{ //create donation record
            charity.donors[donorAddress]=Donor({name: _donorName, amount: amount});
            emit DonationEvent(donorAddress, amount);
        }
        //update charity donation accumulator
        charity.donationsAccumulated += amount;
        
    }
    
    //A function to check if the target amount has been reached, and then releases the funds from the contract to the charity.

    modifier onlyAdministrator(){
        if (administrator != msg.sender) revert ("Only administrator can release funds");
        _;
    }

    event FundReleaseEvent(uint indexed amount);

    function releaseFunds() external onlyAdministrator returns(string memory output){
        uint balance = address(this).balance;
        if(balance >= charity.targetAmount){
            //release funds to charity address
            (bool sent, ) = charity.charityAddr.call{
                value: balance 
            }("");
            require(sent, "Failed to release funds");
            charity.donationsAccumulated = 0;
            emit FundReleaseEvent(balance);
            return "Successfully released funds";
        }
        else{
            return "Charity did not reach target amount yet. Releasing funds is declined.";
        }   
    }
    
}