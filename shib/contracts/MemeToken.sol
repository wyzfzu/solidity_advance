// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import {MemeTokenLq} from "./MemeTokenLq.sol";
import {MemeTokenBase} from "./MemeTokenBase.sol";

// Meme 代币合约
contract MemeToken is MemeTokenLq {
  constructor(
    // 代币名称
    string memory name_,
    // 代币符号
    string memory symbol_,
    // 小数位
    uint8 decimals_,
    // 总发行量
    uint256 totalSupply_,
    // 税费接收地址
    address taxWallet_,
    // 买入税率（bps）
    uint256 buyTaxBps_,
    // 卖出税率（bps）
    uint256 sellTaxBps_,
    // 转账税率（bps）
    uint256 transferTaxBps_,
    // 单笔最大交易额
    uint256 maxTxAmount_,
    // 最大持仓额度
    uint256 maxWalletAmount_,
    // 冷却时间（秒）
    uint256 cooldownSeconds_
  )
    MemeTokenBase(
      name_,
      symbol_,
      decimals_,
      totalSupply_,
      taxWallet_,
      buyTaxBps_,
      sellTaxBps_,
      transferTaxBps_,
      maxTxAmount_,
      maxWalletAmount_,
      cooldownSeconds_
    )
  {}
}