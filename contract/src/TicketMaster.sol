// SPDX-License-Identifier: MIT License
pragma solidity ^0.8.13;

/**
 * @title TicketMaster: A contract for listing and selling event tickets.
 * @author Al zubair khalaf <binioosini@gmail.com>
 * @notice This contract allows the owner to list occasions and users to purchase tickets.
 */

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract TicketMaster is ERC721 {
    uint256 public totalOccasions; // Total number of occasions listed
    uint256 public totalSupply; // Total number of tickets sold

    error notTheOwner();
    error idMustBeMoreThanZero();
    error ethSentIsLessThanTheCost();
    error seatIsTaken();
    error seatIsNotExist();
    error faildToSendETHtoTheOccasionsOwner();

    struct Occasion {
        address owner;
        uint256 id;
        uint256 cost;
        uint256 tickets;
        uint256 maxTickets;
        string name;
        string imgUrl;
        string date;
        string time;
        string description;
        string location;
    }

    mapping(uint256 => Occasion) occasions; // Mapping from occasion ID to Occasion struct
    mapping(uint256 => mapping(address => bool)) public hasBought; // Mapping to track if a user has bought a ticket for an occasion
    mapping(uint256 => mapping(uint256 => address)) public seatTaken; // Mapping to track which address occupies a seat for an occasion
    mapping(uint256 => uint256[]) seatsTaken; // Mapping to track seats that are currently taken for an occasion

    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {}

    function list(
        uint256 _cost,
        uint256 _maxTickets,
        string memory _name,
        string memory _imgUrl,
        string memory _date,
        string memory _time,
        string memory _description,
        string memory _location
    ) public {
        totalOccasions++;
        occasions[totalOccasions] = Occasion(
            msg.sender,
            totalOccasions,
            _cost,
            _maxTickets,
            _maxTickets,
            _name,
            _imgUrl,
            _date,
            _time,
            _description,
            _location
        );
    }

    // Mint a ticket for an occasion and assign a seat
    function mint(uint256 _id, uint256 _seat) public payable {
        uint256 amount = occasions[_id].cost;

        if (_id <= 0) {
            revert idMustBeMoreThanZero();
        }

        if (msg.value < amount) {
            revert ethSentIsLessThanTheCost();
        }

        if (seatTaken[_id][_seat] != address(0)) {
            revert seatIsTaken();
        }

        if (_seat >= occasions[_id].maxTickets) {
            revert seatIsNotExist();
        }

        // Send ETH to the occasion owner
        (bool sent,) = payable(occasions[_id].owner).call{value: amount}("");
        if (!sent) {
            revert faildToSendETHtoTheOccasionsOwner();
        }

        occasions[_id].tickets--; // Update ticket count
        hasBought[_id][msg.sender] = true; // Update buying status
        seatTaken[_id][_seat] = msg.sender; // Assign seat
        seatsTaken[_id].push(_seat); // Update seats currently taken
        totalSupply++;

        _safeMint(msg.sender, totalSupply);
    }

    function getOccasion(uint256 _id) public view returns (Occasion memory) {
        return occasions[_id];
    }

    function getSeatsTaken(uint256 _id) public view returns (uint256[] memory) {
        return seatsTaken[_id];
    }
}
