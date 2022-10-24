
The experimental backend for the POSTRISC architecture.
Currently works for  static PIE programs.
Compiler, assembler.
ELF binary format supported.
Disassembler works via objdump.

Code models:
* tiny, small:
    distance from code to data/rodata fits in 28 bits
* medium:
    code fits in 2GiB, data/rodata fits in 64bits
* large:
    code/data offsets is 63/64 bits.

Usage Restrictions
==================
FIXME: must use --frame-pointer=none (-fomit-frame-pointer)?

TODO:
* Support for pre-update load/store instructions
* Support for loop instructions
* Support for GOT
* Support for C++ exceptions landing pads
* Various SIMD stuff
