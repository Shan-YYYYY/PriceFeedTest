// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

contract MockChainlinkOracle {
    uint80 public currentRound;
    uint80 public lastRound;

    int256 public answer;
    int256 public lastAnswer;

    uint256 public timestamp;
    uint256 public lastTimestamp;

    uint8 public decimals;

    constructor() {
        currentRound = 5;
        lastRound = 4;

        answer = 100e9;
        lastAnswer = 97e9;

        decimals = 9;

        timestamp = block.timestamp;
        lastTimestamp = block.timestamp;
    }

    function setUpAll(
        uint80 _round,
        int256 _answer,
        uint256 _timestamp,
        uint8 _decimals
    ) external {
        this.setUp(_round, _answer, _timestamp, _decimals, true);
        this.setUp(_round, _answer, _timestamp, _decimals, false);
    }

    function setUp(
        uint80 _round,
        int256 _answer,
        uint256 _timestamp,
        uint8 _decimals,
        bool _isPrevious
    ) external {
        if (_isPrevious) {
            lastRound = _round;
            lastAnswer = _answer;
            lastTimestamp = _timestamp;
        } else {
            currentRound = _round;
            answer = _answer;
            timestamp = _timestamp;
        }

        decimals = _decimals;
    }

    function latestRoundData()
        external
        view
        returns (
            uint80 _roundId,
            int256 _answer,
            uint256 _startedAt,
            uint256 _timestamp,
            uint80 _answeredInRound
        )
    {
        return (currentRound, answer, 0, timestamp, 0);
    }

    function getRoundData(uint80 _roundId)
        external
        view
        returns (
            uint80 _roundIdReturned,
            int256 _answer,
            uint256 _startedAt,
            uint256 _timestamp,
            uint80 _answeredInRound
        )
    {
        return (lastRound, lastAnswer, 0, lastTimestamp, 0);
    }

    function getScaledAnswer() public view returns (uint256) {
        return decimals < 18 ? uint256(answer) * (10**(18 - decimals)) : uint256(answer) / (10**(decimals - 18));
    } 
}
