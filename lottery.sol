// SPDX-License-Identifier: MIT
/**
   * @title ContractName
   * @dev ContractDescription
   * @custom:dev-run-script file_path
   */

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract LotteryNFT is ERC721 {
    uint256 public tokenId;

    constructor() ERC721("Lottery NFT", "LNFT") {}

    function mint(address to) public {
        tokenId += 1;
        _mint(to, tokenId);
    }
}

contract Lottery {
    address payable[] public players;
    address public manager;
    address public systemAccount;
    ERC20 public stablecoin;
    LotteryNFT public lotteryNFT;

    uint256 constant TICKET_PRICE = 10 * 10**18; // Assuming stablecoin has 18 decimals
    uint256 constant NUMBER_OF_TICKETS = 10;

    constructor(address _stablecoin, address _systemAccount) {
        manager = msg.sender;
        systemAccount = _systemAccount;
        stablecoin = ERC20(_stablecoin);
        lotteryNFT = new LotteryNFT();
    }

    function enter() public {
        stablecoin.transferFrom(msg.sender, address(this), TICKET_PRICE);
        lotteryNFT.mint(msg.sender);
        players.push(payable(msg.sender));

        if (players.length == NUMBER_OF_TICKETS) {
            pickWinner();
        }
    }

    function pickWinner() private {
        require(players.length == NUMBER_OF_TICKETS, "Not enough players");

        uint256 winnerIndex = random() % NUMBER_OF_TICKETS;
        uint256 winnings = TICKET_PRICE * NUMBER_OF_TICKETS * 90 / 100;
        uint256 systemFee = TICKET_PRICE * NUMBER_OF_TICKETS * 10 / 100;

        stablecoin.transfer(players[winnerIndex], winnings);
        stablecoin.transfer(payable(systemAccount), systemFee);

        players = new address payable[](0);
    }

    function random() private view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp, players)));
    }
}
