// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/IERC1155MetadataURIUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

// import "./StringsUpgradeable.sol";

contract KRL is
    Initializable,
    ERC1155Upgradeable,
    AccessControlUpgradeable,
    PausableUpgradeable,
    ERC1155BurnableUpgradeable,
    UUPSUpgradeable
{
    // using Strings for string;
    bytes32 public constant URI_SETTER_ROLE = keccak256("URI_SETTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    bytes32 public constant AUCTIONEER = keccak256("AUCTIONEER");


    uint256 public constant EOC = 0; //EOC token ID; anything greater than 0 will be NFT racers

    struct Racer {
        string uri;
        address owner;
        address operator;
        uint256 lastPrice;
        bool God;
        bool mint;
        bool auctioned;
    }

    // bytes32 public constant ROLE_SETTER = keccak256("ROLE_SETTER");
    mapping(string => bytes32) internal Roles;
    mapping(uint256 => Racer) public Racers;

    function initialize() public initializer {
        __ERC1155_init("");
        __AccessControl_init();
        __Pausable_init();
        __ERC1155Burnable_init();
        __UUPSUpgradeable_init();

        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(AUCTIONEER, msg.sender);
        setRole("URI_SETTER_ROLE", msg.sender);
        setRole("PAUSER_ROLE", msg.sender);
        setRole("MINTER_ROLE", msg.sender);
        setRole("UPGRADER_ROLE", msg.sender);
    }

    function mintEOC(
        address account,
        uint256 amount,
        bytes memory data
    ) external onlyRole(MINTER_ROLE) {
        _mint(account, 0, amount, data);
    }

    function createRacer(uint256 id, address addr) internal {
        require(Racers[id].owner == address(0), "Racer already has a owner");

        Racers[id].mint = false;
        Racers[id].God = false;
        Racers[id].owner = addr;
        Racers[id].operator = addr;
        Racers[id].uri = string(abi.encodePacked(uri(0), uint2str(id), ".json"));
    }

    function mintRacer(
        address account,
        uint256 id,
        bytes memory data
    ) external {
        require(id != 0, 'ID 0 Belongs to EOC tokens');
        require(hasRole(AUCTIONEER, msg.sender) || hasRole(DEFAULT_ADMIN_ROLE, msg.sender) || hasRole(MINTER_ROLE, msg.sender),"Access Denied");
        createRacer(id, account);
        _mint(account, id, 1, data);
        Racers[id].mint = true;
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal override whenNotPaused {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyRole(UPGRADER_ROLE)
    {}

    // The following functions are overrides required by Solidity.

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC1155Upgradeable, AccessControlUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function stringToBytes32(string memory source)
        internal
        pure
        returns (bytes32 result)
    {
        bytes memory _S = bytes(source);
        // assembly {
        //     result := mload(add(source, 32))
        // }
        return keccak256(_S);
    }
    
    function uint2str(uint256 _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }

    // function hexID(string memory _id) public pure returns (string memory id){
    //     return string.toHexString(_id, 64);
    // }
    function setRole(string memory role, address _add)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        bytes32 _role = stringToBytes32(role);
        Roles[role] = _role;
        _setupRole(_role, _add);
    }

    function setURI(string memory newuri) public onlyRole(URI_SETTER_ROLE) {
        _setURI(newuri);
    }

    function setRacerURI(string memory newuri) public onlyRole(URI_SETTER_ROLE) {
        _setURI(newuri);
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function getRacer(uint256 id) external view returns(Racer memory){
        return Racers[id];
    }
}
