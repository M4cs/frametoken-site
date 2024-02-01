// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "solady/src/tokens/ERC20.sol";

contract FrameToken is ERC20 {
    error AlreadyClaimed();
    error AirdropOver();
    error MaxSupplyReached();
    error NotWhitelisted();

    uint256 public MAX_SUPPLY = 1_000_000_000_000 * 1 ether;
    uint256 public LOCKED_SUPPLY = 200_000_000_000 * 1  ether; // Locked until airdrop is completely claimed, then transferred to an LP.

    uint256 airdropStart = 0;

    address operator;

    mapping(uint128 fid => bool claimed) public airdropClaimed;

    modifier onlyOperator() {
        require(
            msg.sender == operator,
            "FrameToken: caller is not the operator"
        );
        _;
    }

    constructor() ERC20() {
        operator = msg.sender;
        _mint(msg.sender, LOCKED_SUPPLY);
    }

    function claimAirdrop(uint128 fid, address to) external onlyOperator {
        if (airdropClaimed[fid]) {
            revert AlreadyClaimed();
        }
        uint256 airdropSupply = calculateAirdropSupply(fid);
        if (totalSupply() + airdropSupply > MAX_SUPPLY) {
            revert MaxSupplyReached();
        }
        if (block.timestamp > calculateAirdropEnd()) {
            revert AirdropOver();
        }
        _mint(to, airdropSupply);
        airdropClaimed[fid] = true;
    }

    function calculateAirdropSupply(uint128 fid) public pure returns (uint256) {
        if (fid >= 1 && fid <= 1499) {
            return 2_000_000_000 * 1 ether;
        } else if (fid >= 1500 && fid <= 9999) {
            return 1_000_000_000 * 1 ether;
        } else if (fid >= 10_000 && fid <= 99999) {
            return 500_000_000 * 1 ether;
        } else if (fid >= 100_000 && fid <= 224_999) {
            return 250_000_000 * 1 ether;
        } else {
            return 100_000_000 * 1 ether;
        }
    }

    function calculateAirdropEnd() public view returns (uint256) {
        return airdropStart + 14 days;
    }

    function setAirdropStart() external onlyOperator {
        airdropStart = block.timestamp;
    }

    function mintRemaining() external onlyOperator {
        uint256 remaining = MAX_SUPPLY - totalSupply();
        _mint(msg.sender, remaining);
    }

    function name() public view virtual override returns (string memory) {
        return "FrameToken";
    }

    function symbol() public view virtual override returns (string memory) {
        return "FRAME";
    }

    function withdraw() external onlyOperator {
        (bool success,) = address(operator).call{value:address(this).balance}("");
        if (!success) {
            revert ("FailedToTransfer");
        }
    }
}
