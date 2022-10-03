
<div align="center">
  <img width="60" alt="logo" src="./static/tmpLogo.png" style="margin-bottom:-30px">
</div>

<div align="center">
  <h1>HyVM</h1>
  <div>👉 See it in action with <a href="https://oguimbal.github.io/hyvm-live-playground/">HyVM live playground</a></div>
</div>

<br>

**HyVM is an Ethereum Virtual Machine (EVM) Hypervisor written in [Huff](https://huff.sh/), allowing the execution of arbitrary EVM Bytecode.**

```solidity
function execute() public returns (uint256 result) {
    // Bytecode for “3 + 4" and return the result
    (bool success, bytes memory data) = HyVM.delegatecall(hex”600360040160005260ff6000f3");
    result = abi.decode(data, (uint256));
}
```

***

## What is an hypervisor?

According to [vmware](https://www.vmware.com/topics/glossary/content/hypervisor.html)...

> A hypervisor, also known as a virtual machine monitor or VMM, is software that creates and runs virtual machines (VMs). A hypervisor allows one host computer to support multiple guest VMs by virtually sharing its resources, such as memory and processing.

In our case, the HyVM allows to run an **EVM on top the EVM** and execute [opcodes](https://www.evm.codes/) directly.

## How it works?

### Calling the HyVM

The HyVM ingests raw bytecode (as input) via `call` or `delegateCall`, then processes the opcodes and executes them.

<div align="center">
  <img width="600" alt="image" src="./static/processBytecode.png">
</div>

### Bytecode processing

A pointer reads an opcode from the bytecode (extracted from calldata), translates it into a HyVM opcode implementation (more details below), executes and moves on to the next opcode.
The pointer is stored in memory and updated each time it moves.

<div align="center">
  <img width="600" alt="image" src="./static/opcodesReadAndProcess.png">
</div>

Each opcode is re-implemented to fit the HyVM memory layout and logic.

<div align="center">
  <img width="800" alt="image" src="./static/opcodeMemory.png">
</div>

### Memory Layout

When running a smart contract, you have the whole memory available (from 0x00 to infinity).
However, the HyVM needs some memory for its internals.
This memory is taken from the 0x00 offset. Every opcode call that accesses memory (ran by the host) will be fixed to skip this reserved memory.

The HyVM private memory layout is as follows:

- `[0x00-0x20]` 👉 Execution pointer
- `[0x20-0x220]` 👉 Jump table
- `[0x220-0x340]` 👉 Memory reserved for debug purposes (see debug-utils.huff)
- `[0x220-0x460]` **(when contract contract verifier is enabled)** 👉 Memory used to store contract verification call args & result. nb: It overlaps debug memory (because we dont need them both at the same time)

Thus, the actual memory of the host is starting at either 0x340 or 0x460 depending on the chosen configuration.

## Why?

Using the HyVM gives a maximum of flexibility, it replaces using specific scripts to interact with external protocols.
There is no limit on which interactions that can be created.
Custom and complex logic with chained calls can be executed by the HyVM opening a lot possibilities.
Repetive intructions and common ones could also be called as helper contract if needed.

## Example of use

One way to use the HyVM is to use it as a library called with delegatecall.
As shown below, a [Contract Wallet](https://docs.ethhub.io/using-ethereum/wallets/smart-contract-wallets/) allows to execute a delegatecall (or several), and thus to call the HyVM. The DApp managing the contract wallet gives the bytecode for the HyVM to execute. For example :
* Swap multiple assets.
* Approve & deposit.

<div align="center">
  <img width="600" alt="image" src="./static/hyvmAsLibrary.png">
</div>

## Gas consumption

TODO: Gives incations on gas consumption (doubleSwap example)

## Addresses

TODO: HyVM addresses (when deployed)
## Getting Started

TODO: Gives more details to run the project.

You will need:
* [Huff](https://docs.huff.sh/get-started/installing/)
* [Foundry/Forge](https://github.com/foundry-rs/foundry)

You can find `easm`, the basic EVM assemby compiler that is used to compile tests [here](https://github.com/oguimbal/EVM-Assembler)
You can use [pyevmasm](https://github.com/crytic/pyevmasm) to disassemble bytecode
