// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract HelloWeb3 {
    //1、布尔型
    // 布尔值
    bool public _bool = true;
    // 布尔运算
    bool public _bool1 = !_bool; // 取非
    bool public _bool2 = _bool && _bool1; // 与
    bool public _bool3 = _bool || _bool1; // 或
    bool public _bool4 = _bool == _bool1; // 相等
    bool public _bool5 = _bool != _bool1; // 不相等

    //2、整型
    int public _int = -1; // 整数，包括负数
    uint public _uint = 1; // 无符号整数
    uint256 public _number = 20220330; // 256位无符号整数
    // 整数运算
    uint256 public _number1 = _number + 1; // +，-，*，/
    uint256 public _number2 = 2 ** 2; // 指数
    uint256 public _number3 = 7 % 2; // 取余数
    bool public _numberbool = _number2 > _number3; // 比大小

    //3. 地址类型
    // 地址类型(address)有两类：

    // 普通地址（address）: 存储一个 20 字节的值（以太坊地址的大小）。
    // payable address: 比普通地址多了 transfer 和 send 两个成员方法，用于接收转账。
    // 地址
    address public _address = 0x7A58c0Be72BE218B41C608b7Fe7C5bB630736C71;
    address payable public _address1 = payable(_address); // payable address，可以转账、查余额
    // 地址类型的成员
    uint256 public balance = _address1.balance; // balance of address

    // 4. 定长字节数组
    // 字节数组分为定长和不定长两种：

    // 定长字节数组: 属于值类型，数组长度在声明之后不能改变。根据字节数组的长度分为 bytes1, bytes8, bytes32 等类型。定长字节数组最多存储 32 bytes 数据，即bytes32。
    // 不定长字节数组: 属于引用类型（之后的章节介绍），数组长度在声明之后可以改变，包括 bytes 等。
    // 固定长度的字节数组
    bytes32 public _byte32 = "MiniSolidity";
    bytes1 public _byte = _byte32[0];

    // 在上述代码中，字符串 MiniSolidity 以字节的方式存储进变量 _byte32。如果把它转换成 16 进制，就是：0x4d696e69536f6c69646974790000000000000000000000000000000000000000

    // _byte 变量的值为 _byte32 的第一个字节，即 0x4d。

    //5. 枚举 enum
    // 枚举（enum）是 Solidity 中用户定义的数据类型。它主要用于为 uint 分配名称，使程序易于阅读和维护。它与 C 语言 中的 enum 类似，使用名称来代替从 0 开始的 uint：
    // 枚举可以显式地和 uint 相互转换，并会检查转换的无符号整数是否在枚举的长度内，否则会报错：

    // enum可以和uint显式的转换
    function enumToUint() external view returns (uint) {
        return uint(action);
    }
    // enum 是一个比较冷门的数据类型，几乎没什么人用。
}
