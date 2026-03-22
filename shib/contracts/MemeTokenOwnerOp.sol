// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import {MemeTokenBase} from "./MemeTokenBase.sol";

abstract contract MemeTokenOwnerOp is MemeTokenBase {
    // 设置税率参数
  function setTaxRates(
    // 买入税率（bps）
    uint256 buyBps,
    // 卖出税率（bps）
    uint256 sellBps,
    // 转账税率（bps）
    uint256 transferBps
  ) external onlyOwner {
    // 更新买入税率
    buyTaxBps = buyBps;
    // 更新卖出税率
    sellTaxBps = sellBps;
    // 更新转账税率
    transferTaxBps = transferBps;
    // 触发税率更新事件
    emit TaxRatesUpdated(buyBps, sellBps, transferBps);
  }

  // 设置限制参数
  function setLimits(
    // 单笔最大交易额
    uint256 maxTx,
    // 最大持仓额度
    uint256 maxWallet,
    // 冷却时间（秒）
    uint256 cooldown
  ) external onlyOwner {
    // 更新单笔最大交易额
    maxTxAmount = maxTx;
    // 更新最大持仓额度
    maxWalletAmount = maxWallet;
    // 更新冷却时间
    cooldownSeconds = cooldown;
    // 触发限制更新事件
    emit LimitsUpdated(maxTx, maxWallet, cooldown);
  }

  // 设置税费接收地址
  function setTaxWallet(
    // 新税费地址
    address newTaxWallet
  ) external onlyOwner {
    // 校验新地址合法
    require(newTaxWallet != address(0), "tax wallet zero");
    // 记录旧地址
    address oldWallet = taxWallet;
    // 更新税费地址
    taxWallet = newTaxWallet;
    // 将新地址加入白名单
    isExempt[newTaxWallet] = true;
    // 触发税费地址更新事件
    emit TaxWalletUpdated(oldWallet, newTaxWallet);
  }

  // 设置路由器地址
  function setRouter(
    // 新路由器地址
    address newRouter
  ) external onlyOwner {
    // 校验新地址合法
    require(newRouter != address(0), "router zero");
    // 更新路由器地址
    router = newRouter;
    // 触发路由器更新事件
    emit RouterUpdated(newRouter);
  }

  // 设置交易对地址
  function setPair(
    // 新交易对地址
    address newPair
  ) external onlyOwner {
    // 校验新地址合法
    require(newPair != address(0), "pair zero");
    // 更新交易对地址
    pair = newPair;
    // 触发交易对更新事件
    emit PairUpdated(newPair);
  }

  // 设置白名单
  function setExempt(
    // 目标地址
    address account,
    // 是否免税免限制
    bool exempt
  ) external onlyOwner {
    // 校验地址合法
    require(account != address(0), "account zero");
    // 更新白名单状态
    isExempt[account] = exempt;
    // 触发白名单更新事件
    emit ExemptUpdated(account, exempt);
  }

  // 转移所有权
  function transferOwnership(
    // 新所有者地址
    address newOwner
  ) external onlyOwner {
    // 校验新所有者地址合法
    require(newOwner != address(0), "new owner zero");
    // 记录旧所有者
    address previousOwner = owner;
    // 更新所有者地址
    owner = newOwner;
    // 新所有者加入白名单
    isExempt[newOwner] = true;
    // 触发所有权转移事件
    emit OwnershipTransferred(previousOwner, newOwner);
  }

  // 放弃所有权
  function renounceOwnership() external onlyOwner {
    // 记录旧所有者
    address previousOwner = owner;
    // 清空所有者地址
    owner = address(0);
    // 触发所有权转移事件
    emit OwnershipTransferred(previousOwner, address(0));
  }
}