//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

contract Bank {
    // 管理员
    address private immutable admin;
    // 地址存储map映射
    mapping(address => uint) public balances;
    // 前三
    address[3] public topThreeUsers;

    error NotAdmin();
    error NotEnoughBalance();

    constructor() {
        admin = msg.sender;
    }


    modifier onlyAdmin() {
        if (msg.sender != admin) {
            revert NotAdmin();
        }
        _;
    }

    function withdraw(uint amount) public onlyAdmin {
        if (amount > address(this).balance) {
            revert NotEnoughBalance();
        }
        payable(admin).transfer(amount);
    }

    function updateTopThree() internal {
        address sender = msg.sender;
        uint senderBalance = balances[sender];

        for (uint i = 0; i < 3; i++) {
            if (topThreeUsers[i] == sender) {
                for (uint j = i; j < 2; j++) {
                    topThreeUsers[j] = topThreeUsers[j + 1];
                }
                topThreeUsers[2] = address(0);
                break;
            }
        }

        for (uint i = 0; i < 3; i++) {
            if (
                topThreeUsers[i] == address(0) ||
                balances[topThreeUsers[i]] < senderBalance
            ) {
                for (uint j = 2; j > i; j--) {
                    topThreeUsers[j] = topThreeUsers[j - 1];
                }
                topThreeUsers[i] = sender;
                break;
            }
        }
    }

    function getTopThree() public view returns (address[3] memory) {
        return topThreeUsers;
    }

    receive() external payable {
        balances[msg.sender] = balances[msg.sender] + msg.value;
        updateTopThree();
    }
}
