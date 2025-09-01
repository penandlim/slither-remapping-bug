# Slither Scoped Remapping Bug Reproduction

## Problem Statement

Slither fails to understand Foundry's scoped remapping syntax, which causes import resolution failures when analyzing projects that use dependencies with their own sub-dependencies.

### Why This Matters: Version Conflict Resolution

This issue is critical in real-world scenarios where:

1. Your main project uses **OpenZeppelin v5.3.0** 
2. You depend on **tokenized-strategy** which internally uses **OpenZeppelin v4.9.x**
3. You need to create contracts that inherit from both versions simultaneously

Look at `src/TestStrategy.sol` for a concrete example:
- It extends `BaseStrategy` from tokenized-strategy (which uses OpenZeppelin v4.9.x internally)
- It also imports `ReentrancyGuard` from OpenZeppelin v5.3.0 directly
- Both versions need to coexist in the same contract without conflicts

The scoped remapping tells Foundry: "When compiling files inside the tokenized-strategy folder, use its local OpenZeppelin v4.9.x. But when compiling files in my main project, use OpenZeppelin v5.3.0." This allows both versions to work together seamlessly.

## The Bug

Foundry supports a scoped remapping syntax that allows different import resolutions for files within specific directories:

```
dependencies/tokenized-strategy-3.0.4/:@openzeppelin/=dependencies/tokenized-strategy-3.0.4/lib/openzeppelin-contracts/
```

This tells Foundry: "When compiling files inside `dependencies/tokenized-strategy-3.0.4/`, remap `@openzeppelin/` imports to use the local OpenZeppelin copy instead of the project's main version."

**Slither does not understand this syntax** and fails to resolve imports correctly.

## Repository Structure

```
slither-remapping-bug/
├── dependencies/
│   ├── @openzeppelin-contracts-5.3.0/     # Main project's OpenZeppelin (v5.3.0)
│   └── tokenized-strategy-3.0.4/          # Yearn's tokenized-strategy
│       └── lib/
│           └── openzeppelin-contracts/    # Strategy's OpenZeppelin (v4.9.x)
├── src/
│   └── TestStrategy.sol                   # The key example: inherits from both versions
└── foundry.toml                           # Contains the problematic scoped remapping
```

## Steps to Reproduce

### 1. Clone and Setup

```bash
git clone https://github.com/penandlim/slither-remapping-bug
cd slither-remapping-bug
forge soldeer install
```

### 2. Test with Forge (Success)

```bash
forge clean && forge build
```

**Result:** Successful compilation
- Forge correctly handles the scoped remapping
- TestStrategy.sol compiles successfully using both OpenZeppelin versions
- No version conflicts occur

### 3. Test with Slither (Failure)

```bash
slither .
```

**Result:** Import resolution failure
- Slither can't understand the scoped remapping syntax
- Fails with "AssertionError: Contract IERC20Permit not found"

### Remapping Syntax

The problematic remapping in `foundry.toml`:

```toml
remappings = [
    # Standard remappings - work fine
    "@openzeppelin/contracts/=dependencies/@openzeppelin-contracts-5.3.0/contracts/",
    "tokenized-strategy/=dependencies/tokenized-strategy-3.0.4/",
    
    # Scoped remapping - Slither doesn't understand this
    "dependencies/tokenized-strategy-3.0.4/:@openzeppelin/=dependencies/tokenized-strategy-3.0.4/lib/openzeppelin-contracts/"
]
```