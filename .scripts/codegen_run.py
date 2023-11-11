#!/usr/bin/python3

import builtins, os, shutil, subprocess, platform, sys, multiprocessing, math

project_dir = os.path.dirname(os.path.dirname(os.path.realpath(__file__)))
#print(f"project_dir={project_dir}")

build_dir = os.path.dirname(project_dir) + f"{os.sep}llvm-build-debug"


CODEGEN_DIR=f"{project_dir}{os.sep}llvm{os.sep}test{os.sep}CodeGen{os.sep}Postrisc"
#print(f"CODEGEN_DIR={CODEGEN_DIR}")

# automate running LLVM codegen tests from postrisc repo.
def main():
    with open("out_codegen_tests.tmp", "w") as outfile:
        # print(f"LLVM_BUILD_DEBUG_BIN_DIR={LLVM_BUILD_DEBUG_BIN_DIR}")
        os.chdir(f"{build_dir}{os.sep}bin")

        if platform.system() == 'Windows':
            subprocess.run(["python3", "./llvm-lit.py", "-v", CODEGEN_DIR], stdout=outfile, stderr=outfile, text=True, check=True)
        else:
            subprocess.run(["./llvm-lit",               "-v", CODEGEN_DIR], stdout=outfile, stderr=outfile, text=True, check=True)

if __name__ == "__main__":
    main()
