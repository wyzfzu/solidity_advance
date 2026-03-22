// SPDX-License-Identifier: UNLICENSED
// 指定 Solidity 编译器版本
pragma solidity ^0.8.20;

// 引入测试基类
import {Script} from "forge-std/Script.sol";
import "forge-std/console2.sol";
import {MemeToken} from "../contracts/MemeToken.sol";

contract DeployMemeToken is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        // 税费地址
        address taxWallet = address(0xBEEF);

        // 部署合约并设置初始参数
        MemeToken token = new MemeToken(
            "Meme Token",
            "MEME",
            18,
            1_000_000 * 1e18,
            taxWallet,
            0,
            0,
            100,
            1_000_000 * 1e18,
            1_000_000 * 1e18,
            0
        );
        console2.log("Token deployed at:", address(token));

        vm.stopBroadcast();
    }
}
