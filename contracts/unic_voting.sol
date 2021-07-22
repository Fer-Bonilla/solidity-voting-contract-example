// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/*
 * @UNIC Voting Dapp - Developeb by Oscar Bonilla ferbonillasua@gmail.com
 * @dev Smart contract for simple voting dapp.
 * The contract receive a list of 5 candidate names and the days that voting poll will be open
 * Voters need to be authorized by the contract owner
 * Voters only can vote one time and when voting poll still open
 * Contract owner can finish the poll at any time
 * The contract send back any founds sent to him
 */
contract UNICVotingDapp {
    
    //  Voting states Unauthorized = 0, Authorized = 1, Voted = 2
    enum VotingState  
        { 
        UnAuthorized, 
        Authorized, 
        Voted
        }
        
    VotingState voterState;
    
    //  Struct voter with the voter control info
    struct Voter {
        VotingState voteState;  // Register the authorization state
        uint vote;   // Id of the candidate voted
    }

     // Define the Owner Address
    address owner;
    
    
    // Define the date controlling variables
    uint8 daysAvailable;
    uint ballotCreationTime;
    uint ballotClosingDate;
    
    // Array for counting results
    uint256[6] countVoting = [0, 0, 0, 0, 0, 0];
    

    // Array for candidates name
    string[6] candidateNames;    

    // Keeo the votes countung
    uint256 public CountTotalVotes = 0;
    
    // Mapping of voters 
    mapping(address => Voter) public authorizedVoters;

    /* Modifiers declatarion */

    // Modifier to validate that only the contract owner can call the methods in the contract
    modifier onlyOwner() {
        require(msg.sender == owner);
    _;
    }
    
    modifier noVoted() {
        require(!((authorizedVoters[msg.sender].voteState == VotingState.UnAuthorized) || (authorizedVoters[msg.sender].voteState == VotingState.Voted)), "The address already voted or is not authorized!");
    _;
    }
    
    
    // Verified that address is not previous authorized or voted
    modifier voterNoRegistered(address _voter) {
        // Voter memory sender = authorizedVoters[_voter];
        require(!(authorizedVoters[_voter].voteState == VotingState.Authorized), "Already authorized!");        
        require(!(authorizedVoters[_voter].voteState == VotingState.Voted), "The address already voted!");
    _;
    }
    
    // Validate if the voting pool still open
    modifier isOpen() {
        require(block.timestamp < ballotClosingDate, "Voting is Closed!");
    _;
    }
    
    // Validate if the voting poll has finisihed
    modifier isClosed() {
        require(block.timestamp > ballotClosingDate, "Voting still open. can't calculate results yet!");
    _;
    }   
    
    // Validate if at least exist one vote
    modifier noEmpty() {
        require(CountTotalVotes > 0, "No votes in the voting pool, no results no show!");
    _;
    }       

    /* 
     * @dev Create the voting contract
     * @parameters daysOpen, candidateName1, candidateName2, candidateName3, candidateName4, candidateName5  
     *            daysOpen: Defines the number of days that ballot will be open after contract creation
     *            candidateName1: Name for the candidate 1
     *            candidateName2: Name for the candidate 2
     *            candidateName3: Name for the candidate 3
     *            candidateName4: Name for the candidate 4
     *            candidateName5: Name for the candidate 5
     */
    constructor(uint8 daysOpen, 
                string memory candidateName1,
                string memory candidateName2,
                string memory candidateName3,
                string memory candidateName4,
                string memory candidateName5                
                )  payable {
       
       //Initializate candidateNames
       candidateNames[0] = "Blank";       
       candidateNames[1] = candidateName1;
       candidateNames[2] = candidateName2;
       candidateNames[3] = candidateName3;
       candidateNames[4] = candidateName4;
       candidateNames[5] = candidateName5;
       
        // Assign the creator addres as the contract owner
        owner = msg.sender;
        daysAvailable = daysOpen;
        ballotCreationTime = block.timestamp;    
        ballotClosingDate = ballotCreationTime + daysAvailable * 1 days;
        
    }
    
    /** 
     * @dev Authorized the address provided to vote
     * @param _voter Voter addrress to authorize
     */
    function authorizeVoter(address _voter) public payable
        onlyOwner
        isOpen
        voterNoRegistered(_voter)
        {

        // Assing the voter to the list and authorize him/her to vote
        authorizedVoters[_voter].voteState = VotingState.Authorized;
    }


    /**
     * @dev vote function get the candidate Id - Must be a number in range (0,6)
     * @param _candidateId index of the candidate
     */
    function vote(uint8 _candidateId) public payable
        isOpen
        noVoted
        {
        
        // Update the voting info
        authorizedVoters[msg.sender].voteState = VotingState.Voted;
        authorizedVoters[msg.sender].vote = _candidateId;
        
        // Acumulate the voting counts
        countVoting[_candidateId] = countVoting[_candidateId] + 1;
        CountTotalVotes = CountTotalVotes + 1;
    }

    /**
     * @dev Function for terminate and close the voting poll
     */
    function finishVoting() public payable
        onlyOwner
        isOpen
        {
            
        // Set the closing to the actual timestamp    
        ballotClosingDate = block.timestamp;
    }


    /** 
     * @dev Calculate the winner for the voting poll using the rule:
     * At least 60% votes went for the same option and blank vote is less than 15% of the votes
     * @returns return the winner's name or a message for no results.
     */
    function getWinner() public 
        onlyOwner 
        isClosed
        noEmpty
        view
        returns (string memory winner_)
        {

        for (uint8 i = 1; i < 6; i++) {
            if ((countVoting[i] / CountTotalVotes )*100 >= 60 && (countVoting[0] / CountTotalVotes) * 100 <= 15){
                {
                        return candidateNames[i];
                }      
            }
        }
        return "No Winner for this voting poll";
    }

   // Function to review the contract balance
   function getBalance() public view returns(uint256){
      return address(this).balance;
   }


    // The fallback function is used to send back any payment done to this contract
    // Fallback is called when no message or specific function is called
    fallback() external payable {
        payable(msg.sender).transfer(msg.value);
    }
    
    // The receive function is called when some found is transfered to the contract
    // This function is called when a message and value is defined by the sender
    receive() external payable {
        payable(msg.sender).transfer(msg.value);
    }

}