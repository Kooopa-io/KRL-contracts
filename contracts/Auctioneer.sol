// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

// import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./KRL.sol";

contract Auctioneer is Ownable {
    uint256 public minBid;
    uint256 public constant aDay = 86400;
    KRL public krlContract;
    IERC20 constant weth = IERC20(0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619);

    struct logBid {
        address bidder;
        uint256 id;
        uint256 bid;
        uint256 timestamp;
    }

    struct auction {
        uint256 timeStarted;
        uint256 timeEnded;
        bool began;
        bool ended;
        address highestBidder;
        uint256 highestBid;
        uint256 totalBids;
        mapping(uint256 => logBid) pendingReturns;
    }

    struct Racer {
        string uri;
        address owner;
        address operator;
        uint256 lastPrice;
        bool isGod;
        bool mint;
        bool auctioned;
    }

    mapping(uint256 => auction) public Auctions;

    constructor(
        uint256 _minBid,
        address _k
    ) {
        minBid = _minBid;
        krlContract = KRL(_k);
    }

    function startAuction(uint256 id, uint256 amount) external payable {
        require(amount >= minBid, "Amount should be grater than minimum bid");
        auction storage inst = Auctions[id];
        bool auctioned = krlContract.getRacer(id).auctioned;
        require(!inst.began, "Auction already started");
        require(!inst.ended, "Auction already ended");
        require(auctioned == false, "Racer already auctioned");
        deposit(msg.sender, amount);

        inst.began = true;
        inst.highestBid = amount;
        inst.highestBidder = msg.sender;
        inst.timeStarted = block.timestamp;
        inst.timeEnded = block.timestamp + aDay;
    }

    function Bid(uint256 id, uint256 amount) external payable {
        auction storage inst = Auctions[id];
        require(
            amount >= inst.highestBid,
            "The bid amount should higher than current bid"
        );
        require(!inst.ended, "Auction Finished");
        deposit(msg.sender, amount);
        inst.pendingReturns[inst.totalBids++] = logBid({
            bidder: inst.highestBidder,
            bid: inst.highestBid,
            timestamp: block.timestamp,
            id: id
        });
    }
    function auctionEnd(uint256 id) external payable {
        
    }
    
    function deposit(address _r, uint256 amount) public payable {
        uint256 _allownace = weth.allowance(payable(_r), address(this));
        weth.transferFrom(payable(_r), address(this), amount);
    }

    // function getRacer(uint256 id) public view returns(Racer memory){
    //     return krlContract.getRacer(id);
    // }
}
