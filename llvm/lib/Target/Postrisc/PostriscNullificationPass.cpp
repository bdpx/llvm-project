//===-- PostriscNullificationPass.cpp - Transform to Predicated Code ------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
//
//===----------------------------------------------------------------------===//

#include "Postrisc.h"
#include "PostriscMachineFunctionInfo.h"
#include "PostriscTargetMachine.h"
#include "PostriscSubtarget.h"
#include "llvm/ADT/Statistic.h"
#include "llvm/CodeGen/MachineBasicBlock.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineInstr.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineInstrBundle.h"
#include "llvm/CodeGen/MachineOperand.h"

using namespace llvm;

#define DEBUG_TYPE "postrisc-nullification"
#define PASS_NAME "Postrisc Nullification"

static cl::opt<bool>
EnableNullify("postrisc-enable-nullification",
              cl::init(false),
              cl::desc("Enable nullification instructions"),
              cl::NotHidden);

static cl::opt<int>
MaxNullificationBlockSize("postrisc-max-nullification-blocksize",
               cl::init(8),
               cl::desc("Maximum nullification block size"),
               cl::NotHidden);

static inline int maxArchNullificationBlockSize(void) {
  const int MaxArchNullificationBlockSize = 15;
  return std::min<int>(MaxArchNullificationBlockSize, MaxNullificationBlockSize);
}

STATISTIC(NumPREDs,        "Number of single predicated blocks inserted");


static unsigned getNullificationOpc(unsigned Opc, bool& swap_args, bool& swap_blocks) {
  switch (Opc) {
  // X - short/long reg-reg branches convert to short-only nullifications
#define AS_IS_NO_EXT(BCOND, NCOND)                                                              \
  case POSTRISC::BCOND:        swap_args = false; swap_blocks = false; return POSTRISC::NCOND;  \
  case POSTRISC::BCOND##_EXT:  swap_args = false; swap_blocks = false; return POSTRISC::NCOND;

  AS_IS_NO_EXT(BREQW,   NULEQW)
  AS_IS_NO_EXT(BRNEW,   NULNEW)
  AS_IS_NO_EXT(BRLTSW,  NULLTSW)
  AS_IS_NO_EXT(BRLTSD,  NULLTSD)
  AS_IS_NO_EXT(BRLTSQ,  NULLTSQ)
  AS_IS_NO_EXT(BRGESW,  NULGESW)

  AS_IS_NO_EXT(BREQD,   NULEQD)
  AS_IS_NO_EXT(BRNED,   NULNED)
  AS_IS_NO_EXT(BRGESD,  NULGESD)
  AS_IS_NO_EXT(BRGESQ,  NULGESQ)
  AS_IS_NO_EXT(BRLTUW,  NULLTUW)
  AS_IS_NO_EXT(BRLTUD,  NULLTUD)

  AS_IS_NO_EXT(BREQQ,   NULEQQ)
  AS_IS_NO_EXT(BRNEQ,   NULNEQ)
  AS_IS_NO_EXT(BRLTUQ,  NULLTUQ)
  AS_IS_NO_EXT(BRGEUW,  NULGEUW)
  AS_IS_NO_EXT(BRGEUD,  NULGEUD)
  AS_IS_NO_EXT(BRGEUQ,  NULGEUQ)

  AS_IS_NO_EXT(BRBS,    NULBS)
  AS_IS_NO_EXT(BRBC,    NULBC)
  AS_IS_NO_EXT(BRBSI,   NULBSI)
  AS_IS_NO_EXT(BRBCI,   NULBCI)

  AS_IS_NO_EXT(FBROEQH,  FNULOEQH)
  AS_IS_NO_EXT(FBRONEH,  FNULONEH)
  AS_IS_NO_EXT(FBROLTH,  FNULOLTH)
  AS_IS_NO_EXT(FBROGEH,  FNULOGEH)
  AS_IS_NO_EXT(FBROH,    FNULOH)
  AS_IS_NO_EXT(FBRUEQH,  FNULUEQH)
  AS_IS_NO_EXT(FBRUNEH,  FNULUNEH)
  AS_IS_NO_EXT(FBRULTH,  FNULULTH)
  AS_IS_NO_EXT(FBRUGEH,  FNULUGEH)
  AS_IS_NO_EXT(FBRUH,    FNULUH)

  AS_IS_NO_EXT(FBROEQS,  FNULOEQS)
  AS_IS_NO_EXT(FBRONES,  FNULONES)
  AS_IS_NO_EXT(FBROLTS,  FNULOLTS)
  AS_IS_NO_EXT(FBROGES,  FNULOGES)
  AS_IS_NO_EXT(FBROS,    FNULOS)
  AS_IS_NO_EXT(FBRUEQS,  FNULUEQS)
  AS_IS_NO_EXT(FBRUNES,  FNULUNES)
  AS_IS_NO_EXT(FBRULTS,  FNULULTS)
  AS_IS_NO_EXT(FBRUGES,  FNULUGES)
  AS_IS_NO_EXT(FBRUS,    FNULUS)

  AS_IS_NO_EXT(FBROEQD,  FNULOEQD)
  AS_IS_NO_EXT(FBRONED,  FNULONED)
  AS_IS_NO_EXT(FBROLTD,  FNULOLTD)
  AS_IS_NO_EXT(FBROGED,  FNULOGED)
  AS_IS_NO_EXT(FBROD,    FNULOD)
  AS_IS_NO_EXT(FBRUEQD,  FNULUEQD)
  AS_IS_NO_EXT(FBRUNED,  FNULUNED)
  AS_IS_NO_EXT(FBRULTD,  FNULULTD)
  AS_IS_NO_EXT(FBRUGED,  FNULUGED)
  AS_IS_NO_EXT(FBRUD,    FNULUD)

  AS_IS_NO_EXT(FBROEQQ,  FNULOEQQ)
  AS_IS_NO_EXT(FBRONEQ,  FNULONEQ)
  AS_IS_NO_EXT(FBROLTQ,  FNULOLTQ)
  AS_IS_NO_EXT(FBROGEQ,  FNULOGEQ)
  AS_IS_NO_EXT(FBROQ,    FNULOQ)
  AS_IS_NO_EXT(FBRUEQQ,  FNULUEQQ)
  AS_IS_NO_EXT(FBRUNEQ,  FNULUNEQ)
  AS_IS_NO_EXT(FBRULTQ,  FNULULTQ)
  AS_IS_NO_EXT(FBRUGEQ,  FNULUGEQ)
  AS_IS_NO_EXT(FBRUQ,    FNULUQ)

// XX - short/long branch reg-imm branches convert to corresponding short/long nullifications
#define AS_IS_EXT(BCOND, NCOND)                                                                     \
  case POSTRISC::BCOND:        swap_args = false; swap_blocks = false; return POSTRISC::NCOND;      \
  case POSTRISC::BCOND##_EXT:  swap_args = false; swap_blocks = false; return POSTRISC::NCOND##_EXT;

  AS_IS_EXT(BRMALLD,     NULMALLD)
  AS_IS_EXT(BRMNOTALLD,  NULMNOTALLD)
  AS_IS_EXT(BRMNONED,    NULMNONED)
  AS_IS_EXT(BRMANYD,     NULMANYD)

  AS_IS_EXT(BRMALLW,     NULMALLW)
  AS_IS_EXT(BRMNOTALLW,  NULMNOTALLW)
  AS_IS_EXT(BRMNONEW,    NULMNONEW)
  AS_IS_EXT(BRMANYW,     NULMANYW)

  AS_IS_EXT(BRMALLQ,     NULMALLQ)
  AS_IS_EXT(BRMNOTALLQ,  NULMNOTALLQ)
  AS_IS_EXT(BRMNONEQ,    NULMNONEQ)
  AS_IS_EXT(BRMANYQ,     NULMANYQ)

  AS_IS_EXT(BREQIW,  NULEQIW)
  AS_IS_EXT(BREQID,  NULEQID)
  AS_IS_EXT(BREQIQ,  NULEQIQ)
  AS_IS_EXT(BRNEIW,  NULNEIW)
  AS_IS_EXT(BRNEID,  NULNEID)
  AS_IS_EXT(BRNEIQ,  NULNEIQ)

  AS_IS_EXT(BRLTSIW, NULLTSIW)
  AS_IS_EXT(BRLTSID, NULLTSID)
  AS_IS_EXT(BRLTSIQ, NULLTSIQ)
  AS_IS_EXT(BRLTUIW, NULLTUIW)
  AS_IS_EXT(BRLTUID, NULLTUID)
  AS_IS_EXT(BRLTUIQ, NULLTUIQ)
  AS_IS_EXT(BRGESIW, NULGESIW)
  AS_IS_EXT(BRGESID, NULGESID)
  AS_IS_EXT(BRGESIQ, NULGESIQ)
  AS_IS_EXT(BRGEUIW, NULGEUIW)
  AS_IS_EXT(BRGEUID, NULGEUID)
  AS_IS_EXT(BRGEUIQ, NULGEUIQ)

  default:
    LLVM_DEBUG(dbgs() << "The branch instruction without nullification analog! Opc=" << Opc << "\n");
    llvm_unreachable("The branch instruction without nullification analog!");
    return -1;
  }
}

namespace llvm {
  void initializePostriscNullificationPass(PassRegistry &);
} // namespace llvm

namespace {
  class PostriscNullification : public MachineFunctionPass {
  public:
    static char ID;
    const PostriscInstrInfo *TII;

    PostriscNullification() : MachineFunctionPass(ID) {}

    bool runOnMachineFunction(MachineFunction &MF) override;

    StringRef getPassName() const override {
      return PASS_NAME;
    }
  private:
    bool InsertPredInstructions(MachineBasicBlock *MBB);
    bool onePass(MachineFunction &MF);
    bool ExamineBranch(MachineBasicBlock *Head,
                MachineBasicBlock *&TBB, MachineBasicBlock *&FBB,
                SmallVector<MachineOperand, 4> &Cond);
    int checkBlock(MachineBasicBlock *MBB);
    bool Convert(MachineBasicBlock *Head,
                 MachineBasicBlock *Succ0, MachineBasicBlock *Succ1,
                 MachineBasicBlock *Tail);
  };
  char PostriscNullification::ID = 0;
} // end anonymous namespace

INITIALIZE_PASS(PostriscNullification, DEBUG_TYPE, PASS_NAME, false, false)

static void dumpFunc(MachineFunction &MF, const char *what) {
  LLVM_DEBUG(
  dbgs() << "\n" << what << "\n";
    for (auto &MBB : MF) {
      dbgs() << MBB;
  });
}

static void dumpMBB(MachineBasicBlock *MBB, const char *what) {
  LLVM_DEBUG(
    dbgs() << "\n" << what << ": " << MBB->getParent()->getName() << "\n";
    MBB->dump();
    dbgs() << "\n";
  );
}

// Returns true if branch can be changed to a predicate
bool PostriscNullification::ExamineBranch(MachineBasicBlock *Head,
                MachineBasicBlock *&TBB, MachineBasicBlock *&FBB,
                SmallVector<MachineOperand, 4> &Cond) {

  Cond.clear();
  TBB = nullptr;
  FBB = nullptr;
  // Analyze the branching code at the end of MBB, returning true if it cannot be understood
  if (TII->analyzeBranch(*Head, TBB, FBB, Cond, false)) {
    LLVM_DEBUG(dbgs() << "Branch not analyzable.\n");
    return false;
  }
  if (!TBB) { // This is weird, probably some sort of degenerate CFG.
    LLVM_DEBUG(dbgs() << "AnalyzeBranch didn't find conditional branch.\n");
    return false;
  }
  // Make sure the analyzed branch is conditional; one of the successors
  // could be a landing pad. (Empty landing pads can be generated on Windows.)
  if (Cond.empty()) {
    LLVM_DEBUG(dbgs() << "AnalyzeBranch found an unconditional branch.\n");
    return false;
  }
  if (FBB) {
    if (FBB == Head->getFallThrough()) {
      LLVM_DEBUG(dbgs() << "cond/uncond branch pair, uncond branch to fallthru\n");
      MachineBasicBlock::iterator I = Head->getLastNonDebugInstr();
      I->eraseFromParent(); // Remove the branch.
    }
  } else {
    FBB = Head->getFallThrough();
  }
  // LLVM_DEBUG(dbgs() << "Branch analyzed\n");
  return true;
}

// Count how many valid instructions can be predicated.
// If theres a call that is not at the end, return 0.
// Any branch should be at the end.
int PostriscNullification::checkBlock(MachineBasicBlock *MBB) {
  int NumInstrs = 0;

  for (const MachineInstr &MI : MBB->instrs()) {
    unsigned const Opc = MI.getOpcode();
    // currently we can't properly count possible NOPs before long instruction
    if (TII->isLong(Opc)) {
      return -1;
    }
    switch (Opc) {
    case TargetOpcode::CFI_INSTRUCTION:
    case TargetOpcode::MEMBARRIER:
    case TargetOpcode::EH_LABEL:
    case TargetOpcode::IMPLICIT_DEF:
    // special codegened NOP, trick to avoid nullification for MBB in tests
    case POSTRISC::NUL_NEVER:
    case POSTRISC::NUL_NEVER_EXT:
    // FIXME - why are CFI_INSTRUCTIONs in the code?
    // answer: because of tail merged RETs
      return -1;  // continue;
    default:
      break;
    }
    if (MI.isTerminator()) {
       //if (&MI == MBB->getFirstTerminator()) {
         return NumInstrs;
       //}
    }
    // calls are not nullificable
    //if (MI.isCall() || MI.isBranch() || MI.isTerminator())
    //  return -1;
    ++NumInstrs;
    if (NumInstrs > maxArchNullificationBlockSize())
      return -1;
  }
  return NumInstrs;
}

bool PostriscNullification::Convert(MachineBasicBlock *Head,
                        MachineBasicBlock *Succ0, MachineBasicBlock *Succ1,
                        MachineBasicBlock *Tail) {
  MachineBasicBlock *TBB, *FBB;
  SmallVector<MachineOperand, 4> Cond;
  // LLVM_DEBUG(dbgs() << "PostriscNullification::Convert\n");
  if (!ExamineBranch(Head, TBB, FBB, Cond))
    return false;
  // AnalyzeBranch doesn't set FBB on a fall-through branch.
  FBB = TBB == Succ0 ? Succ1 : Succ0;

  // See how many instructions we can shadow
  int ninstrsT, ninstrsF;
  if (TBB == Tail)
    ninstrsT = 0;
  else
    ninstrsT = checkBlock(TBB);
  if (FBB == Tail)
    ninstrsF = 0;
  else
    ninstrsF = checkBlock(FBB);

  LLVM_DEBUG(dbgs() << "Tail" << printMBBReference(*Tail)
                    << " TBB(" << ninstrsT << ") " << printMBBReference(*TBB)
                    << " FBB(" << ninstrsF << ") " << printMBBReference(*FBB) << '\n');

  if (ninstrsT < 0 || ninstrsF < 0 ||   // unpredicatable instructions
     (ninstrsT == 0 && ninstrsF == 0) ||
      ninstrsT > maxArchNullificationBlockSize() || ninstrsF > maxArchNullificationBlockSize()) {
    LLVM_DEBUG(dbgs() << "Cannot convert: T=" << ninstrsT << " F=" << ninstrsF << "\n");
    return false;
  }

  MachineBasicBlock::iterator IP = Head->getFirstTerminator();
  DebugLoc dl = IP->getDebugLoc();

  assert(Cond[0].isImm());
  const int brop = Cond[0].getImm();
  // LLVM_DEBUG(dbgs() << "Opc=" << brop << "\n");
  bool swap_args = false;
  bool swap_blocks = false;
  const int nulOp = getNullificationOpc(brop, swap_args, swap_blocks);
  if (nulOp < 0)
    return false;

    LLVM_DEBUG(
      // dbgs() << "\n\nPostriscNullification::runOnMachineFunction=" << Head->getParent()->getName() << "\n";
      // dumpFunc(*Head->getParent(), "*** Original basic blocks ***");
    );

  if (swap_args) {
    // opc ra, rb, bb <=> opcOpp rb, ra, bb
    assert(Cond[1].isReg() && "invalid cond MachineOperand r1");
    assert(Cond[2].isReg() && "invalid cond MachineOperand r2");
    LLVM_DEBUG(dbgs() << "reverseBranchCondition SWAP regs: " << Cond[1] << " " << Cond[2] << "\n");
    std::swap(Cond[1], Cond[2]);
  }

  LLVM_DEBUG(dumpMBB(Head, "Head"));

  // Create the predicate instruction
  MachineInstrBuilder MIB = BuildMI(*Head, IP, dl, TII->get(nulOp));
  for (unsigned i = 1; i < Cond.size(); ++i) {
    assert((Cond[i].isImm() || Cond[i].isReg()) && "Cannot copy operand for conditional nullification!");
    MIB.add(Cond[i]);
    // LLVM_DEBUG(dbgs() << "after MIB.Add\n");
  }

  if (swap_blocks) {
    MIB.addImm(ninstrsT);
    MIB.addImm(ninstrsF);
  } else {
    MIB.addImm(ninstrsF);
    MIB.addImm(ninstrsT);
  }

  // Move all instructions into Head, except for the terminators.
  if (swap_blocks) {
    if (TBB != Tail) {
      LLVM_DEBUG(dumpMBB(TBB, "TBB (merged 1st)"));
      Head->splice(IP, TBB, TBB->begin(), TBB->getFirstTerminator());
    }
    if (FBB != Tail) {
      LLVM_DEBUG(dumpMBB(FBB, "FBB (merged 2nd)"));
      Head->splice(IP, FBB, FBB->begin(), FBB->getFirstTerminator());
    }
  } else {
    if (FBB != Tail) {
      LLVM_DEBUG(dumpMBB(FBB, "FBB (merged 1st)"));
      Head->splice(IP, FBB, FBB->begin(), FBB->getFirstTerminator());
    }
    if (TBB != Tail) {
      LLVM_DEBUG(dumpMBB(TBB, "TBB (merged 2nd)"));
      Head->splice(IP, TBB, TBB->begin(), TBB->getFirstTerminator());
    }
  }

  // LLVM_DEBUG(dumpMBB(Head, "Head (merged)"));

  // Are there extra Tail predecessors?
  bool ExtraPreds = Tail->pred_size() != 2;

  // Fix up the CFG, temporarily leave Head without any successors.
  Head->removeSuccessor(TBB);
  Head->removeSuccessor(FBB, true);
  if (TBB != Tail)
    TBB->removeSuccessor(Tail, true);
  if (FBB != Tail)
    FBB->removeSuccessor(Tail, true);

  // Fix up Head's terminators.
  // It should become a single branch or a fallthrough.
  DebugLoc HeadDL = Head->getFirstTerminator()->getDebugLoc();
  // LLVM_DEBUG(dumpMBB(Head, "remove branch from Head"));
  TII->removeBranch(*Head);
  // LLVM_DEBUG(dumpMBB(Head, "Head (removed branch)"));

  if (Head->getFirstTerminator() != nullptr && Head->getFirstTerminator() != Head->end()) {
    LLVM_DEBUG(dumpMBB(Head, "Head: perhaps 2 branches were in head?"));
  }

  // Erase the now empty conditional blocks. It is likely that Head can fall
  // through to Tail, and we can join the two blocks.
  if (TBB != Tail) {
    TBB->eraseFromParent();
  }
  if (FBB != Tail) {
    FBB->eraseFromParent();
  }

  LLVM_DEBUG(dumpMBB(Tail, "Tail"));

  assert(Head->succ_empty() && "Additional head successors?");
  if (!ExtraPreds && Head->isLayoutSuccessor(Tail)) {
    // Splice Tail onto the end of Head.
    LLVM_DEBUG(dbgs() << "joining tail " << printMBBReference(*Tail)
                      << " into head " << printMBBReference(*Head) << '\n');
    Head->splice(Head->end(), Tail, Tail->begin(), Tail->end());
    Head->transferSuccessors(Tail);
    Tail->eraseFromParent();

    LLVM_DEBUG(dumpMBB(Head, "Head (tail merged)"));
  } else {
    // We need a branch to Tail, let code placement work it out later.
    // LLVM_DEBUG(dbgs() << "converting to unconditional branch\n");
    SmallVector<MachineOperand, 0> EmptyCond;
    TII->insertBranch(*Head, Tail, nullptr, EmptyCond, HeadDL);
    Head->addSuccessor(Tail);
    LLVM_DEBUG(dumpMBB(Head, "Head (branch to tail inserted)"));
  }
//  MakeBundle(Head, MIB, ninstrsT+ninstrsF);
  return true;
}

bool PostriscNullification::InsertPredInstructions(MachineBasicBlock *Head) {
  LLVM_DEBUG(dbgs() << "PostriscNullification::InsertPredInstructions "
                    << printMBBReference(*Head) << '\n');
  bool Modified = false;
  // 2 successors for triangle or diamond
  if (Head->succ_size() != 2)
    return false;
  MachineBasicBlock *Tail = nullptr;
  MachineBasicBlock *Succ0 = Head->succ_begin()[0];
  MachineBasicBlock *Succ1 = Head->succ_begin()[1];

  // Canonicalize so Succ0 has Head as its single predecessor.
  if (Succ0->pred_size() != 1) {
    //LLVM_DEBUG(dbgs() << "swapped arms\n");
    std::swap(Succ0, Succ1);
  }
  //LLVM_DEBUG(dbgs() << "Succ0: " << printMBBReference(*Succ0) <<
  //   " #P=" << Succ0->pred_size() << " #S=" << Succ0->succ_size() << '\n');
  //LLVM_DEBUG(dbgs() << "Succ1: " << printMBBReference(*Succ1) <<
  //   " #P=" << Succ1->pred_size() << " #S=" << Succ1->succ_size() << '\n');
  if (Succ0->pred_size() != 1)
    return false;

  if (Succ0->succ_size() == 1) { // Could be simple triangle or diamond
    Tail = Succ0->succ_begin()[0];
    //LLVM_DEBUG(dbgs() << "Tail:  " << printMBBReference(*Tail) << '\n');
    if (Tail == Succ1) {
      LLVM_DEBUG(dbgs() << "Triangle\n");
    } else {
      // Check for a diamond. We won't deal with any critical edges.
      if (Succ1->pred_size() == 1 && Succ1->succ_size() == 1 &&
          Succ1->succ_begin()[0] == Tail) {
          LLVM_DEBUG(dbgs() << "Diamond\n");
      } else {
        return false;
      }
    }
    // We have a simple triangle or diamond
    Modified = Convert(Head, Succ0, Succ1, Tail);
    if (Modified) NumPREDs += 1;
  }
  return Modified;
}


bool PostriscNullification::onePass(MachineFunction &MF) {
  // If we did any inserts, blocks may have been deleted so
  // we must start at the beginning again.
  for (auto &MBB : MF) {
    if (InsertPredInstructions(&MBB))
      return true;
  }
  return false;
}

bool PostriscNullification::runOnMachineFunction(MachineFunction &MF) {
  if (!EnableNullify) {
     return false;
  }
  TII = MF.getSubtarget<PostriscSubtarget>().getInstrInfo();

  bool Modified = false;
  while (onePass(MF)) {
    Modified = true;
    // LLVM_DEBUG(dumpFunc(MF, "*** Modified basic blocks ***"));
  }
  if (Modified) {
    // LLVM_DEBUG(dumpFunc(MF, "*** Final modified basic blocks ***"));
    MF.getRegInfo().invalidateLiveness();
  }
  return Modified;
}

/// createPostriscNullification - Returns an instance of the PostriscNullification
/// insertion pass.
FunctionPass *llvm::createPostriscNullificationPass() { return new PostriscNullification(); }
