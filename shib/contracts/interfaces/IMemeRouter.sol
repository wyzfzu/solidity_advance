// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.20;

interface IMemeRouter {
    function addLqETH(
        // 代币合约地址
        address token,
        // 期望投入的代币数量
        uint256 amountTokenDesired,
        // 可接受的最低的代币数量
        uint256 amountTokenMin,
        // 可接受的最低的ETH数量
        uint256 amountETHMin,
        // 接收LP代币的地址
        address to,
        // 交易过期时间戳
        uint256 deadline
    ) external payable returns(
        // 实际添加的代币数量
        uint256 amountToken, 
        // 实际添加的ETH数量
        uint256 amountETH, 
        // LP代币数量
        uint liquidity
    );
    
    function removeLqETH(
        // 代币合约地址
        address token,
        // 要移除的LP代币数量
        uint256 liquidity,
        // 可接受的最低的代币数量
        uint amountTokenMin,
        // 可接受的最低的ETH数量
        uint amountETHMin,
        // 接收代币和ETH的地址
        address to,
        // 交易过期时间戳
        uint deadline
    ) external returns(
        // 实际取回的代币数量
        uint amountToken,
        // 实际取回的ETH数量 
        uint amountETH
    );
}