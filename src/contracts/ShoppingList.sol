pragma solidity ^0.5.0;

contract ShoppingList {
    string public name;
    uint public productCount = 0;
    mapping(uint => Product) public products;

    struct Product {
        uint id;
        string name;
        address payable owner;
        bool crossed;
    }

    event ProductCreated(
        uint id,
        string name,
        address payable owner,
        bool crossed
    );

    event ProductCrossed(
        uint id,
        string name,
        address payable owner,
        bool crossed
    );

    event ProductUnCrossed(
        uint id,
        string name,
        address payable owner,
        bool crossed
    );

    constructor() public {
        name = "Kalek & Gnusowski";
    }

    function createProduct(string memory _name) public {
        require(bytes(_name).length > 0);
        productCount ++;
        products[productCount] = Product(productCount, _name, msg.sender, false);
        emit ProductCreated(productCount, _name, msg.sender, false);
    }

    function crossProduct(uint _id) public payable {
        Product memory _product = products[_id];
        require(_product.id > 0 && _product.id <= productCount);
        require(!_product.crossed);
        _product.crossed = true;
        products[_id] = _product;
        emit ProductCrossed(productCount, _product.name, msg.sender, true);
    }

    function unCrossProduct(uint _id) public payable {
        Product memory _product = products[_id];
        require(_product.id > 0 && _product.id <= productCount);
        require(_product.crossed);
        _product.crossed = false;
        products[_id] = _product;
        emit ProductUnCrossed(productCount, _product.name, msg.sender, true);
    }

    function clearProduct(uint _id) public {
        delete products[_id];
    }
}
