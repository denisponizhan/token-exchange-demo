pragma solidity >=0.4.21 <0.7.0;

contract Exchange {
    Order[] public bids;
    Order[] public asks;

    struct Order {
        uint256 price;
        uint256 amount;
        address sender;
    }

    constructor() public {}

    function buy(uint256 _price, uint256 _amount) public {
        require(_amount > 0, "Amount must be greater than zero");

        if (asks.length > 0 && _price >= asks[asks.length - 1].price) {
            // Match Orders
            // Delete Order From Sellbook
            // Adjust Sum
        } else {
            addToBids(_price, _amount);
        }
    }

    function sell(uint256 _price, uint256 _amount) public {
        require(_amount > 0, "Amount must be greater than zero");

        if (bids.length > 0 && _price <= bids[bids.length - 1].price) {
            // Match Orders
            // Delete Order From BuyBook
            // Adjust Sum
        } else {
            addToAsks(_price, _amount);
        }
    }

    function addToBids(uint256 _price, uint256 _amount)
        private
        returns (bool success)
    {
        if (bids.length == 0) {
            bids.push(
                Order({price: _price, amount: _amount, sender: msg.sender})
            );
            return true;
        }
        uint256 innerLength = bids.length - 1;
        for (uint256 i = 0; i <= innerLength; i++) {
            if (_price > bids[innerLength - i].price) {
                if (i == 0) {
                    bids.push(
                        Order({
                            price: _price,
                            amount: _amount,
                            sender: msg.sender
                        })
                    );
                    return true;
                } else {
                    bids.push(bids[innerLength]);
                    for (uint256 j = 0; j < i; j++) {
                        bids[innerLength - j + 1] = bids[innerLength - j];
                    }
                    bids[innerLength - i + 1] = Order({
                        price: _price,
                        amount: _amount,
                        sender: msg.sender
                    });
                    return true;
                }
            }
        }
        bids.push(bids[innerLength]);
        for (uint256 k = 0; k < innerLength + 1; k++) {
            bids[innerLength - k + 1] = bids[innerLength - k];
        }
        bids[0] = Order({price: _price, amount: _amount, sender: msg.sender});
        return true;

    }

    function addToAsks(uint256 _price, uint256 _amount)
        private
        returns (bool success)
    {
        if (asks.length == 0) {
            asks.push(
                Order({price: _price, amount: _amount, sender: msg.sender})
            );
            return true;
        }
        uint256 innerLength = asks.length - 1;
        for (uint256 i = 0; i <= innerLength; i++) {
            if (_price < asks[innerLength - i].price) {
                if (i == 0) {
                    asks.push(
                        Order({
                            price: _price,
                            amount: _amount,
                            sender: msg.sender
                        })
                    );
                    return true;
                } else {
                    asks.push(asks[innerLength]);
                    for (uint256 j = 0; j < i; j++) {
                        asks[innerLength - j + 1] = asks[innerLength - j];
                    }
                    asks[innerLength - i + 1] = Order({
                        price: _price,
                        amount: _amount,
                        sender: msg.sender
                    });
                    return true;
                }
            }
        }
        asks.push(asks[innerLength]);
        for (uint256 k = 0; k < innerLength + 1; k++) {
            asks[innerLength - k + 1] = asks[innerLength - k];
        }
        asks[0] = Order({price: _price, amount: _amount, sender: msg.sender});
        return true;
    }

}
