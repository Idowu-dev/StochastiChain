# StochastiChain: Secure Entropy Pool

A secure and trustless random number generator smart contract built with Clarity for the Stacks blockchain ecosystem.

## Overview

StochastiChain provides a transparent, on-chain random number generation solution that combines multiple sources of entropy to create unpredictable yet deterministic random numbers. This implementation uses a Linear Congruential Generator (LCG) algorithm enhanced with blockchain-specific entropy sources.

## Features

- **Multiple Entropy Sources**: Combines block timestamps, user-provided entropy, and internal state
- **Secure Implementation**: Uses widely accepted LCG parameters for good statistical properties
- **Customizable Ranges**: Generate random numbers in any range
- **Permission Controls**: Only contract owner can initialize/reset the generator
- **User Contributions**: Anyone can add entropy to improve randomness
- **Transparency**: All entropy sources and generation logic are visible on-chain

## Functions

### Public Functions

| Function | Description |
|----------|-------------|
| `add-entropy` | Add user-provided entropy to enhance randomness |
| `generate-random` | Generate a random number between 0 and a specified maximum |
| `generate-in-range` | Generate a random number within a custom range [min, max] |
| `initialize-generator` | Owner-only function to set a custom initial seed |
| `get-last-random` | Retrieve the most recently generated random number |
| `get-rng-info` | Get information about the current state of the RNG |

### Private Functions

| Function | Description |
|----------|-------------|
| `get-block-entropy` | Extract entropy from the current block timestamp |
| `lcg-next` | Linear Congruential Generator implementation |

## Usage Examples

### Basic Random Number Generation

```clarity
;; Generate a random number between 0 and 100
(contract-call? .secure-entropy-pool generate-random u100)

;; Generate a random number between 5 and 10
(contract-call? .secure-entropy-pool generate-in-range u5 u10)
```

### Contributing Entropy

```clarity
;; Add your own entropy source
(contract-call? .secure-entropy-pool add-entropy u1234567890)
```

### For Contract Owners

```clarity
;; Initialize with a custom seed
(contract-call? .secure-entropy-pool initialize-generator u42)
```

## Technical Implementation

The contract uses a Linear Congruential Generator with the following parameters:
- Multiplier: 1,664,525
- Increment: 1,013,904,223
- Modulus: 2^32 (4,294,967,296)

These are standard parameters known to provide good statistical properties for random number generation.

## Security Considerations

- While this RNG provides good pseudorandom properties, it's not cryptographically secure in the traditional sense
- Miners could theoretically influence block timestamps, but this would require significant control of the blockchain
- The combination of multiple entropy sources helps mitigate potential manipulation
- Best suited for applications where the stakes are modest or manipulation incentives are limited