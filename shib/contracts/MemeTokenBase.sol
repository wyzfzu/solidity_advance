// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

contract MemeTokenBase {
    // 代币名称
    string public name;
    // 代币符号
    string public symbol;
    // 小数位数
    uint8 public decimals;
    // 总发行量
    uint256 public totalSupply;

    // 合约所有者
    address public owner;
    // 税费接收地址
    address public taxWallet;
    // 路由器地址
    address public router;
    // 交易对地址
    address public pair;

    // 买入税费（bps）
    uint256 public buyTaxBps;
    // 卖出税费（bps）
    uint256 public sellTaxBps;
    // 转账税费（bps）
    uint256 public transferTaxBps;

    // 单笔最大交易额
    uint256 public maxTxAmount;
    // 最大持仓额度
    uint256 public maxWalletAmount;
    // 冷却时间（秒）
    uint256 public cooldownSeconds;

    // 账户余额
    mapping(address => uint256) public balanceOf;
    // 授权额度
    mapping(address => mapping(address => uint256)) public allowance;
    // 上次交易时间
    mapping(address => uint256) public lastTradeTime;
    // 免税/免限制白名单
    mapping(address => bool) public isExempt;

    // 转账事件
    event Transfer(address indexed from, address indexed to, uint256 value);
    // 授权事件
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    // 税率更新事件
    event TaxRatesUpdated(uint256 buyBps, uint256 sellBps, uint256 transferBps);
    // 限制参数更新事件
    event LimitsUpdated(
        uint256 maxTxAmount,
        uint256 maxWalletAmount,
        uint256 cooldownSeconds
    );
    // 税费地址更新事件
    event TaxWalletUpdated(
        address indexed oldWallet,
        address indexed newWallet
    );
    // 路由器更新事件
    event RouterUpdated(address indexed router);
    // 交易对更新事件
    event PairUpdated(address indexed pair);
    // 白名单更新事件
    event ExemptUpdated(address indexed account, bool isExempt);
    // 所有权转移事件
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    // 仅允许合约所有者调用
    modifier onlyOwner() {
        // 校验调用者是否为所有者
        _onlyOwner();
        // 继续执行后续逻辑
        _;
    }

    function _onlyOwner() internal view {
        require(msg.sender == owner, "only owner");
    }
    // 构造函数：初始化代币与参数
    constructor(
        // 代币名称参数
        string memory name_,
        // 代币符号参数
        string memory symbol_,
        // 小数位参数
        uint8 decimals_,
        // 总发行量参数
        uint256 totalSupply_,
        // 税费接收地址参数
        address taxWallet_,
        // 买入税率参数（bps）
        uint256 buyTaxBps_,
        // 卖出税率参数（bps）
        uint256 sellTaxBps_,
        // 转账税率参数（bps）
        uint256 transferTaxBps_,
        // 单笔最大交易额参数
        uint256 maxTxAmount_,
        // 最大持仓额度参数
        uint256 maxWalletAmount_,
        // 冷却时间参数（秒）
        uint256 cooldownSeconds_
    ) {
        // 设置代币名称
        name = name_;
        // 设置代币符号
        symbol = symbol_;
        // 设置小数位
        decimals = decimals_;
        // 设置总发行量
        totalSupply = totalSupply_;
        // 设置合约所有者
        owner = msg.sender;
        // 设置税费接收地址
        taxWallet = taxWallet_;
        // 设置买入税率
        buyTaxBps = buyTaxBps_;
        // 设置卖出税率
        sellTaxBps = sellTaxBps_;
        // 设置转账税率
        transferTaxBps = transferTaxBps_;
        // 设置单笔最大交易额
        maxTxAmount = maxTxAmount_;
        // 设置最大持仓额度
        maxWalletAmount = maxWalletAmount_;
        // 设置冷却时间
        cooldownSeconds = cooldownSeconds_;

        // 将初始发行量分配给所有者
        balanceOf[owner] = totalSupply_;
        // 所有者免税免限制
        isExempt[owner] = true;
        // 税费地址免税免限制
        isExempt[taxWallet_] = true;

        // 触发初始铸币转账事件
        emit Transfer(address(0), owner, totalSupply_);
    }

    // 转账函数
    function transfer(
        // 接收地址
        address to,
        // 转账数量
        uint256 amount
    ) external returns (bool) {
        // 调用内部转账逻辑
        _transfer(msg.sender, to, amount);
        // 返回执行成功
        return true;
    }

    // 授权函数
    function approve(
        // 授权地址
        address spender,
        // 授权数量
        uint256 amount
    ) external returns (bool) {
        // 设置授权额度
        allowance[msg.sender][spender] = amount;
        // 触发授权事件
        emit Approval(msg.sender, spender, amount);
        // 返回执行成功
        return true;
    }

    // 授权转账函数
    function transferFrom(
        // 转出地址
        address from,
        // 接收地址
        address to,
        // 转账数量
        uint256 amount
    ) external returns (bool) {
        // 获取当前授权额度
        uint256 currentAllowance = allowance[from][msg.sender];
        // 校验授权额度是否足够
        require(currentAllowance >= amount, "allowance not enough");
        // 扣减授权额度
        allowance[from][msg.sender] = currentAllowance - amount;
        // 执行转账逻辑
        _transfer(from, to, amount);
        // 返回执行成功
        return true;
    }

    // 内部转账逻辑
    function _transfer(
        // 转出地址
        address from,
        // 接收地址
        address to,
        // 转账数量
        uint256 amount
    ) internal {
        // 校验转出地址合法
        require(from != address(0), "from zero");
        // 校验转入地址合法
        require(to != address(0), "to zero");
        // 校验余额是否足够
        require(balanceOf[from] >= amount, "balance not enough");

        // 判断是否需要执行限制与税费逻辑
        bool takeRules = !(isExempt[from] || isExempt[to]);
        // 记录实际到账金额
        uint256 receiveAmount = amount;

        if (takeRules) {
            // 校验单笔最大交易额
            require(amount <= maxTxAmount, "max tx exceeded");
            // 校验最大持仓额度
            require(
                balanceOf[to] + amount <= maxWalletAmount,
                "max wallet exceeded"
            );

            // 校验冷却时间（对交易双方生效）
            require(
                block.timestamp >= lastTradeTime[from] + cooldownSeconds,
                "from cooldown"
            );
            require(
                block.timestamp >= lastTradeTime[to] + cooldownSeconds,
                "to cooldown"
            );

            // 记录本次交易时间
            lastTradeTime[from] = block.timestamp;
            lastTradeTime[to] = block.timestamp;

            // 计算税率（bps）
            uint256 taxBps = transferTaxBps;
            // 买入：from 为交易对
            if (from == pair) {
                taxBps = buyTaxBps;
            }
            // 卖出：to 为交易对
            if (to == pair) {
                taxBps = sellTaxBps;
            }

            // 计算税费金额
            uint256 taxAmount = (amount * taxBps) / 10000;
            // 计算实际到账金额
            receiveAmount = amount - taxAmount;

            // 将税费转入税费地址
            if (taxAmount > 0) {
                balanceOf[taxWallet] += taxAmount;
                emit Transfer(from, taxWallet, taxAmount);
            }
        }

        // 扣减转出账户余额
        balanceOf[from] -= amount;
        // 增加转入账户余额
        balanceOf[to] += receiveAmount;
        // 触发转账事件
        emit Transfer(from, to, receiveAmount);
    }
}
