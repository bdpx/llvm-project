//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

include "llvm/Option/LibraryOptions.td"

// Hidden command Line Options

def PostriscOptions : OptionsStruct<prefix = "postrisc-">;

defm : BoolField<"postrisc-enable-block-merging",   "false", "Enable fallthrough blocks merging">;
defm : BoolField<"postrisc-enable-dense-calls",     "false", "Enable calls inside bundle and returns to middle of bundle.">;
defm : BoolField<"postrisc-disable-leaf-proc",      "false", "Disable leaf procedure optimization.">;
defm : BoolField<"postrisc-enable-move-merging",    "false", "Enables mov+mov => mov2 coalescing">;
defm : BoolField<"postrisc-enable-nullification",   "false", "Enable nullification instructions">;
defm : BoolField<"postrisc-enable-pre-post-update", "false", "Enable Pre/Post update instructions">;

defm : ValueField<"postrisc-max-nullification-blocksize", "int",      "8", "Maximum nullification block size">;
defm : ValueField<"postrisc-kill-addr-mode",              "unsigned", "0", "Postrisc Kill-addr-mode flags">;
