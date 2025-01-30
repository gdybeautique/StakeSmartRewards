# Secure Staking Smart Contract

## Overview
The Secure Staking Smart Contract allows users to stake tokens and earn rewards over time. The contract ensures security and fairness in staking, reward calculation, and withdrawals.

## Features
- **Stake Tokens**: Users can stake tokens and start earning rewards.
- **Reward Calculation**: Earn a 10% annual reward based on the staking duration.
- **Claim Rewards**: Users can claim their accrued rewards.
- **Withdraw Staked Tokens**: Users can withdraw both staked tokens and earned rewards.
- **Emergency Withdraw**: The contract owner can perform an emergency withdrawal if necessary.

## Constants
- **CONTRACT_OWNER**: The deployer of the contract.
- **REWARD_RATE**: 10% annual interest rate.
- **SECONDS_IN_YEAR**: Defined as 31,536,000 seconds.
- **Error Codes**:
  - ERR_UNAUTHORIZED (u1)
  - ERR_INVALID_AMOUNT (u2)
  - ERR_INSUFFICIENT_BALANCE (u3)
  - ERR_NO_REWARDS (u4)
  - ERR_NOTHING_TO_WITHDRAW (u5)

## Data Structures
- **stakes**: Stores the amount of tokens staked by each user.
- **stake-timestamps**: Records the block height when a user stakes tokens.
- **rewards**: Tracks the rewards earned by each user.

## Functions
### Public Functions
1. **stake(amount uint)**
   - Stakes the specified amount of tokens.
   - Updates the user's stake and timestamp.

2. **claim-rewards()**
   - Calculates and claims earned rewards.
   - Updates reward balance and stake timestamp.

3. **withdraw()**
   - Withdraws the user's staked tokens and earned rewards.
   - Transfers funds back to the user.

4. **emergency-withdraw()** *(Owner Only)*
   - Transfers all contract funds to the owner in case of emergency.

### Read-Only Functions
1. **get-staked-amount(user principal)**
   - Returns the total amount staked by the user.

2. **get-user-rewards(user principal)**
   - Returns the user's earned rewards.

## Security Considerations
- **Ownership Control**: Only the contract owner can perform emergency withdrawals.
- **Error Handling**: Defined error codes prevent unauthorized access and invalid transactions.
- **Balance Validation**: Ensures users cannot stake more than their available balance.

## Usage Guide
1. Deploy the contract to the blockchain.
2. Users can stake tokens by calling `stake(amount)`.
3. Rewards accrue over time; users can check them using `get-user-rewards(user)`.
4. Users can claim rewards with `claim-rewards()` and withdraw with `withdraw()`.

## License
This contract is open-source and can be freely used and modified.

