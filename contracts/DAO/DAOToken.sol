//SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


pragma solidity >0.5.0 <0.9.0;

contract DAOToken is ERC20, Ownable{

    mapping(address=>uint)private _balances;

    constructor(
        string memory name, 
        string memory symbol,
        uint totalAmount
        )ERC20(name, symbol){
            _mint(address(this), totalAmount);
            _balances[address(this)] += totalAmount;
        }



    function increaseAllowance(address spender, uint256 addedValue) public virtual override returns (bool) {
        address owner = address(this);
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }



    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }



    function _transfer(
        address from, 
        address to,
        uint amount
    )internal override{
        _balances[from] -= amount;
        _balances[to] += amount;
        super._transfer(from, to, amount);
    } 



    function burn(address account, uint amount)public{
        _balances[account] -= amount;
        super._burn(account, amount);
    }
}