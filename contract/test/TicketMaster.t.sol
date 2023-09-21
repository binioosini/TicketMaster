// SPDX-License-Identifier: MIT License
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {TicketMaster} from "../src/TicketMaster.sol";

contract TicketMasterTest is Test {
    TicketMaster public ticketMaster;
    address public owner;
    address public user1;
    address public user2;
    
    function setUp() public {
        owner = msg.sender;
        user1 = address(0x1);
        user2 = address(0x2);

        // Deploy TicketMaster contract
        ticketMaster = new TicketMaster("TicketMaster", "TM");
    }

    function testListFunction() public {
        vm.prank(owner);
        ticketMaster.list(1 ether, 10, "Event 1", "http://image.com/event1", "2023-09-30", "12:00:00", "Description 1", "Location 1");

        TicketMaster.Occasion memory occasion = ticketMaster.getOccasion(1);

        assertEq(occasion.owner, owner);
        assertEq(occasion.id, 1);
        assertEq(occasion.cost, 1 ether);
        assertEq(occasion.tickets, 10);
        assertEq(occasion.maxTickets, 10);
        assertEq(occasion.name, "Event 1");
        assertEq(occasion.imgUrl, "http://image.com/event1");
        assertEq(occasion.date, "2023-09-30");
        assertEq(occasion.time, "12:00:00");
        assertEq(occasion.description, "Description 1");
        assertEq(occasion.location, "Location 1");
    }

    function testMintFunction() public {
        // List an occasion
        vm.prank(user2);
        ticketMaster.list(1 ether, 10, "Event 1", "http://image.com/event1", "2023-09-30", "12:00:00", "Description 1", "Location 1");
        
        vm.deal(user1, 2 ether);
        vm.prank(user1);

        // Mint a ticket for the occasion
        uint256 occasionId = 1;
        uint256 seat = 0;
        uint256 ticketCost = 1 ether;

        // Check user1's balance before minting
        uint256 initialUser1Balance = address(user1).balance;
        console.log("initial user1 balance: " , initialUser1Balance);
        // Mint a ticket for user1
        ticketMaster.mint{value: ticketCost}(occasionId, seat);

        // Check user1's balance after minting
        uint256 finalUser1Balance = address(user1).balance;

        // Check if the minted NFT belongs to user1
        uint256 tokenId = ticketMaster.totalSupply();
        assertEq(ticketMaster.ownerOf(tokenId), user1);

        // Check if the occasion's ticket count was updated
        assertEq(ticketMaster.getOccasion(occasionId).tickets, 9);

        // Check if user1 has bought a ticket for the occasion
        assertEq(ticketMaster.hasBought(occasionId, user1), true);

        // Check if the seat was assigned to user1
        assertEq(ticketMaster.seatTaken(occasionId, seat), user1);

        // Check if user1's balance decreased by the ticket cost
        assertEq(finalUser1Balance, initialUser1Balance - ticketCost);
    }
}
