// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title 极简多签钱包
 * @dev 实现逻辑：链下收集签名，链上一次性验证并执行。
 */
contract MultisigWallet {
    // --- 事件 ---
    event ExecutionSuccess(bytes32 txHash);
    event ExecutionFailure(bytes32 txHash);

    // --- 状态变量 ---
    address[] public owners; // 多签持有人数组
    mapping(address => bool) public isOwner; // 快速检查是否为持有人
    uint256 public ownerCount; // 持有人总数
    uint256 public threshold; // 执行门槛 (至少需要 n 个签名)
    uint256 public nonce; // 防止重放攻击

    // --- 构造函数 ---
    constructor(address[] memory _owners, uint256 _threshold) {
        _setupOwners(_owners, _threshold);
    }

    // --- 内部初始化函数 ---
    function _setupOwners(
        address[] memory _owners,
        uint256 _threshold
    ) internal {
        require(threshold == 0, "Already initialized");
        require(_threshold <= _owners.length, "Threshold exceeds owner count");
        require(_threshold >= 1, "Threshold must be at least 1");

        for (uint256 i = 0; i < _owners.length; i++) {
            address owner = _owners[i];
            // 检查：非零地址、非合约自身、地址不重复
            require(
                owner != address(0) &&
                    owner != address(this) &&
                    !isOwner[owner],
                "Invalid or duplicate owner"
            );
            owners.push(owner);
            isOwner[owner] = true;
        }
        ownerCount = _owners.length;
        threshold = _threshold;
    }

    /**
     * @dev 执行交易的主函数
     * @param signatures 打包好的签名数据，要求签名人的地址按升序排列
     */
    function execTransaction(
        address to,
        uint256 value,
        bytes memory data,
        bytes memory signatures
    ) public payable returns (bool success) {
        // 1. 编码交易并生成哈希
        bytes32 txHash = encodeTransactionData(
            to,
            value,
            data,
            nonce,
            block.chainid
        );

        // 2. 增加 nonce，防止该哈希被再次使用
        nonce++;

        // 3. 检查签名是否有效且达到门槛
        checkSignatures(txHash, signatures);

        // 4. 利用 call 执行交易
        (success, ) = to.call{value: value}(data);

        if (success) {
            emit ExecutionSuccess(txHash);
        } else {
            emit ExecutionFailure(txHash);
            // 注意：如果执行失败，nonce 已经增加，该笔签名失效，需重新发起
        }
    }

    /**
     * @dev 验证签名
     */
    function checkSignatures(
        bytes32 dataHash,
        bytes memory signatures
    ) public view {
        uint256 _threshold = threshold;
        require(_threshold > 0, "Threshold not set");
        require(signatures.length >= _threshold * 65, "Signatures not enough");

        address lastOwner = address(0);
        address currentOwner;
        uint8 v;
        bytes32 r;
        bytes32 s;

        for (uint256 i = 0; i < _threshold; i++) {
            // 分离签名
            (v, r, s) = signatureSplit(signatures, i);

            // 恢复签名者地址 (添加以太坊签名消息前缀)
            currentOwner = ecrecover(
                keccak256(
                    abi.encodePacked(
                        "\x19Ethereum Signed Message:\n32",
                        dataHash
                    )
                ),
                v,
                r,
                s
            );

            // 关键点：
            // 1. currentOwner > lastOwner 确保签名者地址升序排列，同时避免同一人重复签名
            // 2. isOwner[currentOwner] 确保签名者是授权的多签人
            require(
                currentOwner > lastOwner && isOwner[currentOwner],
                "Invalid signature or order"
            );
            lastOwner = currentOwner;
        }
    }

    /**
     * @dev 拆分签名数据
     */
    function signatureSplit(
        bytes memory signatures,
        uint256 pos
    ) internal pure returns (uint8 v, bytes32 r, bytes32 s) {
        // 签名格式: {bytes32 r}{bytes32 s}{uint8 v}，每个签名 65 字节
        assembly {
            let signaturePos := mul(0x41, pos)
            r := mload(add(signatures, add(signaturePos, 0x20)))
            s := mload(add(signatures, add(signaturePos, 0x40)))
            v := and(mload(add(signatures, add(signaturePos, 0x41))), 0xff)
        }
    }

    /**
     * @dev 计算交易哈希
     */
    function encodeTransactionData(
        address to,
        uint256 value,
        bytes memory data,
        uint256 _nonce,
        uint256 chainid
    ) public pure returns (bytes32) {
        return
            keccak256(abi.encode(to, value, keccak256(data), _nonce, chainid));
    }

    // 支持接收 ETH
    receive() external payable {}
}
