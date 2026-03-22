## 理论知识梳理
[理论知识](./theory/理论知识梳理.md)

## Meme

### 结构

代码都在shib目录下

#### 源码
- `IMemeRouter` 路由接口
- `MemeTokenBase` 事件和字段定义
- `MemeTokenOwnerOp` 所有者操作的接口
- `MemeTokenLq` 流动性相关操作
- `MemeToken` 代币
  
#### 测试代码
- `MemeToken.t` foundry测试类
  
#### 部署脚本
- `DeployMemeToken.s.sol` 部署的脚本


### 构建

```shell
$ forge build
```

### 测试
```shell
$ forge test
```

### 部署
```shell
$ source .env
$ forge script shib/scripts/DeployMemeToken.s.sol:DeployMemeToken \
  --rpc-url $SEPOLIA_RPC_URL \
  --chain-id 11155111 \
  --verify \
  --etherscan-api-key $ETHERSCAN_API_KEY \
  --broadcast
```
