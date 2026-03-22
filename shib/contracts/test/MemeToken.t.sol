// SPDX-License-Identifier: UNLICENSED
// 指定 Solidity 编译器版本
pragma solidity ^0.8.20;

// 引入测试基类
import {Test} from "forge-std/Test.sol";
// 引入待测试合约
import {MemeToken} from "../MemeToken.sol";

// MemeToken 合约测试
contract MemeTokenTest is Test {
  // 代币实例
  MemeToken token;
  // 税费地址
  address taxWallet = address(0xBEEF);
  // 普通用户地址
  address user = address(0xCAFE);
  address user2 = address(0xBABE);

  // 测试前置初始化
  function setUp() public {
    // 部署合约并设置初始参数
    token = new MemeToken(
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
  }

  // 初始发行量分配给部署者
  function test_InitialSupplyToOwner() public view {
    // 读取部署者余额
    uint256 ownerBalance = token.balanceOf(address(this));
    // 读取总发行量
    uint256 supply = token.totalSupply();
    // 校验余额等于总发行量
    require(ownerBalance == supply, "owner balance not equal to supply");
  }

  // 转账税费生效
  function test_TransferTaxApplied() public {
    // 取消部署者白名单
    token.setExempt(address(this), false);
    // 读取税费地址初始余额
    uint256 taxBefore = token.balanceOf(taxWallet);
    // 读取用户初始余额
    uint256 userBefore = token.balanceOf(user);
    // 发起转账
    token.transfer(user, 1_000 * 1e18);
    // 读取税费地址余额
    uint256 taxAfter = token.balanceOf(taxWallet);
    // 读取用户余额
    uint256 userAfter = token.balanceOf(user);
    // 校验税费增加 1%
    require(taxAfter - taxBefore == 10 * 1e18, "tax not applied");
    // 校验用户实际到账 99%
    require(userAfter - userBefore == 990 * 1e18, "receive amount error");
  }

  // 最大交易额度限制
  function test_MaxTxLimit() public {
    // 取消部署者白名单
    token.setExempt(address(this), false);
    // 设置较小的最大交易额度
    token.setLimits(100 * 1e18, 1_000_000 * 1e18, 0);
    // 预期触发最大交易额度错误
    vm.expectRevert(bytes("max tx exceeded"));
    // 发起超过限制的转账
    token.transfer(user, 101 * 1e18);
  }

// 授权成功
  function test_approve() public {
    bool res = token.approve(user, 1000);
    require(res, "approve fail");
    uint256 amount = token.allowance(address(this), user);
    require(amount == 1000, "approve amount should equals to 1000");
  }

  function test_transferFrom() public {
    vm.expectRevert(bytes("allowance not enough"));
    token.transferFrom(user, user2, 10);
  }
}