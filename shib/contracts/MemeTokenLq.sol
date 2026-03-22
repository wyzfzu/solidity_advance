// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import {MemeTokenOwnerOp} from "./MemeTokenOwnerOp.sol";
import {IMemeRouter} from "./interfaces/IMemeRouter.sol";

// Meme 代币流动性功能
abstract contract MemeTokenLq is MemeTokenOwnerOp, ReentrancyGuard {
  // 添加流动性（ETH 版本）
  function addLqETH(
    // 期望投入的代币数量
    uint256 amountTokenDesired,
    // 最低接受的代币数量
    uint256 amountTokenMin,
    // 最低接受的 ETH 数量
    uint256 amountETHMin,
    // 交易过期时间戳
    uint256 deadline
  )
    external
    payable
    onlyOwner
    nonReentrant
    returns (
      // 实际添加的代币数量
      uint256 amountToken,
      // 实际添加的 ETH 数量
      uint256 amountETH,
      // 铸造的 LP 代币数量
      uint256 liquidity
    )
  {
    // 校验路由器是否设置
    require(router != address(0), "router not set");
    // 校验交易对是否设置
    require(pair != address(0), "pair not set");

    // 将代币从调用者转入合约
    _transfer(msg.sender, address(this), amountTokenDesired);
    // 授权路由器使用代币
    allowance[address(this)][router] = amountTokenDesired;

    // 调用路由器添加流动性
    (amountToken, amountETH, liquidity) = IMemeRouter(router).addLqETH{value: msg.value}(
        address(this),
        amountTokenDesired,
        amountTokenMin,
        amountETHMin,
        msg.sender,
        deadline
      );

      emit Approval(address(this), router, amountTokenDesired);
  }

  // 移除流动性（ETH 版本）
  function removeLqETH(
    // 要移除的 LP 代币数量
    uint256 liquidity,
    // 最低接受的代币数量
    uint256 amountTokenMin,
    // 最低接受的 ETH 数量
    uint256 amountETHMin,
    // 交易过期时间戳
    uint256 deadline
  )
    external
    onlyOwner
    nonReentrant
    returns (
      // 实际取回的代币数量
      uint256 amountToken,
      // 实际取回的 ETH 数量
      uint256 amountETH
    )
  {
    // 校验路由器是否设置
    require(router != address(0), "router not set");
    // 校验交易对是否设置
    require(pair != address(0), "pair not set");

    // 调用路由器移除流动性
    (amountToken, amountETH) =  IMemeRouter(router).removeLqETH(
        address(this),
        liquidity,
        amountTokenMin,
        amountETHMin,
        msg.sender,
        deadline
      );
  }
}