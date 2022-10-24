
The experimental backend for the POSTRISC architecture.
Currently works for simple programs.
Compiler, assembler.
ELF binary format supported.
Disassembler works via objdump.
Linker works for static-pie.

Usage Restrictions
==================
Must use --frame-pointer=none (-fomit-frame-pointer).

Command Line Options
====================
--postrisc-enable-dense-calls   bool default=false    Enables returns to middle of bundles
--disable-postrisc-leaf-proc    bool default=false    Disable Postrisc leaf procedure optimization (experimental).
--enable-move-merging           bool default=false    Enables mov+mov => mov2 coalescing
--enable-nullification          bool default=false    Enables nullification
--max-nullification-blocksize   uint default=10       Max merged block size for nullification

Code models:
* tiny, small:
    distance from code to data/rodata fits in 28 bits
* medium:
    code fit in 2GiB, data/rodata fits in 64bits
* large:
    code/data offsets is 63/64 bits.
