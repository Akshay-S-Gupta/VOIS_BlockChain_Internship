// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LandRegistry {
    // Structure to represent a land parcel
    struct Land {
        uint256 id;
        string location;
        uint256 area; // Area in square meters
        address owner;
        bool registered;
    }

    // Mapping from land ID to Land details
    mapping(uint256 => Land) public lands;

    // Mapping from land ID to list of previous owners
    mapping(uint256 => address[]) public landOwnershipHistory;

    // Mapping from land ID to approved address for transfer
    mapping(uint256 => address) public approvedTransfers;

    // Event emitted when a new land is registered
    event LandRegistered(uint256 indexed landId, string location, uint256 area, address indexed owner);

    // Event emitted when land ownership is transferred
    event OwnershipTransferred(uint256 indexed landId, address indexed oldOwner, address indexed newOwner);

    // Event emitted when land details are updated
    event LandDetailsUpdated(uint256 indexed landId, string newLocation, uint256 newArea);

    // Event emitted when land is unregistered
    event LandUnregistered(uint256 indexed landId);

    // Register a new land parcel
    function registerLand(uint256 _id, string memory _location, uint256 _area) public {
        require(!lands[_id].registered, "Land already registered");

        lands[_id] = Land({
            id: _id,
            location: _location,
            area: _area,
            owner: msg.sender,
            registered: true
        });

        landOwnershipHistory[_id].push(msg.sender);

        emit LandRegistered(_id, _location, _area, msg.sender);
    }

    // Transfer ownership of a land parcel
    function transferOwnership(uint256 _id, address _newOwner) public {
        Land storage land = lands[_id];
        require(land.registered, "Land not registered");
        require(land.owner == msg.sender || approvedTransfers[_id] == msg.sender, "Only the owner or approved address can transfer ownership");

        address oldOwner = land.owner;
        land.owner = _newOwner;
        landOwnershipHistory[_id].push(_newOwner);

        if (approvedTransfers[_id] == msg.sender) {
            delete approvedTransfers[_id];
        }

        emit OwnershipTransferred(_id, oldOwner, _newOwner);
    }

    // Approve another address to transfer ownership
    function approveTransfer(uint256 _id, address _approved) public {
        Land storage land = lands[_id];
        require(land.registered, "Land not registered");
        require(land.owner == msg.sender, "Only the owner can approve transfer");

        approvedTransfers[_id] = _approved;
    }

    // Update land details
    function updateLandDetails(uint256 _id, string memory _newLocation, uint256 _newArea) public {
        Land storage land = lands[_id];
        require(land.registered, "Land not registered");
        require(land.owner == msg.sender, "Only the owner can update land details");

        land.location = _newLocation;
        land.area = _newArea;

        emit LandDetailsUpdated(_id, _newLocation, _newArea);
    }

    // Unregister land
    function unregisterLand(uint256 _id) public {
        Land storage land = lands[_id];
        require(land.registered, "Land not registered");
        require(land.owner == msg.sender, "Only the owner can unregister land");

        land.registered = false;

        emit LandUnregistered(_id);
    }

    // Check if an address is the owner of a land parcel
    function isOwner(uint256 _id, address _owner) public view returns (bool) {
        return lands[_id].owner == _owner;
    }

    // Get land details
    function getLand(uint256 _id) public view returns (uint256, string memory, uint256, address, bool) {
        Land memory land = lands[_id];
        require(land.registered, "Land not registered");

        return (land.id, land.location, land.area, land.owner, land.registered);
    }

    // Check if land is registered
    function isLandRegistered(uint256 _id) public view returns (bool) {
        return lands[_id].registered;
    }

    // Get ownership history of a land parcel
    function getOwnershipHistory(uint256 _id) public view returns (address[] memory) {
        return landOwnershipHistory[_id];
    }

    // List all registered land parcels
    function listAllLands() public view returns (Land[] memory) {
        uint256 count = 0;
        for (uint256 i = 0; i < type(uint256).max; i++) {
            if (lands[i].registered) {
                count++;
            } else {
                break;
            }
        }

        Land[] memory allLands = new Land[](count);
        for (uint256 i = 0; i < count; i++) {
            allLands[i] = lands[i];
        }

        return allLands;
    }
}
