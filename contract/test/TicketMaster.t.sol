// SPDX-License-Identifier: MIT License
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {TicketMaster} from "../src/TicketMaster.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";

contract TicketMasterTest is Test {
    TicketMaster public ticketMaster;
    HelperConfig public helperConfig;

    address public user1;
    address public user2;
    string public name;
    string public symbol;

    function setUp() public {
        user1 = address(0x1);
        user2 = address(0x2);

        helperConfig = new HelperConfig();
        (name, symbol, ) = helperConfig.activeNetworkConfig();
        // Deploy TicketMaster contract
        ticketMaster = new TicketMaster(name, symbol);
        
        // list an occasion 
        vm.prank(user2);
        ticketMaster.list(
        1 ether, 
        10, 
        "Event 1", 
        "http://image.com/event1", 
        "2023-10-15", 
        "12:00:00", 
        "Description 1", 
        "Location 1"
        );

    }

    function testGetOccasionFunction() public {
        TicketMaster.Occasion memory occasion = ticketMaster.getOccasion(1);

        assertEq(occasion.owner, user2);
        assertEq(occasion.id, 1);
        assertEq(occasion.cost, 1 ether);
        assertEq(occasion.tickets, 10);
        assertEq(occasion.maxTickets, 10);
        assertEq(occasion.name, "Event 1");
        assertEq(occasion.imgUrl, "http://image.com/event1");
        assertEq(occasion.date, "2023-10-15");
        assertEq(occasion.time, "12:00:00");
        assertEq(occasion.description, "Description 1");
        assertEq(occasion.location, "Location 1");
    }

    function testMintFunction() public {
        
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
        console.log("final User1 Balance: " , finalUser1Balance);
        // Check if the minted NFT belongs to user1
        uint256 tokenId = ticketMaster.totalSupply();
        console.log("token Id: " , tokenId);
        assertEq(ticketMaster.ownerOf(tokenId), user1);
        address newOwner = ticketMaster.ownerOf(tokenId);
        console.log("owner Of the token: " , newOwner);

        // Check if the occasion's ticket count was updated
        assertEq(ticketMaster.getOccasion(occasionId).tickets, 9);

        // Check if user1 has bought a ticket for the occasion
        assertEq(ticketMaster.hasBought(occasionId, user1), true);

        // Check if the seat was assigned to user1
        assertEq(ticketMaster.seatTaken(occasionId, seat), user1);

        // Check if user1's balance decreased by the ticket cost
        assertEq(finalUser1Balance, initialUser1Balance - ticketCost);
    }

    function testRevertidMustBeMoreThanZero() public {
        vm.deal(user1, 2 ether);
        vm.prank(user1);

        uint256 occasionId = 0;
        uint256 seatNum =1;

        // 1. Attempt to mint with an invalid occasion ID (0)
        vm.expectRevert(TicketMaster.idMustBeMoreThanZero.selector);
        ticketMaster.mint{value: 1 ether}(occasionId, seatNum);
    }

    function testRevertEthSentIsLessThanTheCost() public {
        vm.deal(user1, 2 ether);
        vm.prank(user1);

        uint256 occasionId = 1;
        uint256 seatNum =2;

        // 2. Attempt to mint without sending enough ether
        vm.expectRevert(TicketMaster.ethSentIsLessThanTheCost.selector);
        ticketMaster.mint{value: 0.5 ether}(occasionId, seatNum);

    }

    function testRevertSeatIsTaken() public {
        vm.deal(user1, 2 ether);
        vm.prank(user1);

        uint256 occasionId = 1;
        uint256 seatNum =1;

        // 3. Attempt to mint a seat that is already taken
        ticketMaster.mint{value: 1 ether}(occasionId, seatNum); // Mint a ticket for seat 1
        vm.expectRevert(TicketMaster.seatIsTaken.selector);
        ticketMaster.mint{value: 1 ether}(occasionId, seatNum); // Attempt to mint another ticket for the same seat

    }  

    function testRevertSeatIsNotExist() public {
        vm.deal(user1, 2 ether);
        vm.prank(user1);

        uint256 occasionId = 1;
        uint256 seatNum =12;

        // 4. Attempt to mint a ticket for a non-existent seat
        vm.expectRevert(TicketMaster.seatIsNotExist.selector);
        ticketMaster.mint{value: 1 ether}(occasionId, seatNum); // Attempt to mint a ticket for seat 11

    }

    function testGetOccasion() public {
        uint256 occasionId = 1;
        TicketMaster.Occasion memory occasion = ticketMaster.getOccasion(occasionId);

        assertEq(occasion.owner, user2);
        assertEq(occasion.id, 1);
        assertEq(occasion.cost, 1 ether);
        assertEq(occasion.tickets, 10);
        assertEq(occasion.maxTickets, 10);
        assertEq(occasion.name, "Event 1");
        assertEq(occasion.imgUrl, "http://image.com/event1");
        assertEq(occasion.date, "2023-10-15");
        assertEq(occasion.time, "12:00:00");
        assertEq(occasion.description, "Description 1");
        assertEq(occasion.location, "Location 1");
    }
    
    function testGetSeatsTaken() public {
        vm.deal(user1, 2 ether);
        vm.prank(user1);
        
        uint256 occasionId = 1;
        uint256 seat = 2;
        // Mint a ticket
        ticketMaster.mint{value: 1 ether}(occasionId, seat);
        // Call the getSeatsTaken() function and check if the returned seat matches the minted seat
        uint256[] memory seats = ticketMaster.getSeatsTaken(occasionId);
        assert(seats.length == 1); // Expected one seat taken
        assert(seats[0] == seat); // Expected seat to match the minted seat
    }

        
    

}
