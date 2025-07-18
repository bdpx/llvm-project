//===-- PostriscISelDAGToDAG.cpp - A dag to dag inst selector for Postrisc ------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file defines an instruction selector for the POSTRISC target.
//
//===----------------------------------------------------------------------===//

#include "PostriscSelectionDAGInfo.h"
#include "PostriscTargetMachine.h"
#include "PostriscMachineFunctionInfo.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/CodeGen/SelectionDAGISel.h"
#include "llvm/IR/Intrinsics.h"
#include "llvm/IR/Type.h"
#include "llvm/ADT/Statistic.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/raw_ostream.h"
using namespace llvm;

#define DEBUG_TYPE "postrisc-isel"
#define PASS_NAME "POSTRISC DAG->DAG Pattern Instruction Selection"

STATISTIC(NumLoadMoved, "Number of loads moved below TokenFactor");

//===----------------------------------------------------------------------===//
// Instruction Selector Implementation
//===----------------------------------------------------------------------===//

//===--------------------------------------------------------------------===//
/// PostriscDAGToDAGISel - POSTRISC specific code to select POSTRISC machine
/// instructions for SelectionDAG operations.
///
namespace {
class PostriscDAGToDAGISel : public SelectionDAGISel {
  /// Subtarget - Keep a pointer to the Postrisc Subtarget around so that we can
  /// make the right decision when generating code for different targets.
  const PostriscSubtarget *Subtarget = nullptr;

public:
  PostriscDAGToDAGISel() = delete;

  explicit PostriscDAGToDAGISel(PostriscTargetMachine &tm) : SelectionDAGISel(tm) {}

  bool runOnMachineFunction(MachineFunction &MF) override {
    Subtarget = &MF.getSubtarget<PostriscSubtarget>();
    return SelectionDAGISel::runOnMachineFunction(MF);
  }

  void Select(SDNode *N) override;
  void PreprocessISelDAG() override;

  /// Return a target constant with the specified value, of type i32.
  inline SDValue getI32Imm(signed Imm, const SDLoc &DL) {
    return CurDAG->getSignedTargetConstant(Imm, DL, MVT::i32);
  }

  /// Return a target constant with the specified value, of type i64.
  inline SDValue getI64Imm(int64_t Imm, const SDLoc &DL) {
    return CurDAG->getSignedTargetConstant(Imm, DL, MVT::i64);
  }

  inline bool isSextInt(const APInt &Imm, unsigned nbits) const {
      return Imm.getSignificantBits() <= nbits; // APInt signed len
  }
  inline bool isZextInt(const APInt &Imm, unsigned nbits) const {
      return Imm.getActiveBits() <= nbits;  // APInt unsigned len
  }

  // getImm - Return a target constant with the specified value.
  inline SDValue getUnsignedConstant(const SDNode *Node, uint64_t Imm) {
    return CurDAG->getTargetConstant(Imm, SDLoc(Node), Node->getValueType(0));
  }

  // Complex Pattern Selectors.
  bool SelectAddrFI(SDValue Addr, SDValue &Base);

  /// SelectInlineAsmMemoryOperand - Implement addressing mode selection for
  /// inline asm expressions.
  bool SelectInlineAsmMemoryOperand(const SDValue &Op,
                                    InlineAsm::ConstraintCode ConstraintID,
                                    std::vector<SDValue> &OutOps) override;

  // Include the pieces autogenerated from the target description.
#include "PostriscGenDAGISel.inc"

private:
  bool tryInlineAsm(SDNode *N);
};

class PostriscDAGToDAGISelLegacy : public SelectionDAGISelLegacy {
public:
  static char ID;
  explicit PostriscDAGToDAGISelLegacy(PostriscTargetMachine &tm)
      : SelectionDAGISelLegacy(ID, std::make_unique<PostriscDAGToDAGISel>(tm)) {}
};
}  // end anonymous namespace

char PostriscDAGToDAGISelLegacy::ID = 0;

INITIALIZE_PASS(PostriscDAGToDAGISelLegacy, DEBUG_TYPE, PASS_NAME, false, false)

// Re-assemble i64 arguments split up in SelectionDAGBuilder's
// visitInlineAsm / GetRegistersForValue functions.
//
// Note: This function was copied from, and is essentially identical
// to ARMISelDAGToDAG::SelectInlineAsm. It is very unfortunate that
// such hacking-up is necessary; a rethink of how inline asm operands
// are handled may be in order to make doing this more sane.
//
// TODO: fix inline asm support so I can simply tell it that 'i64'
// inputs to asm need to be allocated to the IntPair register type,
// and have that work. Then, delete this function.
bool PostriscDAGToDAGISel::tryInlineAsm(SDNode *N){
  LLVM_DEBUG(dbgs() << "tryInlineAsm: N="; N->dump());
  std::vector<SDValue> AsmNodeOperands;
  InlineAsm::Flag Flag;
  bool Changed = false;
  unsigned NumOps = N->getNumOperands();

  // Normally, i64 data is bounded to two arbitrary GPRs for "%r"
  // constraint.  However, some instructions (e.g. ldd/std) require
  // (even/even+1) GPRs.

  // So, here, we check for this case, and mutate the inlineasm to use
  // a single IntPair register instead, which guarantees such even/odd
  // placement.

  SDLoc dl(N);
  SDValue Glue = N->getGluedNode() ? N->getOperand(NumOps - 1) : SDValue();

  SmallVector<bool, 8> OpChanged;
  // Glue node will be appended late.
  for(unsigned i = 0, e = N->getGluedNode() ? NumOps - 1 : NumOps; i < e; ++i) {
    SDValue op = N->getOperand(i);
    LLVM_DEBUG(dbgs() << "tryInlineAsm: op="; op.dump());
    AsmNodeOperands.push_back(op);

    if (i < InlineAsm::Op_FirstOperand)
      continue;

    if (const auto *C = dyn_cast<ConstantSDNode>(N->getOperand(i)))
      Flag = InlineAsm::Flag(C->getZExtValue());
    else
      continue;

    // Immediate operands to inline asm in the SelectionDAG are modeled with
    // two operands. The first is a constant of value InlineAsm::Kind::Imm, and
    // the second is a constant with the value of the immediate. If we get here
    // and we have a Kind::Imm, skip the next operand, and continue.
    if (Flag.isImmKind()) {
      SDValue op = N->getOperand(++i);
      LLVM_DEBUG(dbgs() << "tryInlineAsm: Kind_Imm:"; op.dump());
      AsmNodeOperands.push_back(op);
      continue;
    }

    const unsigned NumRegs = Flag.getNumOperandRegisters();
    if (NumRegs)
      OpChanged.push_back(false);


    if (!Flag.isRegUseKind() && !Flag.isRegDefKind() &&
        !Flag.isRegDefEarlyClobberKind())
      continue;

    //unsigned RC;
    //bool HasRC = InlineAsm::hasRegClassConstraint(Flag, RC);
  }

  if (Glue.getNode())
    AsmNodeOperands.push_back(Glue);
  if (!Changed)
  {
    LLVM_DEBUG(dbgs() << "tryInlineAsm: !Changed" << "\n");
    return false;
  }

  SelectInlineAsmMemoryOperands(AsmNodeOperands, SDLoc(N));

  LLVM_DEBUG(dbgs() << "tryInlineAsm:  N->getOpcode()=" << N->getOpcode() << "\n");
  SDValue New = CurDAG->getNode(N->getOpcode(), SDLoc(N),
      CurDAG->getVTList(MVT::Other, MVT::Glue), AsmNodeOperands);
  New->setNodeId(-1);
  ReplaceNode(N, New.getNode());
  return true;
}

void PostriscDAGToDAGISel::Select(SDNode *N) {
  SDLoc dl(N);
  if (N->isMachineOpcode()) {
    N->setNodeId(-1);
    return;   // Already selected.
  }

  switch (N->getOpcode()) {
  default: break;
  case ISD::INLINEASM:
  case ISD::INLINEASM_BR: {
    if (tryInlineAsm(N))
      return;
    break;
  }
  }

  SelectCode(N);
}

/// Replace the original chain operand of the call with
/// load's chain operand and move load below the call's chain operand.
static void
moveBelowOrigChain(
  SelectionDAG *CurDAG, SDValue Load, SDValue Call, SDValue OrigChain)
{
  SmallVector<SDValue, 8> Ops;
  SDValue Chain = OrigChain.getOperand(0);
  if (Chain.getNode() == Load.getNode())
    Ops.push_back(Load.getOperand(0));
  else {
    assert(Chain.getOpcode() == ISD::TokenFactor &&
           "Unexpected chain operand");
    for (unsigned i = 0, e = Chain.getNumOperands(); i != e; ++i)
      if (Chain.getOperand(i).getNode() == Load.getNode())
        Ops.push_back(Load.getOperand(0));
      else
        Ops.push_back(Chain.getOperand(i));
    SDValue NewChain =
      CurDAG->getNode(ISD::TokenFactor, SDLoc(Load), MVT::Other, Ops);
    Ops.clear();
    Ops.push_back(NewChain);
  }
  Ops.append(OrigChain->op_begin() + 1, OrigChain->op_end());
  CurDAG->UpdateNodeOperands(OrigChain.getNode(), Ops);
  CurDAG->UpdateNodeOperands(Load.getNode(), Call.getOperand(0),
                             Load.getOperand(1), Load.getOperand(2));

  Ops.clear();
  Ops.push_back(SDValue(Load.getNode(), 1));
  Ops.append(Call->op_begin() + 1, Call->op_end());
  CurDAG->UpdateNodeOperands(Call.getNode(), Ops);
}

/// TODO: add preprocess for CALL(ADD+LOAD), similar to CALL(LOAD) for callrvt instruction

/// Return true if call address is a load and it can be
/// moved below CALLSEQ_START and the chains leading up to the call.
/// Return the CALLSEQ_START by reference as a second output.
/// In the case of a tail call, there isn't a callseq node between the call
/// chain and the load.
static bool
isCalleeLoad(SDValue Callee, SDValue &Chain, bool HasCallSeq)
{
  // The transformation is somewhat dangerous if the call's chain was glued to
  // the call. After MoveBelowOrigChain the load is moved between the call and
  // the chain, this can create a cycle if the load is not folded. So it is
  // *really* important that we are sure the load will be folded.
  if (Callee.getNode() == Chain.getNode() || !Callee.hasOneUse())
    return false;
  LoadSDNode *LD = dyn_cast<LoadSDNode>(Callee.getNode());
  if (!LD ||
      !LD->isSimple() ||
      LD->getAddressingMode() != ISD::UNINDEXED ||
      LD->getExtensionType() != ISD::NON_EXTLOAD)
    return false;

  // Now let's find the callseq_start.
  while (HasCallSeq && Chain.getOpcode() != ISD::CALLSEQ_START) {
    if (!Chain.hasOneUse())
      return false;
    Chain = Chain.getOperand(0);
  }

  if (!Chain.getNumOperands())
    return false;
  // Since we are not checking for AA here, conservatively abort if the chain
  // writes to memory. It's not safe to move the callee (a load) across a store.
  if (isa<MemSDNode>(Chain.getNode()) &&
      cast<MemSDNode>(Chain.getNode())->writeMem())
    return false;
  if (Chain.getOperand(0).getNode() == Callee.getNode())
    return true;
  if (Chain.getOperand(0).getOpcode() == ISD::TokenFactor &&
      Callee.getValue(1).isOperandOf(Chain.getOperand(0).getNode()) &&
      Callee.getValue(1).hasOneUse())
    return true;
  return false;
}

void
PostriscDAGToDAGISel::PreprocessISelDAG()
{
  bool MadeChange = false;
  for (SelectionDAG::allnodes_iterator I = CurDAG->allnodes_begin(),
       E = CurDAG->allnodes_end(); I != E; ) {
    SDNode *N = &*I++; // Preincrement iterator to avoid invalidation issues.

    if (OptLevel != CodeGenOptLevel::None &&
        // Only do this when the target can fold the load into the call or
        // jmp.
        (N->getOpcode() == PostriscISD::CALL)) {
      /// Also try moving call address load from outside callseq_start to just
      /// before the call to allow it to be folded.
      ///
      ///     [Load chain]
      ///         ^
      ///         |
      ///       [Load]
      ///       ^    ^
      ///       |    |
      ///      /      \--
      ///     /          |
      ///[CALLSEQ_START] |
      ///     ^          |
      ///     |          |
      /// [LOAD/C2Reg]   |
      ///     |          |
      ///      \        /
      ///       \      /
      ///       [CALL]
      bool HasCallSeq = N->getOpcode() == PostriscISD::CALL;
      SDValue Chain = N->getOperand(0);
      SDValue Load  = N->getOperand(1);
      if (!isCalleeLoad(Load, Chain, HasCallSeq))
        continue;
      moveBelowOrigChain(CurDAG, Load, SDValue(N, 0), Chain);
      ++NumLoadMoved;
      MadeChange = true;
      continue;
    }
  }

  // Remove any dead nodes that may have been left behind.
  if (MadeChange)
    CurDAG->RemoveDeadNodes();
}

bool
PostriscDAGToDAGISel::SelectAddrFI(SDValue Addr, SDValue &Base)
{
  if (auto FIN = dyn_cast<FrameIndexSDNode>(Addr)) {
    MachineFunction &MF = CurDAG->getMachineFunction();
    LLVM_DEBUG(dbgs() << "SelectAddrFI: FI=" << FIN->getIndex()
                      << " MF=" << MF.getName() << "\n");
    Base = CurDAG->getTargetFrameIndex(FIN->getIndex(),
                                       TLI->getPointerTy(CurDAG->getDataLayout()));
    return true;
  }
  return false;
}

/// SelectInlineAsmMemoryOperand - Implement addressing mode selection for
/// inline asm expressions.
bool PostriscDAGToDAGISel::SelectInlineAsmMemoryOperand(
    const SDValue &Op, InlineAsm::ConstraintCode ConstraintID,
    std::vector<SDValue> &OutOps) {
  // FIXME
  LLVM_DEBUG(dbgs() << "SelectInlineAsmMemoryOperand\n"; Op.dump());

  switch (ConstraintID) {
  default: return true;
  case InlineAsm::ConstraintCode::o:
  case InlineAsm::ConstraintCode::m: // memory
    // We just support simple memory operands that have a single address
    // operand and need no special handling.
    OutOps.push_back(Op);
    return false;
  case InlineAsm::ConstraintCode::A:
    OutOps.push_back(Op);
    return false;
  }
  return true;
}

/// createPostriscISelDag - This pass converts a legalized DAG into a
/// POSTRISC-specific DAG, ready for instruction scheduling.
///
FunctionPass *llvm::createPostriscISelDag(PostriscTargetMachine &TM) {
  return new PostriscDAGToDAGISelLegacy(TM);
}
