//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20

interface IERC20{
    //代币转移事件
    event Transfer(address indexed from,address indexed to,uint256 value);
    //授权事件
    event Approval(address indexed owner,address indexed spender,uint256 value)
    //返回代币总供给
    function totalSupply() external view returns(uint256);
    //返回account账户该代币的剩余数量
    function balanceof(address account) external view returns(uint256);
    //转移给某个地址多少数量代币
    function transfer(address to,uint256 amount) external returns(bool);
    //owner给spender的授权额度数量
    function allowance(address owner,address spender )external view returns(uint256);
    //owner给spender授权
    function approve(address spender,uint256 amount)external returns(bool);
    //spender执行代币转移
    function transferFrom(address from,address to,uint256 amount )external returns(bool);
}