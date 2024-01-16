# Decentralized Voting System

## Overview
The Decentralized Voting System leverages Ethereum blockchain technology to create a secure, transparent, and immutable environment for conducting various types of votes and polls. With smart contracts at its core, this system ensures the integrity and confidentiality of the voting process.

## Features
- **Decentralized Voting**: Built on Ethereum for a secure and tamper-proof voting experience.
- **Poll Manager Contract**: Manages the creation and lifecycle of individual voting instances (`VotingInstance`).
- **Polling Instances**: Represents distinct votes or polls, each with their own set of candidates and voting logic.
- **Transparency and Anonymity**: Balances transparent voting results with voter privacy.
- **Versatile Voting Scenarios**: Suitable for a wide range of voting applications.
- **Reward Mechanism**: After a poll has expired the users that have voted on the winning PollOption will receive a reward. 

## How It Works
1. **Poll Manager**: A master contract that deploys and oversees `VotingInstance` contracts.
2. **Creating Polls**: Users can initiate new poll instances through the Poll Manager.
3. **Voting Process**: Voters participate in active polls, casting votes for their preferred options.
4. **Results**: Vote outcomes are transparently tallied and published.

## Getting Started
### Prerequisites
- [Foundry](https://github.com/foundry-rs/foundry)
- [Node.js](https://nodejs.org/)
- [MetaMask](https://metamask.io/)

### Installation
1. Clone the repository:
    ```git clone https://github.com/web3technologies/decentralized_voting_system.git```

2. Install Foundry:
    ```
    curl -L https://foundry.paradigm.xyz | bash
    foundryup
    ```

### Deployment
1. Compile the smart contracts:
```forge build```

2. Deploy the contracts to a local testnet (like Hardhat or Ganache):
```forge test --fork-url http://localhost:8545```

### Interacting with the Contract
Interact with the deployed contracts using Foundry's `cast` tool, or integrate with a frontend using Web3.js.

## Testing
Run the test suite:
```forge test```

## Contributing
We welcome contributions! Please see our [contribution guidelines](CONTRIBUTING.md) for details.

## License
This project is under the [MIT License](LICENSE).

## Acknowledgements
- Ethereum Community
- Foundry
- Solidity

