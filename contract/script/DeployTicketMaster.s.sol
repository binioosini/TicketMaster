// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {TicketMaster} from "../src/TicketMaster.sol";

contract DeployTicketMaster is Script {
    function run() external returns (TicketMaster, HelperConfig) {
        TicketMaster ticketMaster;
        HelperConfig helperConfig;
        
        helperConfig = new HelperConfig(); 
        (
            string memory name,
            string memory symbol,
            uint256 deployerKey
        ) = helperConfig.activeNetworkConfig();

        vm.startBroadcast(deployerKey);
        ticketMaster = new TicketMaster (
            name,
            symbol
        );
        vm.stopBroadcast();

        return (ticketMaster, helperConfig);
    }
}