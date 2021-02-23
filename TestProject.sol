pragma solidity 0.8.0;
pragma abicoder v2;

//@dev Let's set our contract name;
contract Wallet {
    //@dev set array of owners address+limit;
    address[] public owners;
    uint limit;

    //@dev create struct transfer;
    struct Transfer{
        uint amount;
        address payable receiver;
        uint approvals;
        bool hasBeenSent;
        uint id;
    }

    Transfer[] transferRequests;

    //@dev let's add a few events;
    event TransferRequestCreated(uint _id, uint _amount, address _initiator, address _receiver);
    event ApprovalReceived(uint _id, uint _approvals, address _approver);
    event TransferApproved(uint _id);

    //@dev we will need a double mapping, uint=>bool;
    mapping(address => mapping(uint => bool)) approvals;

    //@dev Only allow the owners list to execute.
    modifier onlyOwners(){
        bool owner = false;
        for(uint i = 0; i < owners.length; i++) {
            if(owners[i] == msg.sender) {
                owner = true;
            }
        }
        require(owner == true);
        _;
    }
    //@dev Initialize the owners list and the limit ;
    constructor(address[] memory _owners, uint _limit) {
        owners = _owners;
        limit = _limit;
    }

    //@dev create deposit empty function;
    function deposit() public payable {}

    //@dev Create Transfer struct and add it to the transferRequests array.
    function createTransfer(uint _amount, address payable _receiver) public onlyOwners {
        emit TransferRequestCreated(transferRequests.length, _amount, msg.sender, _receiver);
        transferRequests.push(Transfer(_amount, _receiver, 0, false, transferRequests.length));
    }

    //@dev Set your approval for one of the transfer requests.
    //@dev Need to update the Transfer object.
    //@dev Need to update the mapping to record the approval for the msg.sender.
    //@dev When the amount of approvals for a transfer has reached the limit, this function should send the transfer to the recipient.
    //@dev Owners should only vote once;
    //@dev Owners should not be able to vote on a tranfer request that has already been sent.
    function approve(uint _id) public onlyOwners {
        require(approvals[msg.sender][_id] == false);
        require(transferRequests[_id].hasBeenSent == false);

        approvals[msg.sender][_id] == true;
        transferRequests[_id].approvals++;

        emit ApprovalReceived(_id, transferRequests[_id].approvals, msg.sender);

        if(transferRequests[_id].approvals >= limit) {
            transferRequests[_id].hasBeenSent = true;
            transferRequests[_id].receiver.transfer(transferRequests[_id].amount);
            emit TransferApproved(_id);
        }
    }

    //@dev return all transferRequests;
    function getTransferRequests() public view returns (Transfer[] memory){
        return transferRequests;
    }
