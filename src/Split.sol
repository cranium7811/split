// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import {ERC20} from "solmate/tokens/ERC20.sol";
import {ERC721} from "solmate/tokens/ERC721.sol";

contract Split is ERC721{

    /// @notice id of the NFT
    uint256 public id;

    /// @notice total supply of the NFT
    uint256 public totalSupply;

    /// @notice address of the account deploying this contract
    address public owner;

    /// @notice address of the ERC20 contract
    address public stake;

    /// @notice array of all the key stake holders (atleast 100,000 $STAKE)
    address[] public stakeHolders;

    /// @dev `owner` is the address deploying this contract
    /// @param _stake address of the ERC20 contract
    /// @param _name name of the NFT
    /// @param _symbol symbol of the NFT
    /// @param _totalSupply total supply of the NFT
    constructor(
        address _stake,
        string memory _name,
        string memory _symbol,
        uint256 _totalSupply
    ) ERC721(_name, _symbol) {
        owner = msg.sender;
        stake = _stake;
        totalSupply = _totalSupply;
    }

    /// @dev overriding this function to make this contract non-abstract
    function tokenURI(uint256 _id) public view override returns (string memory){}

    /// @notice Get the number of holders whose balance of $STAKE is atleast 100,000
    /// @dev run `callKeyStakeHolders` script to get all the stake holders and input as argument
    /// @param _stakeHolders array of all the key stake holders (atleast 100,000)
    function getKeyStakeHolders(address[] calldata _stakeHolders) public {
        require(msg.sender == owner, "NOT_OWNER");
        stakeHolders = _stakeHolders;
    }

    /// @notice Split the ETH in this contract equally among the stakeholders
    /// @dev run `callKeyStakeHolders` script before this function
    /// @dev any stakeHolder can call the function
    function splitETH() public {
        require(ERC20(stake).balanceOf(msg.sender) >= 1e23, "NOT_APPLICABLE");

        // reverts if _stakeHolders.length = 0
        uint256 amount = address(this).balance / stakeHolders.length;

        // transfer `amount` to all the stakeHolders
        for (uint256 i; i < stakeHolders.length;) {
            payable(stakeHolders[i]).transfer(amount);

            // Gas savings
            unchecked {
                ++i;
            }
        }
    }

    /// @notice Minimal implementation to mint a particular number of tokens
    /// @dev if _numberOfTokens is more than the remaining tokens, remaining is minted and the rest is reverted
    /// @param _numberOfTokens number of tokens to mint
    function mint(uint256 _numberOfTokens) public payable {
        // assume minimum 0.05 eth per mint
        require(msg.value >= 5e16 * _numberOfTokens, "0.05_ETH");
        
        uint256 numberOfTokens = _numberOfTokens;

        // Check remaining tokens
        if(id + _numberOfTokens > totalSupply) numberOfTokens = totalSupply - id; 

        for (uint256 i; i < numberOfTokens;) {
            // id < totalSupply check notrequired here
            // safeMint `id` to msg.sender
            _safeMint(msg.sender, id);

            // Gas savings
            unchecked {
                ++i;
                ++id;
            }
        }

        // Refund remaining value if sent more
        payable(msg.sender).transfer(msg.value - (5e16 * numberOfTokens));
    }

    /// @notice Minimal implementation to burn a particular id
    /// @param _id token id to be burned
    function burn(uint256 _id) public {
        require(msg.sender == this.ownerOf(_id), "NOT_OWNER_OF_TOKEN");

        _burn(_id);
    }
}
