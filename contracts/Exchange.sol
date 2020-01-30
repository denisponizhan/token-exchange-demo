pragma solidity >=0.4.21 <0.7.0;

interface ERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address tokenOwner)
        external
        view
        returns (uint256 balance);
    function allowance(address tokenOwner, address spender)
        external
        view
        returns (uint256 remaining);
    function transfer(address to, uint256 tokens)
        external
        returns (bool success);
    function approve(address spender, uint256 tokens)
        external
        returns (bool success);
    function transferFrom(address from, address to, uint256 tokens)
        external
        returns (bool success);
    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(
        address indexed tokenOwner,
        address indexed spender,
        uint256 tokens
    );
}

contract Exchange {
    Order[] public bids;
    Order[] public asks;

    address public base;
    address public quote;

    struct Order {
        uint256 price;
        uint256 amount;
        address sender;
    }

    constructor(address _base, address _quote) public {
        base = _base;
        quote = _quote;
    }

    function getBid(uint256 index) public view returns (uint256, uint256) {
        Order storage bid = bids[index];
        return (bid.price, bid.amount);
    }

    function getAsk(uint256 index) public view returns (uint256, uint256) {
        Order storage ask = asks[index];
        return (ask.price, ask.amount);
    }

    function buy(uint256 _price, uint256 _amount) public {
        require(_amount > 0, "Amount must be greater than zero");

        if (asks.length > 0 && _price >= asks[asks.length - 1].price) {
            Order storage ask = asks[asks.length - 1];

            uint256 diff;
            uint256 actualPrice;
            uint256 transferAmount;
            uint256 toAdd;

            if (_price > ask.price) {
                diff = _price - ask.price;
                actualPrice = ask.price;
            } else {
                actualPrice = _price;
            }

            if (_amount == ask.amount) {
                transferAmount = _amount;
                swapToBuy(
                    base,
                    quote,
                    msg.sender,
                    ask.sender,
                    transferAmount,
                    actualPrice
                );
                delete asks[asks.length - 1];
            } else if (_amount < ask.amount) {
                transferAmount = _amount;
                ask.amount = ask.amount - _amount;
                swapToBuy(
                    base,
                    quote,
                    msg.sender,
                    ask.sender,
                    transferAmount,
                    actualPrice
                );
            } else if (_amount > ask.amount) {
                transferAmount = ask.amount;
                toAdd = _amount - ask.amount;
                swapToBuy(
                    base,
                    quote,
                    msg.sender,
                    ask.sender,
                    transferAmount,
                    actualPrice
                );
                delete asks[asks.length - 1];
                addToBids(actualPrice, toAdd);
            }

        } else {
            addToBids(_price, _amount);
        }
    }

    function sell(uint256 _price, uint256 _amount) public {
        require(_amount > 0, "Amount must be greater than zero");

        if (bids.length > 0 && _price <= bids[bids.length - 1].price) {
            Order storage bid = bids[bids.length - 1];

            uint256 diff;
            uint256 actualPrice;
            uint256 transferAmount;
            uint256 toAdd;

            if (_price < bid.price) {
                diff = bid.price - _price;
                actualPrice = _price;
            } else {
                actualPrice = bid.price;
            }

            if (_amount == bid.amount) {
                transferAmount = _amount;
                swapToSell(
                    base,
                    quote,
                    msg.sender,
                    bid.sender,
                    transferAmount,
                    actualPrice
                );
                delete bids[bids.length - 1];
            } else if (_amount < bid.amount) {
                transferAmount = _amount;
                bid.amount = bid.amount - _amount;
                swapToSell(
                    base,
                    quote,
                    msg.sender,
                    bid.sender,
                    transferAmount,
                    actualPrice
                );
            } else if (_amount > bid.amount) {
                transferAmount = bid.amount;
                toAdd = _amount - bid.amount;
                swapToSell(
                    base,
                    quote,
                    msg.sender,
                    bid.sender,
                    transferAmount,
                    actualPrice
                );
                delete bids[bids.length - 1];
                addToAsks(_price, toAdd);
            }
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
            ERC20(quote).transferFrom(
                msg.sender,
                address(this),
                _amount * _price
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
                    ERC20(quote).transferFrom(
                        msg.sender,
                        address(this),
                        _amount * _price
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
                    ERC20(quote).transferFrom(
                        msg.sender,
                        address(this),
                        _amount * _price
                    );
                    return true;
                }
            }
        }
        bids.push(bids[innerLength]);
        for (uint256 k = 0; k < innerLength + 1; k++) {
            bids[innerLength - k + 1] = bids[innerLength - k];
        }
        bids[0] = Order({price: _price, amount: _amount, sender: msg.sender});
        ERC20(quote).transferFrom(msg.sender, address(this), _amount * _price);
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
            ERC20(base).transferFrom(msg.sender, address(this), _amount);
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
                    ERC20(base).transferFrom(
                        msg.sender,
                        address(this),
                        _amount
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
                    ERC20(base).transferFrom(
                        msg.sender,
                        address(this),
                        _amount
                    );
                    return true;
                }
            }
        }
        asks.push(asks[innerLength]);
        for (uint256 k = 0; k < innerLength + 1; k++) {
            asks[innerLength - k + 1] = asks[innerLength - k];
        }
        asks[0] = Order({price: _price, amount: _amount, sender: msg.sender});
        ERC20(base).transferFrom(msg.sender, address(this), _amount);
        return true;
    }

    function swapToBuy(
        address _base,
        address _quote,
        address _sender,
        address _receiver,
        uint256 _amount,
        uint256 _price
    ) private {
        ERC20(_quote).transferFrom(_sender, _receiver, _amount * _price);
        ERC20(_base).transfer(_sender, _amount);
    }

    function swapToSell(
        address _base,
        address _quote,
        address _sender,
        address _receiver,
        uint256 _amount,
        uint256 _price
    ) private {
        ERC20(_base).transferFrom(_sender, _receiver, _amount);
        ERC20(_quote).transfer(_sender, _amount * _price);
    }
}
