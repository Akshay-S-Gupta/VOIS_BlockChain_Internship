// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract LandRegistry {
    struct Land {
        uint256 id;
        string location;
        uint256 area;
        address owner;
        bool isVerified;
        uint256 price;
        bool forSale;
    }
    mapping(uint256 => Land) public lands;
    mapping(uint256 => bool) public landExists;
    address public registrar;
    uint256 public landCount;

    event LandRegistered(uint256 id, address owner);
    event LandTransferred(uint256 id, address newOwner);
    event LandVerified(uint256 id, bool verified);
    event LandListedForSale(uint256 id, uint256 price);
    event LandSold(uint256 id, address buyer);
    event VerificationRequested(uint256 id, address requester);

    modifier onlyRegistrar() {
        require(msg.sender == registrar, "Only registrar can verify land.");
        _;
    }

    modifier onlyOwner(uint256 id) {
        require(lands[id].owner == msg.sender, "Not the owner.");
        _;
    }

    constructor() {
        registrar = msg.sender;
    }

    function registerLand(string memory _location, uint256 _area) public {
        landCount++;
        lands[landCount] = Land(
            landCount,
            _location,
            _area,
            msg.sender,
            false,
            0,
            false
        );
        landExists[landCount] = true;
        emit LandRegistered(landCount, msg.sender);
    }

    function transferLand(uint256 id, address newOwner) public onlyOwner(id) {
        require(landExists[id], "Land does not exist.");
        lands[id].owner = newOwner;
        lands[id].forSale = false;
        emit LandTransferred(id, newOwner);
    }

    function requestVerification(uint256 id) public onlyOwner(id) {
        require(landExists[id], "Land does not exist.");
        emit VerificationRequested(id, msg.sender);
    }

    function verifyLand(uint256 id) public onlyRegistrar {
        require(landExists[id], "Land does not exist.");
        lands[id].isVerified = true;
        emit LandVerified(id, true);
    }

    function listLandForSale(uint256 id, uint256 price) public onlyOwner(id) {
        require(landExists[id], "Land does not exist.");
        lands[id].price = price;
        lands[id].forSale = true;
        emit LandListedForSale(id, price);
    }

    function buyLand(uint256 id) public payable {
        require(landExists[id], "Land does not exist.");
        require(lands[id].forSale, "Land is not for sale.");
        require(msg.value >= lands[id].price, "Insufficient funds.");

        address payable seller = payable(lands[id].owner);
        seller.transfer(msg.value);
        lands[id].owner = msg.sender;
        lands[id].forSale = false;
        emit LandSold(id, msg.sender);
    }
}