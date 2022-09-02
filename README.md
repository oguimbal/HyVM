# Tools

You can find `easm`, the basic EVM assemby compiler that is used to compile tests [here](https://github.com/oguimbal/EVM-Assembler)

# Implementation
## Memory layout

When runing a smartcontract, you have the whole memory available (from 0x00 to infinity).
However, NVM needs some memory for its internals.
This memory is taken from the 0x00 offset, and every opcode call that accesses memory that is ran by the host will be fixed to skip this reserved memory.

NVM private memory layout is as follows:

- `[0x00-0x20]` 👉 Execution pointer
- `[0x20-0x220]` 👉 Jump table
- `[0x220-0x340]` 👉 Memory reserved for debug purposes (see debug-utils.huff)
- (when contract contract verifier is enabled) `[0x220-0x460]` 👉 Memory used to store contract verification call args & result. nb: It overlaps debug memory (because we dont need them both at the same time)

Thus, the actual memory of the host is starting at either 0x340 or 0x460 depending on the chosen configuration.