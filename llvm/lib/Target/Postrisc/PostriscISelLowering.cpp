//===-- PostriscISelLowering.cpp - Postrisc DAG Lowering Implementation ---------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements the interfaces that Postrisc uses to lower LLVM code into a
// selection DAG.
//
//===----------------------------------------------------------------------===//

#include "PostriscISelLowering.h"
#include "PostriscCallingConv.h"
#include "MCTargetDesc/PostriscMCExpr.h"
#include "PostriscMachineFunctionInfo.h"
#include "PostriscRegisterInfo.h"
#include "PostriscTargetMachine.h"
#include "PostriscTargetObjectFile.h"
#include "llvm/ADT/StringExtras.h"
#include "llvm/ADT/StringSwitch.h"
#include "llvm/CodeGen/CallingConvLower.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineJumpTableInfo.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/CodeGen/SelectionDAG.h"
#include "llvm/CodeGen/SelectionDAGNodes.h"
#include "llvm/CodeGen/TargetLoweringObjectFileImpl.h"
#include "llvm/IR/DerivedTypes.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/IntrinsicsPostrisc.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/KnownBits.h"
#include "llvm/Support/Debug.h"

#define DEBUG_TYPE "postrisc-isellowering"

using namespace llvm;

/// Selects the correct CCAssignFn for a given CallingConvention value.
CCAssignFn *
PostriscTargetLowering::CCAssignFnForCall(CallingConv::ID CC, bool IsVarArg) const {
  switch (CC) {
  default:
    report_fatal_error("Unsupported calling convention.");
  case CallingConv::C:
  case CallingConv::Fast:
      return CC_Postrisc_C;
  }
}

CCAssignFn *
PostriscTargetLowering::CCAssignFnForReturn(CallingConv::ID CC, bool IsVarArg) const {
  switch (CC) {
  default:
    report_fatal_error("Unsupported calling convention.");
  case CallingConv::C:
  case CallingConv::Fast:
    return RetCC_Postrisc_C;
  }
}

bool PostriscTargetLowering::CanLowerReturn(
    CallingConv::ID CallConv, MachineFunction &MF, bool isVarArg,
    const SmallVectorImpl<ISD::OutputArg> &Outs, LLVMContext &Context) const {
  SmallVector<CCValAssign, 16> RVLocs;
  CCState CCInfo(CallConv, isVarArg, MF, RVLocs, Context);
  return CCInfo.CheckReturn(Outs, CCAssignFnForReturn(CallConv, isVarArg));
}

// Lower return values for the 64-bit ABI.
// Return values are passed the exactly the same way as function arguments.
SDValue
PostriscTargetLowering::LowerReturn(SDValue Chain, CallingConv::ID CallConv,
                                    bool IsVarArg,
                                    const SmallVectorImpl<ISD::OutputArg> &Outs,
                                    const SmallVectorImpl<SDValue> &OutVals,
                                    const SDLoc &DL, SelectionDAG &DAG) const {
  // CCValAssign - represent the assignment of the return value to locations.
  SmallVector<CCValAssign, 16> RVLocs;

  // CCState - Info about the registers and stack slot.
  CCState CCInfo(CallConv, IsVarArg, DAG.getMachineFunction(), RVLocs,
                 *DAG.getContext());

  // Analyze return values.
  CCInfo.AnalyzeReturn(Outs, CCAssignFnForReturn(CallConv, IsVarArg));

  SDValue Glue;
  SmallVector<SDValue, 4> RetOps(1, Chain);

  // The operand on the RETF instruction is the SP rollback (updated later in framelowering).
  RetOps.push_back(DAG.getConstant(0, DL, MVT::i64));

  // Copy the result values into the output registers.
  for (unsigned i = 0; i != RVLocs.size(); ++i) {
    CCValAssign &VA = RVLocs[i];
    assert(VA.isRegLoc() && "Can only return in registers!");
    SDValue OutVal = OutVals[i];

    // Integer return values must be sign or zero extended by the callee.
    switch (VA.getLocInfo()) {
    case CCValAssign::Full: break;
    case CCValAssign::SExt:
      OutVal = DAG.getNode(ISD::SIGN_EXTEND, DL, VA.getLocVT(), OutVal);
      break;
    case CCValAssign::ZExt:
      OutVal = DAG.getNode(ISD::ZERO_EXTEND, DL, VA.getLocVT(), OutVal);
      break;
    case CCValAssign::AExt:
      OutVal = DAG.getNode(ISD::ANY_EXTEND, DL, VA.getLocVT(), OutVal);
      break;
    default:
      LLVM_DEBUG(dbgs() << "VA.getLocInfo()=" << VA.getLocInfo() << "\n");
      llvm_unreachable("Unknown loc info!");
    }

    // The custom bit on an i32 return value indicates that it should be passed
    // in the high bits of the register.
    if (VA.getValVT() == MVT::i32 && VA.needsCustom()) {
      assert(0 && "LowerReturn: needsCustom");
      OutVal = DAG.getNode(ISD::SHL, DL, MVT::i64, OutVal,
                           DAG.getConstant(32, DL, MVT::i32));

      // The next value may go in the low bits of the same register.
      // Handle both at once.
      if (i+1 < RVLocs.size() && RVLocs[i+1].getLocReg() == VA.getLocReg()) {
        SDValue NV = DAG.getNode(ISD::ZERO_EXTEND, DL, MVT::i64, OutVals[i+1]);
        OutVal = DAG.getNode(ISD::OR, DL, MVT::i64, OutVal, NV);
        // Skip the next value, it's already done.
        ++i;
      }
    }

    Chain = DAG.getCopyToReg(Chain, DL, VA.getLocReg(), OutVal, Glue);

    // Guarantee that all emitted copies are stuck together with flags.
    Glue = Chain.getValue(1);
    RetOps.push_back(DAG.getRegister(VA.getLocReg(), VA.getLocVT()));
  }

  RetOps[0] = Chain;  // Update chain.

  // Add the flag if we have it.
  if (Glue.getNode())
    RetOps.push_back(Glue);

  return DAG.getNode(PostriscISD::RET_GLUE, DL, MVT::Other, RetOps);
}

SDValue PostriscTargetLowering::LowerFormalArguments(
    SDValue Chain, CallingConv::ID CallConv, bool IsVarArg,
    const SmallVectorImpl<ISD::InputArg> &Ins, const SDLoc &DL,
    SelectionDAG &DAG, SmallVectorImpl<SDValue> &InVals) const {
  MachineFunction &MF = DAG.getMachineFunction();

  SmallVector<CCValAssign, 16> ArgLocs;

  PostriscCCState CCInfo(CallConv, IsVarArg, DAG.getMachineFunction(), ArgLocs,
                         *DAG.getContext(),
                         MF.getFunction().getFunctionType()->getNumParams());
  CCInfo.AnalyzeFormalArguments(Ins, CCAssignFnForCall(CallConv, IsVarArg));

  // The argument array begins at %fp+BIAS+128, after the register save area.
  const unsigned ArgArea = 0; //128;

  for (unsigned i = 0, e = ArgLocs.size(); i != e; ++i) {
    CCValAssign &VA = ArgLocs[i];
    if (VA.isRegLoc()) {
      // This argument is passed in a register.
      // All integer register arguments are promoted by the caller to i64.

      // Create a virtual register for the promoted live-in value.
      Register VReg = MF.addLiveIn(VA.getLocReg(),
                                   getRegClassFor(VA.getLocVT()));
      SDValue Arg = DAG.getCopyFromReg(Chain, DL, VReg, VA.getLocVT());
      LLVM_DEBUG(dbgs() << "LowerFormalArguments:"
             << " MF=" << MF.getName()
             << " VA.getLocReg=" << PostriscRegisterInfo::getRegisterName(VA.getLocReg())
             << " VReg=" << format_hex(VReg, 8) << "\n");

      // Get the high bits for i32 struct elements.
      if (VA.getValVT() == MVT::i32 && VA.needsCustom()) {
        assert(0 && "LowerFormalArguments: needsCustom");
        Arg = DAG.getNode(ISD::SRL, DL, VA.getLocVT(), Arg,
                          DAG.getConstant(32, DL, MVT::i32));
      }

      // The caller promoted the argument, so insert an Assert?ext SDNode so we
      // won't promote the value again in this function.
      switch (VA.getLocInfo()) {
      case CCValAssign::SExt:
        Arg = DAG.getNode(ISD::AssertSext, DL, VA.getLocVT(), Arg,
                          DAG.getValueType(VA.getValVT()));
        break;
      case CCValAssign::ZExt:
        Arg = DAG.getNode(ISD::AssertZext, DL, VA.getLocVT(), Arg,
                          DAG.getValueType(VA.getValVT()));
        break;
      default:
        break;
      }

      // Truncate the register down to the argument type.
      if (VA.isExtInLoc())
        Arg = DAG.getNode(ISD::TRUNCATE, DL, VA.getValVT(), Arg);

      InVals.push_back(Arg);
      continue;
    }

    // The registers are exhausted. This argument was passed on the stack.
    assert(VA.isMemLoc());
    // The CC_Postrisc64_Full/Half functions compute stack offsets relative to the
    // beginning of the arguments area at %fp+BIAS+128.
    unsigned Offset = VA.getLocMemOffset() + ArgArea;
    unsigned ValSize = VA.getValVT().getSizeInBits() / 8;
    // FIXME:
    // Don't adjust offset for extended arguments, because POSTRISC is little-endian.
    // The caller will have written the full slot with extended bytes, but we
    // prefer our own extending loads.
    //if (VA.isExtInLoc())
    //  Offset += 8 - ValSize;
    int FI = MF.getFrameInfo().CreateFixedObject(ValSize, Offset, true);
    LLVM_DEBUG(dbgs() << "LowerFormalArguments(1): " << MF.getName() << " FI=" << FI << "\n");
    InVals.push_back(
        DAG.getLoad(VA.getValVT(), DL, Chain,
                    DAG.getFrameIndex(FI, getPointerTy(MF.getDataLayout())),
                    MachinePointerInfo::getFixedStack(MF, FI)));
  }


  if (!IsVarArg)
    return Chain;

  MachineFrameInfo &MFI = MF.getFrameInfo();
  PostriscMachineFunctionInfo *PostriscFI = MF.getInfo<PostriscMachineFunctionInfo>();

  uint64_t NumBytes = MFI.getStackSize();
  LLVM_DEBUG(dbgs() << "LowerFormalArguments: MF=" << MF.getName() << " NumBytes=" << NumBytes << "\n");

  // Record the frame index of the first variable argument
  // which is a value necessary to VASTART.
  int FI = MFI.CreateFixedObject(8/*bytes*/, CCInfo.getStackSize(), true);
  LLVM_DEBUG(dbgs() << "setVarArgsFrameIndex: " << MF.getName() << " " << FI << "\n");
  PostriscFI->setVarArgsFrameIndex(FI);

#define MAX_REGISTER_ARGS 0

#if 0
  // This function takes variable arguments, some of which may have been passed
  // in registers %r1-%r[MAX_REGISTER_ARGS].
  //
  // The va_start intrinsic needs to know the offset to the first variable
  // argument.
  unsigned ArgOffset = CCInfo.getStackSize();
  // Skip the 128 bytes of register save area.
  PostriscFI->setVarArgsFrameOffset(ArgOffset + ArgArea +
                                  Subtarget->getStackPointerBias());

  // Save the variable arguments that were passed in registers.
  // The caller is required to reserve stack space for MAX_REGISTER_ARGS arguments regardless
  // of how many arguments were actually passed.
  SmallVector<SDValue, MAX_REGISTER_ARGS> OutChains;
  for (; ArgOffset < MAX_REGISTER_ARGS * 16; ArgOffset += 16) {
    Register VReg = MF.addLiveIn(POSTRISC::r1 + ArgOffset/16, &POSTRISC::GRRegClass);
    SDValue VArg = DAG.getCopyFromReg(Chain, DL, VReg, MVT::i128);
    int FI = MF.getFrameInfo().CreateFixedObject(16, ArgOffset + ArgArea, true);
    auto PtrVT = getPointerTy(MF.getDataLayout());
    LLVM_DEBUG(dbgs() << "LowerFormalArguments(vararg_in_reg): " << MF.getName() << " FI=" << FI << "\n");
    SDValue Store = DAG.getStore(Chain, DL, VArg, DAG.getFrameIndex(FI, PtrVT),
                                 MachinePointerInfo::getFixedStack(MF, FI));
    OutChains.push_back(Store);
  }

  if (!OutChains.empty())
    Chain = DAG.getNode(ISD::TokenFactor, DL, MVT::Other, OutChains);
#endif

  return Chain;
}

static bool hasReturnsTwiceAttr(SelectionDAG &DAG, SDValue Callee,
                                const CallBase *Call) {
  if (Call)
    return Call->hasFnAttr(Attribute::ReturnsTwice);

  const Function *CalleeFn = nullptr;
  if (GlobalAddressSDNode *G = dyn_cast<GlobalAddressSDNode>(Callee)) {
    CalleeFn = dyn_cast<Function>(G->getGlobal());
  } else if (ExternalSymbolSDNode *E =
             dyn_cast<ExternalSymbolSDNode>(Callee)) {
    const Function &Fn = DAG.getMachineFunction().getFunction();
    const Module *M = Fn.getParent();
    const char *CalleeName = E->getSymbol();
    CalleeFn = M->getFunction(CalleeName);
  }

  if (!CalleeFn)
    return false;
  return CalleeFn->hasFnAttribute(Attribute::ReturnsTwice);
}

/// IsEligibleForTailCallOptimization - Check whether the call is eligible
/// for tail call optimization.
bool PostriscTargetLowering::IsEligibleForTailCallOptimization(
    CCState &CCInfo, CallLoweringInfo &CLI, MachineFunction &MF) const {

  auto &Outs = CLI.Outs;
  auto &Caller = MF.getFunction();

  // Do not tail call opt functions with "disable-tail-calls" attribute.
  if (Caller.getFnAttribute("disable-tail-calls").getValueAsString() == "true")
    return false;

  // Do not tail call opt if the stack is used to pass parameters.
  // 64-bit targets have a slightly higher limit since the ABI requires
  // to allocate some space even when all the parameters fit inside registers.
  unsigned StackSizeLimit = Subtarget->is64Bit() ? 48 : 0;
  if (CCInfo.getStackSize() > StackSizeLimit)
    return false;

  // Do not tail call opt if either the callee or caller returns
  // a struct and the other does not.
  if (!Outs.empty() && Caller.hasStructRetAttr() != Outs[0].Flags.isSRet())
    return false;

  // Byval parameters hand the function a pointer directly into the stack area
  // we want to reuse during a tail call.
  for (auto &Arg : Outs)
    if (Arg.Flags.isByVal())
      return false;

  return true;
}
// FIXME? Maybe this could be a TableGen attribute on some registers and
// this table could be generated automatically from RegInfo.
Register PostriscTargetLowering::getRegisterByName(const char* RegName, LLT VT,
                                                const MachineFunction &MF) const {
#define X(NAME) .Case(#NAME, POSTRISC::NAME)
  Register Reg = StringSwitch<Register>(RegName)
#define R(ID) X(r##ID)
    R(0) R(1) R(2) R(3) R(4) R(5) R(6) R(7)
    R(8) R(9) R(10) R(11) R(12) R(13) R(14) R(15)
    R(16) R(17) R(18) R(19) R(20) R(21) R(22) R(23)
    R(24) R(25) R(26) R(27) R(28) R(29) R(30) R(31)
    R(32) R(33) R(34) R(35) R(36) R(37) R(38) R(39)
    R(40) R(41) R(42) R(43) R(44) R(45) R(46) R(47)
    R(48) R(49) R(50) R(51) R(52) R(53) R(54) R(55)
    R(56) R(57) R(58) R(59) R(60) R(61) R(62) R(63)
    R(64) R(65) R(66) R(67) R(68) R(69) R(70) R(71)
    R(72) R(73) R(74) R(75) R(76) R(77) R(78) R(79)
    R(80) R(81) R(82) R(83) R(84) R(85) R(86) R(87)
    R(88) R(89) R(90) R(91) R(92) R(93) R(94) R(95)
    R(96) R(97) R(98) R(99) R(100) R(101) R(102) R(103)
    R(104) R(105) R(106) R(107) R(108) R(109) R(110) R(111)
    R(112) R(113) R(114) R(115) R(116) R(117) R(118) R(119)
#undef R
    X(g0) X(g1) X(g2) X(g3) X(tp) X(fp) X(sp) X(gz)
#undef X
    .Default(0);

  if (Reg)
    return Reg;

  report_fatal_error("Invalid register name global variable");
}

SDValue
PostriscTargetLowering::LowerCall(TargetLowering::CallLoweringInfo &CLI,
                                  SmallVectorImpl<SDValue> &InVals) const {
  SelectionDAG &DAG = CLI.DAG;
  SDLoc DL = CLI.DL;
  SDValue Chain = CLI.Chain;
  auto PtrVT = getPointerTy(DAG.getDataLayout());

  // Analyze operands of the call, assigning locations to each operand.
  SmallVector<CCValAssign, 24> ArgLocs;
  unsigned const NumParams = CLI.CB ? CLI.CB->getFunctionType()->getNumParams() : 0;
  PostriscCCState CCInfo(CLI.CallConv, CLI.IsVarArg, DAG.getMachineFunction(), ArgLocs,
                 *DAG.getContext(), NumParams);
  CCInfo.AnalyzeCallOperands(CLI.Outs, CCAssignFnForCall(CLI.CallConv, CLI.IsVarArg));

  // TODO: not work
  CLI.IsTailCall = false;
   // CLI.IsTailCall && IsEligibleForTailCallOptimization(
   //                         CCInfo, CLI, DAG.getMachineFunction());

  // Assign locations to each value returned by this call.
  SmallVector<CCValAssign, 16> RVLocs;
  CCState RVInfo(CLI.CallConv, CLI.IsVarArg, DAG.getMachineFunction(), RVLocs,
                 *DAG.getContext());

  // Set inreg flag manually for codegen generated library calls that
  // return float.
  if (CLI.Ins.size() == 1 && CLI.Ins[0].VT == MVT::f32 && !CLI.CB)
    CLI.Ins[0].Flags.setInReg();

  RVInfo.AnalyzeCallResult(CLI.Ins, CCAssignFnForReturn(CLI.CallConv, CLI.IsVarArg));
  CLI.IsTailCall = false;

  // Get the size of the outgoing arguments stack space requirement.
  unsigned StackReserved = 0; // FIXME: MAX_REGISTER_ARGS * 8u;
  unsigned ArgsSize = std::max<unsigned>(StackReserved, CCInfo.getStackSize());

  // Keep stack frames 16-byte aligned.
  ArgsSize = alignTo(ArgsSize, 16);

  assert(!CLI.IsTailCall || ArgsSize == StackReserved);

  // Adjust the stack pointer to make room for the arguments.
  // FIXME: Use hasReservedCallFrame to avoid %sp adjustments around all calls
  // with more than MAX_REGISTER_ARGS arguments.
  if (!CLI.IsTailCall)
    Chain = DAG.getCALLSEQ_START(Chain, ArgsSize, 0, DL);

  // Collect the set of registers to pass to the function and their values.
  // This will be emitted as a sequence of CopyToReg nodes glued to the call
  // instruction.
  SmallVector<std::pair<Register, SDValue>, 16> RegsToPass;

  // Collect chains from all the memory opeations that copy arguments to the
  // stack. They must follow the stack pointer adjustment above and precede the
  // call instruction itself.
  SmallVector<SDValue, 8> MemOpChains;

  // Compute how many regs is used for args/outs.
  unsigned n_used_regs = 0;
  for (unsigned i = 0, e = ArgLocs.size(); i != e; ++i) {
    if (ArgLocs[i].isRegLoc()) ++n_used_regs;
  }
  // RVLocs all should be passed in regs
  if (RVLocs.size() > n_used_regs) n_used_regs = RVLocs.size();

  unsigned const LinkRegister = CLI.IsTailCall
          ? POSTRISC::r0 + 0
          : POSTRISC::r119 - n_used_regs;
  unsigned CurrentReg = LinkRegister + 1;

  LLVM_DEBUG(dbgs() << "ArgLocs=" << ArgLocs.size()
         << " RVLocs=" << RVLocs.size()
         << " LinkRegister=" << LinkRegister << "\n");

  for (unsigned i = 0, e = ArgLocs.size(); i != e; ++i) {
    const CCValAssign &VA = ArgLocs[i];
    SDValue Arg = CLI.OutVals[i];

    // Promote the value if needed.
    switch (VA.getLocInfo()) {
    default:
      LLVM_DEBUG(dbgs() << "LowerCall: VA.getLocInfo()=" << VA.getLocInfo() << "\n");
      llvm_unreachable("Unknown location info!");
    case CCValAssign::Full:
      break;
    case CCValAssign::SExt:
      Arg = DAG.getNode(ISD::SIGN_EXTEND, DL, VA.getLocVT(), Arg);
      break;
    case CCValAssign::ZExt:
      Arg = DAG.getNode(ISD::ZERO_EXTEND, DL, VA.getLocVT(), Arg);
      break;
    case CCValAssign::AExt:
      Arg = DAG.getNode(ISD::ANY_EXTEND, DL, VA.getLocVT(), Arg);
      break;
    case CCValAssign::BCvt:
      // fixupVariableFloatArgs() may create bitcasts from f128 to i128. But
      // POSTRISC does not support i128 natively. Lower it into two i64, see below.
      if (!VA.needsCustom() || VA.getValVT() != MVT::f128
          || VA.getLocVT() != MVT::i128) {
        assert(0 && "LowerCall(1): needsCustom");
        Arg = DAG.getNode(ISD::BITCAST, DL, VA.getLocVT(), Arg);
      }
      break;
    }

    if (VA.isRegLoc()) {
      // The custom bit on an i32 return value indicates that it should be
      // passed in the high bits of the register.
      if (VA.getValVT() == MVT::i32 && VA.needsCustom()) {
        assert(0 && "LowerCall(2): needsCustom");
        Arg = DAG.getNode(ISD::SHL, DL, MVT::i64, Arg,
                          DAG.getConstant(32, DL, MVT::i32));

        // The next value may go in the low bits of the same register.
        // Handle both at once.
        if (i+1 < ArgLocs.size() && ArgLocs[i+1].isRegLoc() &&
            ArgLocs[i+1].getLocReg() == VA.getLocReg()) {
          SDValue NV = DAG.getNode(ISD::ZERO_EXTEND, DL, MVT::i64,
                                   CLI.OutVals[i+1]);
          Arg = DAG.getNode(ISD::OR, DL, MVT::i64, Arg, NV);
          // Skip the next value, it's already done.
          ++i;
        }
      }
      LLVM_DEBUG(dbgs() << " in-arg old=" << PostriscRegisterInfo::getRegisterName(VA.getLocReg())
             << " new=" << PostriscRegisterInfo::getRegisterName(CurrentReg) << "\n");

      RegsToPass.push_back(std::make_pair(CurrentReg, Arg));
      ++CurrentReg;
      continue;
    }

    assert(VA.isMemLoc());

    // Create a store off the stack pointer for this argument.
    SDValue StackPtr = DAG.getRegister(POSTRISC::sp, PtrVT);
    // The argument area starts at %fp+BIAS+128 in the callee frame,
    // %sp+BIAS+128 in ours.
    SDValue PtrOff = DAG.getIntPtrConstant(VA.getLocMemOffset() +
                                           Subtarget->getStackPointerBias() +
                                           0/*128*/, DL);
    PtrOff = DAG.getNode(ISD::ADD, DL, PtrVT, StackPtr, PtrOff);
    // LLVM_DEBUG(dbgs() << "MemOpChains.push_back: offset=" << offset << "\n");
    MemOpChains.push_back(
        DAG.getStore(Chain, DL, Arg, PtrOff, MachinePointerInfo()));
  }

  // Emit all stores, make sure they occur before the call.
  if (!MemOpChains.empty())
    Chain = DAG.getNode(ISD::TokenFactor, DL, MVT::Other, MemOpChains);

  // Build a sequence of CopyToReg nodes glued together with token chain and
  // glue operands which copy the outgoing args into registers. The InGlue is
  // necessary since all emitted instructions must be stuck together in order
  // to pass the live physical registers.
  SDValue InGlue;
  for (unsigned i = 0, e = RegsToPass.size(); i != e; ++i) {
    Chain = DAG.getCopyToReg(Chain, DL,
                             RegsToPass[i].first, RegsToPass[i].second, InGlue);
    InGlue = Chain.getValue(1);
  }

  // If the callee is a GlobalAddress node (quite common, every direct call is)
  // turn it into a TargetGlobalAddress node so that legalize doesn't hack it.
  // Likewise ExternalSymbol -> TargetExternalSymbol.
  SDValue Callee = CLI.Callee;
  bool hasReturnsTwice = hasReturnsTwiceAttr(DAG, Callee, CLI.CB);
  if (isa<GlobalAddressSDNode>(Callee))
    Callee = makeAddress(Callee, DAG, true/*isCode*/);
  else if (isa<ExternalSymbolSDNode>(Callee))
    Callee = makeAddress(Callee, DAG, true/*isCode*/);

  //
  MachineFunction &MF = DAG.getMachineFunction();
  if (!CLI.IsTailCall) {
    Register RetReg = MF.addLiveIn(LinkRegister, getRegClassFor(MVT::i64));
    (void)RetReg;
    LLVM_DEBUG(dbgs() << " link=" << PostriscRegisterInfo::getRegisterName(LinkRegister) << "\n");
  }
  // Build the operands for the call instruction itself.
  SmallVector<SDValue, 8> Ops;
  Ops.push_back(Chain);
  Ops.push_back(Callee);
  for (unsigned i = 0, e = RegsToPass.size(); i != e; ++i)
    Ops.push_back(DAG.getRegister(RegsToPass[i].first,
                                  RegsToPass[i].second.getValueType()));

  // Add a register mask operand representing the call-preserved registers.
  const PostriscRegisterInfo *TRI = Subtarget->getRegisterInfo();
  const uint32_t *Mask =
      ((hasReturnsTwice && 0) ? nullptr
                         : TRI->getCallPreservedMask(DAG.getMachineFunction(),
                                                     CLI.CallConv));
  assert(Mask && "Missing call preserved mask for calling convention");
  Ops.push_back(DAG.getRegisterMask(Mask));

  // Make sure the CopyToReg nodes are glued to the call instruction which
  // consumes the registers.
  if (InGlue.getNode())
    Ops.push_back(InGlue);

  // Now the call itself.
  if (CLI.IsTailCall) {
    DAG.getMachineFunction().getFrameInfo().setHasTailCall();
    return DAG.getNode(PostriscISD::TAIL_CALL, DL, MVT::Other, Ops);
  }
  SDVTList NodeTys = DAG.getVTList(MVT::i64, MVT::Other, MVT::Glue);
  SDValue Call = DAG.getNode(PostriscISD::CALL, DL, NodeTys, Ops);
  LLVM_DEBUG(dbgs() << "Call PostriscISD NumValues=" << Chain.getNode()->getNumValues() << "\n");
  Chain = Call.getValue(1);
  InGlue = Chain.getValue(2);

  LLVM_DEBUG(dbgs() << "Call="; Call.dump());
  // force linkinfo to be stored in link register
  //MachineFunction &MF = DAG.getMachineFunction();
  //Register RetReg = MF.addLiveIn(LinkRegister, getRegClassFor(MVT::i64));

  SDValue SDLinkRegister = DAG.getRegister(LinkRegister, MVT::i64);
  Chain = DAG.getCopyToReg(Chain, DL,
              SDLinkRegister,
              Call.getValue(0),
              InGlue);
  InGlue = Chain.getValue(1);

  Chain = DAG.getCopyFromReg(Chain, DL, LinkRegister, MVT::i64, InGlue);
  Chain = Chain.getValue(1);
  InGlue = Chain.getValue(2);

  // Revert the stack pointer immediately after the call.
  // consume link register, because otherwise -
  // optimizer eliminates copy to/from physical register.
  Chain = DAG.getCALLSEQ_END(Chain,
                             DAG.getIntPtrConstant(ArgsSize, DL, true),
                             Chain.getValue(0),
                             InGlue, DL);
  LLVM_DEBUG(dbgs() << "CALLSEQ_END: NumValues=" << Chain.getNode()->getNumValues() << "\n";
             Chain.dump());
  InGlue = Chain.getValue(1);

  // Now extract the return values. This is more or less the same as
  // LowerFormalArguments_64.

  CurrentReg = LinkRegister + 1;

  // Copy all of the result registers out of their specified physreg.
  for (unsigned i = 0; i != RVLocs.size(); ++i) {
    CCValAssign &VA = RVLocs[i];
    assert(VA.isRegLoc() && "Can only return in registers!");
    LLVM_DEBUG(dbgs() << " out arg old=" << PostriscRegisterInfo::getRegisterName(VA.getLocReg())
           << " new=" << PostriscRegisterInfo::getRegisterName(CurrentReg) << "\n");
    unsigned Reg = CurrentReg;
    ++CurrentReg;

    // When returning 'inreg {i32, i32 }', two consecutive i32 arguments can
    // reside in the same register in the high and low bits. Reuse the
    // CopyFromReg previous node to avoid duplicate copies.
    SDValue RV;
    if (RegisterSDNode *SrcReg = dyn_cast<RegisterSDNode>(Chain.getOperand(1)))
      if (SrcReg->getReg() == Reg && Chain->getOpcode() == ISD::CopyFromReg)
        RV = Chain.getValue(0);

    // But usually we'll create a new CopyFromReg for a different register.
    assert(!RV.getNode());
    if (!RV.getNode()) {
      RV = DAG.getCopyFromReg(Chain, DL, Reg, RVLocs[i].getLocVT(), InGlue);
      Chain = RV.getValue(1);
      InGlue = Chain.getValue(2);
    }

    // Get the high bits for i32 struct elements.
    if (VA.getValVT() == MVT::i32 && VA.needsCustom()) {
      assert(0 && "LowerCall(3): needsCustom");
      RV = DAG.getNode(ISD::SRL, DL, VA.getLocVT(), RV,
                       DAG.getConstant(32, DL, MVT::i32));
    }

    // The callee promoted the return value, so insert an Assert?ext SDNode so
    // we won't promote the value again in this function.
    switch (VA.getLocInfo()) {
    case CCValAssign::SExt:
      RV = DAG.getNode(ISD::AssertSext, DL, VA.getLocVT(), RV,
                       DAG.getValueType(VA.getValVT()));
      break;
    case CCValAssign::ZExt:
      RV = DAG.getNode(ISD::AssertZext, DL, VA.getLocVT(), RV,
                       DAG.getValueType(VA.getValVT()));
      break;
    default:
      break;
    }

    // Truncate the register down to the return value type.
    if (VA.isExtInLoc())
      RV = DAG.getNode(ISD::TRUNCATE, DL, VA.getValVT(), RV);

    InVals.push_back(RV);
  }

  // FIXME: this is a trick to mark all argument registers dirty
  for (unsigned i = RVLocs.size(); i < n_used_regs; ++i) {
    unsigned Reg = CurrentReg;
    ++CurrentReg;
    Chain = DAG.getCopyFromReg(Chain, DL, Reg, MVT::Other, InGlue);
    Chain = Chain.getValue(1);
    InGlue = Chain.getValue(2);
  }

  return Chain;
}

//===----------------------------------------------------------------------===//
// TargetLowering Implementation
//===----------------------------------------------------------------------===//

TargetLowering::AtomicExpansionKind
PostriscTargetLowering::shouldExpandAtomicRMWInIR(AtomicRMWInst *AI) const {
  switch (AI->getOperation()) {
  default:
    return AtomicExpansionKind::CmpXChg;
  case AtomicRMWInst::Xchg:
    switch (AI->getType()->getPrimitiveSizeInBits()) {
      case 8: case 16: case 32: case 64: case 128:
        return AtomicExpansionKind::None; // Uses xchg instruction
    }
    break;
  case AtomicRMWInst::Add:
  case AtomicRMWInst::Sub:
  case AtomicRMWInst::And:
  case AtomicRMWInst::Or:
  case AtomicRMWInst::Xor:
  case AtomicRMWInst::Max:
  case AtomicRMWInst::Min:
  case AtomicRMWInst::UMax:
  case AtomicRMWInst::UMin:
    switch (AI->getType()->getPrimitiveSizeInBits()) {
      case 8: case 16: case 32: case 64:
        return AtomicExpansionKind::None; // Uses AMO[SIZE]OP instruction
    }
    break;
  }
  return AtomicExpansionKind::CmpXChg;
}

PostriscTargetLowering::PostriscTargetLowering(const TargetMachine &TM,
                                         const PostriscSubtarget &STI)
    : TargetLowering(TM), Subtarget(&STI) {
  MVT PtrVT = MVT::getIntegerVT(TM.getPointerSizeInBits(0));

  // Instructions which use registers as conditionals examine all the
  // bits (as does the pseudo SELECT_CC expansion). I don't think it
  // matters much whether it's ZeroOrOneBooleanContent, or
  // ZeroOrNegativeOneBooleanContent, so, arbitrarily choose the
  // former.
  setBooleanContents(ZeroOrOneBooleanContent);
  setBooleanVectorContents(ZeroOrOneBooleanContent);

  // do aggressive inlining of memcpy and friends.
  // set threshold of 32 stores.
  MaxStoresPerMemset = 32;
  MaxStoresPerMemsetOptSize = 32;
  MaxStoresPerMemcpy = 32;
  MaxStoresPerMemcpyOptSize = 8;
  MaxStoresPerMemmove = 32;
  MaxStoresPerMemmoveOptSize = 8;

  // Set up the register classes.
  for (auto VT : { MVT::i1, MVT::i32, MVT::i64, MVT::i128,
                   MVT::f16, MVT::f32, MVT::f64, MVT::f128,
                   MVT::v2f64, MVT::v4f32, MVT::v8f16,
                   MVT::v2i64, MVT::v4i32, MVT::v8i16, MVT::v16i8
                 }) {
    addRegisterClass(VT, &POSTRISC::GRRegClass);
  }

  // TODO: this is a workaround to disallow use i128 mul for i64 div
  setOperationAction({ ISD::UDIV, ISD::SDIV,
                   ISD::MUL, ISD::UMULO, ISD::SMULO,
                   ISD::SHL, ISD::SRA, ISD::SRL,
                   ISD::SETCC }, MVT::i128, LibCall);

  setOperationAction({ ISD::ADD, ISD::SUB }, MVT::i128, Legal);

  setOperationAction({ ISD::SMIN, ISD::SMAX, ISD::UMIN, ISD::UMAX, ISD::ABS },
                     { MVT::i32, MVT::i64 }, Legal);

  // Turn FP extload into load/fpextend
  for (MVT VT : MVT::fp_valuetypes()) {
    setLoadExtAction(ISD::EXTLOAD, VT, MVT::f16, Expand);
    setLoadExtAction(ISD::EXTLOAD, VT, MVT::f32, Expand);
    setLoadExtAction(ISD::EXTLOAD, VT, MVT::f64, Expand);
  }

  // Postrisc doesn't have i1 sign extending load
  for (MVT VT : MVT::integer_valuetypes()) {
    setLoadExtAction(ISD::EXTLOAD, VT, MVT::i1, Promote);
    setLoadExtAction(ISD::ZEXTLOAD, VT, MVT::i1, Promote);
    setLoadExtAction(ISD::SEXTLOAD, VT, MVT::i1, Promote);
  }

  // Turn FP truncstore into trunc + store.
  setTruncStoreAction(MVT::f32, MVT::f16, Expand);
  setTruncStoreAction(MVT::f64, MVT::f16, Expand);
  setTruncStoreAction(MVT::f64, MVT::f32, Expand);
  setTruncStoreAction(MVT::f128, MVT::f32, Expand);
  setTruncStoreAction(MVT::f128, MVT::f64, Expand);

  // Custom legalize GlobalAddress nodes.
  setOperationAction(ISD::GlobalAddress, PtrVT, Custom);
  setOperationAction(ISD::GlobalTLSAddress, PtrVT, Custom);
  setOperationAction(ISD::ExternalSymbol, PtrVT, Custom);
  setOperationAction(ISD::ConstantPool, PtrVT, Custom);
  setOperationAction(ISD::BlockAddress, PtrVT, Custom);
  setOperationAction(ISD::JumpTable, PtrVT, Custom);

  // Expand jump table branches as address arithmetic
  // followed by an indirect jump.
  setOperationAction(ISD::BR_JT, MVT::Other, Expand);

  // Postrisc has sext_inreg, replace them with shl/sra
  setOperationAction(ISD::SIGN_EXTEND_INREG,
         { MVT::i32, MVT::i16, MVT::i8, MVT::i1 }, Legal);

  setOperationAction(ISD::FP_TO_SINT, MVT::i32, Legal);
  setOperationAction(ISD::SINT_TO_FP, MVT::i32, Legal);
  setOperationAction(ISD::FP_TO_SINT, MVT::i64, Legal);
  setOperationAction(ISD::SINT_TO_FP, MVT::i64, Legal);

  setOperationAction(ISD::FP_TO_UINT, MVT::i32, Legal);
  setOperationAction(ISD::UINT_TO_FP, MVT::i32, Legal);
  setOperationAction(ISD::FP_TO_UINT, MVT::i64, Legal);
  setOperationAction(ISD::UINT_TO_FP, MVT::i64, Legal);

  // Lower f16 conversion operations into library calls
  setOperationAction(ISD::FP16_TO_FP, MVT::f32, Expand);
  setOperationAction(ISD::FP_TO_FP16, MVT::f32, Expand);
  setOperationAction(ISD::FP16_TO_FP, MVT::f64, Expand);
  setOperationAction(ISD::FP_TO_FP16, MVT::f64, Expand);

  setOperationAction(ISD::BITCAST, {
     MVT::i32, MVT::i64, MVT::i128,
     MVT::f16, MVT::f32, MVT::f64, MVT::f128 }, Legal);

  // Postrisc has select
  setOperationAction(ISD::SELECT, {
    MVT::i32, MVT::i64, MVT::i128,
    MVT::f16, MVT::f32, MVT::f64, MVT::f128 }, Legal);

  setOperationAction(ISD::SETCC, MVT::i32, Legal);
  setOperationAction(ISD::SETCC, MVT::i64, Legal);
  setOperationAction(ISD::SETCC, MVT::f32, Legal);//Expand
  setOperationAction(ISD::SETCC, MVT::f64, Legal);//Expand
  setOperationAction(ISD::SETCC, MVT::f128, Legal);//Expand

  setOperationAction(ISD::BRIND, MVT::Other, Legal);
  setOperationAction(ISD::BR_JT, MVT::Other, Expand);

  // Don't lower BR_CC (we have brcond)
  setOperationAction(ISD::BR_CC, {
        MVT::Other,
        MVT::i1, MVT::i32, MVT::i64, MVT::i128,
        MVT::f32, MVT::f64, MVT::f128 }, Expand);

  // Postrisc have BRCOND for all?
  //setOperationAction(ISD::BRCOND, MVT::Other, Legal);
  setOperationAction(ISD::BRCOND, {
     MVT::i32, MVT::i64,
     MVT::f32, MVT::f64, MVT::f128
     }, Legal);

  // Don't lower SELECT_CC, we have select
  setOperationAction(ISD::SELECT_CC, {
        MVT::i1, MVT::i32, MVT::i64, MVT::i128,
        MVT::f32, MVT::f64, MVT::f128
        }, Expand);

  setOperationAction(ISD::DYNAMIC_STACKALLOC, MVT::i64, Custom);

  for (auto VT : { MVT::i32, MVT::i64 }) {
    setOperationAction({
      ISD::CTPOP, ISD::CTLZ, ISD::CTTZ, ISD::BITREVERSE
      }, VT, Legal);
    setOperationAction(ISD::ROTL , VT, Expand);
    setOperationAction(ISD::ROTR , VT, Expand);
    setOperationAction(ISD::BSWAP, VT, Expand);

    // Postrisc has no REM or DIVREM operations.
    setOperationAction(ISD::UREM, VT, Expand);
    setOperationAction(ISD::SREM, VT, Expand);
    setOperationAction(ISD::SDIVREM, VT, Expand);
    setOperationAction(ISD::UDIVREM, VT, Expand);

    setOperationAction({
       ISD::ADDC, ISD::ADDE, ISD::SUBC, ISD::SUBE
       }, VT, Custom);
  }

  // ATOMICs.
  setMaxAtomicSizeInBitsSupported(128);
  setMinCmpXchgSizeInBits(8); // 8,16,32,64,128 CAS supported

  setOperationAction(ISD::ATOMIC_FENCE, MVT::Other, Custom);

  for (auto VT : { MVT::i8, MVT::i16, MVT::i32, MVT::i64, MVT::i128 }) {
    setOperationAction({ISD::ATOMIC_LOAD, ISD::ATOMIC_STORE}, VT, Legal);
  }
  for (auto VT : { MVT::i32, MVT::i64, MVT::i128 }) {
    setOperationAction(ISD::ATOMIC_CMP_SWAP, VT, Legal);
    // We can't return success/failure for CAS, only the old value,
    // sowe expand and let LLVM to add the comparison
    setOperationAction(ISD::ATOMIC_CMP_SWAP_WITH_SUCCESS, VT, Expand);
    setOperationAction(ISD::ATOMIC_SWAP, VT, Legal);
  }
  for (auto VT : { MVT::i32, MVT::i64 }) {
    setOperationAction({
        ISD::ATOMIC_LOAD_ADD, ISD::ATOMIC_LOAD_SUB, // NEG+ATOMIC_LOAD_ADD
        ISD::ATOMIC_LOAD_AND, ISD::ATOMIC_LOAD_OR, ISD::ATOMIC_LOAD_XOR,
        ISD::ATOMIC_LOAD_MIN, ISD::ATOMIC_LOAD_MAX,
        ISD::ATOMIC_LOAD_UMIN, ISD::ATOMIC_LOAD_UMAX,
        }, VT, Legal);
  }

  setOperationAction(ISD::SHL_PARTS, MVT::i32, Expand);
  setOperationAction(ISD::SRA_PARTS, MVT::i32, Expand);
  setOperationAction(ISD::SRL_PARTS, MVT::i32, Expand);

  // Expands to [SU]MUL_LOHI.
  setOperationAction(ISD::MULHU,     MVT::i32, Expand);
  setOperationAction(ISD::MULHS,     MVT::i32, Expand);
  setOperationAction(ISD::MUL,       MVT::i32, Expand);

  setOperationAction(ISD::UMUL_LOHI, MVT::i64, Expand);
  setOperationAction(ISD::SMUL_LOHI, MVT::i64, Expand);
  setOperationAction(ISD::MULHU,     MVT::i64, Expand);
  setOperationAction(ISD::MULHS,     MVT::i64, Expand);

  //setOperationAction(ISD::UMULO,     MVT::i64, Custom);
  //setOperationAction(ISD::SMULO,     MVT::i64, Custom);

  setOperationAction(ISD::SHL_PARTS, MVT::i64, Expand);
  setOperationAction(ISD::SRA_PARTS, MVT::i64, Expand);
  setOperationAction(ISD::SRL_PARTS, MVT::i64, Expand);

  // VASTART needs to be custom lowered to use the VarArgsFrameIndex.
  setOperationAction(ISD::VASTART, MVT::Other, Custom);
  setOperationAction({ISD::VAARG, ISD::VACOPY, ISD::VAEND}, MVT::Other, Expand);

  setOperationAction(ISD::TRAP              , MVT::Other, Legal);
  setOperationAction(ISD::DEBUGTRAP         , MVT::Other, Legal);

  // Use the default implementation.
  setOperationAction(ISD::STACKSAVE         , MVT::Other, Expand);
  setOperationAction(ISD::STACKRESTORE      , MVT::Other, Expand);
  setOperationAction(ISD::DYNAMIC_STACKALLOC, MVT::i32  , Custom);

  setStackPointerRegisterToSaveRestore(POSTRISC::sp);

  // FPU
  for (auto VT : { MVT::f16, MVT::f32, MVT::f64, MVT::f128, MVT::v4f32, MVT::v2f64 }) {
    static unsigned const ExpandOps[] = {
      ISD::FSIN,
      ISD::FCOS,
      ISD::FSINCOS,
      ISD::FREM,
      ISD::FPOW,
    };
    setOperationAction(ExpandOps, VT, Expand);

    setOperationAction({
      ISD::LOAD, ISD::STORE,
      ISD::FADD, ISD::FSUB, ISD::FMUL, ISD::FDIV,
      ISD::STRICT_FADD, ISD::STRICT_FSUB, ISD::STRICT_FMUL, ISD::STRICT_FDIV,
      ISD::FSQRT, ISD::STRICT_FSQRT,
      ISD::FP_EXTEND, ISD::FP_ROUND,
      ISD::FABS, ISD::FCOPYSIGN, ISD::FNEG,
      ISD::FMA, ISD::STRICT_FMA,
      ISD::FRINT, ISD::FNEARBYINT, ISD::FFLOOR, ISD::FCEIL, ISD::FROUND, ISD::FTRUNC,
      ISD::STRICT_FMA,
      ISD::STRICT_FNEARBYINT, ISD::STRICT_FFLOOR, ISD::STRICT_FCEIL,
      ISD::STRICT_FROUND, ISD::STRICT_FTRUNC,
      ISD::STRICT_FRINT, ISD::STRICT_FP_ROUND, ISD::STRICT_FP_EXTEND,
      }, VT, Legal);

    // FIXME:
    //setOperationAction(ISD::IS_FPCLASS, VT, Custom);
  }

  // TODO: how construct vectors?
  setOperationAction(ISD::BUILD_VECTOR, MVT::v4i32, LibCall);
  setOperationAction(ISD::BUILD_VECTOR, MVT::v2i64, LibCall);

  // TODO Legal?
  //setOperationAction(ISD::FDIV, MVT::f32, Promote);
  //setOperationAction(ISD::FSQRT, MVT::f32, Promote);
  /*
  setTargetDAGCombine(ISD::FADD);
  setTargetDAGCombine(ISD::FSUB);
  setTargetDAGCombine(ISD::FNEG);
  setTargetDAGCombine(ISD::FMA);
  setTargetDAGCombine(ISD::STRICT_FMA);
  */
  setOperationAction(ISD::READCYCLECOUNTER, MVT::i64, Legal);

  setOperationAction(ISD::INTRINSIC_WO_CHAIN, MVT::Other, Custom);

  setMinFunctionAlignment(Align(16)); // the instruction bundle

  computeRegisterProperties(Subtarget->getRegisterInfo());
}

bool PostriscTargetLowering::useSoftFloat() const {
  return Subtarget->useSoftFloat();
}

const char *PostriscTargetLowering::getTargetNodeName(unsigned Opcode) const {
#define MAKE_CASE(V) case PostriscISD::V: return "PostriscISD::" #V
  switch ((PostriscISD::NodeType)Opcode) {
    case PostriscISD::FIRST_NUMBER:
      break;
    MAKE_CASE(PCREL_CODE_WRAPPER);
    MAKE_CASE(PCREL_CODE_WRAPPER_EXT);
    MAKE_CASE(PCREL_DATA_WRAPPER);
    MAKE_CASE(PCREL_DATA_WRAPPER_EXT);
    MAKE_CASE(ABSADDR_WRAPPER);
    MAKE_CASE(ABSADDR_WRAPPER_EXT);
    MAKE_CASE(TLS_OFFSET_WRAPPER);
    MAKE_CASE(TLS_OFFSET_WRAPPER_EXT);
    MAKE_CASE(FTOI);
    MAKE_CASE(ITOF);
    MAKE_CASE(FTOX);
    MAKE_CASE(XTOF);
    MAKE_CASE(CALL);
    MAKE_CASE(RET_GLUE);
    MAKE_CASE(FLUSHW);
    MAKE_CASE(TAIL_CALL);
    MAKE_CASE(TLS_CALL);
    MAKE_CASE(TLS_CALL_EXT);
  }
  return nullptr;
}

EVT PostriscTargetLowering::getSetCCResultType(
  const DataLayout &DL, LLVMContext &Context, EVT VT) const {
  if (!VT.isVector())
    return MVT::i1;
  return VT.changeVectorElementTypeToInteger();
}

/// isMaskedValueZeroForTargetNode - Return true if 'Op & Mask' is known to
/// be zero. Op is expected to be a target specific node. Used by DAG
/// combiner.
void PostriscTargetLowering::computeKnownBitsForTargetNode
                                (const SDValue Op,
                                 KnownBits &Known,
                                 const APInt &DemandedElts,
                                 const SelectionDAG &DAG,
                                 unsigned Depth) const {
  KnownBits Known2;
  Known.resetAll();
}

//===----------------------------------------------------------------------===//
//  Nodes Lowering Code
//===----------------------------------------------------------------------===//
SDValue PostriscTargetLowering::getTargetNode(
  GlobalAddressSDNode *N, EVT Ty, SelectionDAG &DAG, unsigned Flag) const {
  LLVM_DEBUG(dbgs() << "withTargetFlags: GlobalAddressSDNode flags="
                    << N->getTargetFlags() << " TF=" << Flag << "\n");
  return DAG.getTargetGlobalAddress(N->getGlobal(), SDLoc(N), Ty, N->getOffset(), Flag);
}

SDValue PostriscTargetLowering::getTargetNode(
  ExternalSymbolSDNode *N, EVT Ty, SelectionDAG &DAG, unsigned Flag) const {
  LLVM_DEBUG(dbgs() << "withTargetFlags: ExternalSymbolSDNode flags="
                    << N->getTargetFlags() << " TF=" << Flag << "\n");
  return DAG.getTargetExternalSymbol(N->getSymbol(), Ty, Flag);
}

SDValue PostriscTargetLowering::getTargetNode(
  JumpTableSDNode *N, EVT Ty, SelectionDAG &DAG, unsigned Flag) const {
  LLVM_DEBUG(dbgs() << "withTargetFlags: JumpTableSDNode:"
                    << " flags=" << N->getTargetFlags()
                    << " index=" << N->getIndex()
                    << " TF=" << Flag << "\n");
  return DAG.getTargetJumpTable(N->getIndex(), Ty, Flag);
}

SDValue PostriscTargetLowering::getTargetNode(
  ConstantPoolSDNode *N, EVT Ty, SelectionDAG &DAG, unsigned Flag) const {
  LLVM_DEBUG(dbgs() << "withTargetFlags: ConstantPoolSDNode flags="
                    << N->getTargetFlags() << " TF=" << Flag << "\n");
  return DAG.getTargetConstantPool(N->getConstVal(), Ty, N->getAlign(), N->getOffset(), Flag);
}

SDValue PostriscTargetLowering::getTargetNode(
  BlockAddressSDNode* N, EVT Ty, SelectionDAG &DAG, unsigned Flag) const {
  LLVM_DEBUG(dbgs() << "withTargetFlags: BlockAddressSDNode flags="
                    << N->getTargetFlags() << " TF=" << Flag << "\n");
  return DAG.getTargetBlockAddress(N->getBlockAddress(), Ty, 0, Flag);
}

// Convert to a target node and set target flags.
SDValue PostriscTargetLowering::withTargetFlags(
  SDValue Op, unsigned TF, SelectionDAG &DAG) const {
  if (const GlobalAddressSDNode *GA = dyn_cast<GlobalAddressSDNode>(Op))
  {
    LLVM_DEBUG(dbgs() << "withTargetFlags: GlobalAddressSDNode flags=" << GA->getTargetFlags()
                      << " TF=" << TF << "\n");
    return DAG.getTargetGlobalAddress(GA->getGlobal(),
                                      SDLoc(GA),
                                      GA->getValueType(0),
                                      GA->getOffset(),
                                      TF);
  }

  if (const ConstantPoolSDNode *CP = dyn_cast<ConstantPoolSDNode>(Op))
  {
    LLVM_DEBUG(dbgs() << "withTargetFlags: ConstantPoolSDNode flags=" << CP->getTargetFlags()
                      << " TF=" << TF << "\n");
    return DAG.getTargetConstantPool(CP->getConstVal(), CP->getValueType(0),
                                     CP->getAlign(),
                                     CP->getOffset(),
                                     TF);
  }

  if (const BlockAddressSDNode *BA = dyn_cast<BlockAddressSDNode>(Op))
  {
    LLVM_DEBUG(dbgs() << "withTargetFlags: BlockAddressSDNode flags=" << BA->getTargetFlags()
                      << " TF=" << TF << "\n");
    return DAG.getTargetBlockAddress(BA->getBlockAddress(),
                                     Op.getValueType(),
                                     0,
                                     TF);
  }

  if (const ExternalSymbolSDNode *ES = dyn_cast<ExternalSymbolSDNode>(Op))
  {
    LLVM_DEBUG(dbgs() << "withTargetFlags: ExternalSymbolSDNode flags=" << ES->getTargetFlags()
                      << " TF=" << TF << "\n");
    return DAG.getTargetExternalSymbol(ES->getSymbol(),
                                       ES->getValueType(0), TF);
  }

  if (const JumpTableSDNode *JT = dyn_cast<JumpTableSDNode>(Op)) {
    // *JT = cast<JumpTableSDNode>(Op);
    LLVM_DEBUG(dbgs() << "withTargetFlags: JumpTableSDNode:"
                      << " flags=" << JT->getTargetFlags()
                      << " index=" << JT->getIndex()
                      << " TF=" << TF << "\n");
    EVT PtrVT = getPointerTy(DAG.getDataLayout());
    return DAG.getTargetJumpTable(JT->getIndex(), PtrVT, TF);
  }

  LLVM_DEBUG(dbgs() << "Unhandled address SDNode\n");
  llvm_unreachable("Unhandled address SDNode");
}

static bool IsFunction(const GlobalValue *GV)
{
  if (isa<Function>(GV)) { // Function::classof(GV)?
    LLVM_DEBUG(dbgs() << "IsFunction: the global value is a function: "
                      << GV->getGlobalIdentifier() << "\n");
    return true;
  }
  if (isa<GlobalAlias>(GV)) {
    GlobalAlias const *GA = dyn_cast<const GlobalAlias>(GV);
    if (isa<Function>(GA)) { // Function::classof(GA)
      LLVM_DEBUG(dbgs() << "IsFunction: the global value is a function alias: "
                        << GV->getGlobalIdentifier() << "\n");
      return true;
    }
  }

  LLVM_DEBUG(dbgs() << "IsFunction: the global value is data: "
                    << GV->getGlobalIdentifier() << "\n");
  return false;
}

bool
PostriscTargetLowering::IsCodeModelExtInsnRequired(bool is_code) const
{
  CodeModel::Model const codeModel = getTargetMachine().getCodeModel();
  if (is_code) {
    switch (codeModel) {
    case CodeModel::Tiny:
    case CodeModel::Small:
    case CodeModel::Kernel:
    case CodeModel::Medium:
        return false;
    case CodeModel::Large:
        return true;
    }
    LLVM_DEBUG(dbgs() << "Unsupported code model " << codeModel);
    llvm_unreachable("Unsupported code model");
  } else { // data
    switch (codeModel) {
    case CodeModel::Tiny:
    case CodeModel::Small:
    case CodeModel::Kernel:
        return false;
    case CodeModel::Medium:
    case CodeModel::Large:
        return true;
    }
    LLVM_DEBUG(dbgs() << "Unsupported data model " << codeModel);
    llvm_unreachable("Unsupported data model");
  }
}

// Build SDNodes for producing an address from a GlobalAddress, ConstantPool,
// or ExternalSymbol SDNode.
SDValue PostriscTargetLowering::makeAddress(SDValue Op, SelectionDAG &DAG, bool isCode) const {
  SDLoc DL(Op);
  EVT PtrVT = getPointerTy(DAG.getDataLayout());
  unsigned TF;

  if (isPositionIndependent()) {
    if (IsCodeModelExtInsnRequired(isCode)) {
      // only LARGE model forces all refs to be extended instructions
      // This is the pic64 code model
      TF = isCode ? PostriscMCExpr::VK_POSTRISC_JUMP_EXT
                  : PostriscMCExpr::VK_POSTRISC_PCREL_FWD_EXT;
      return DAG.getNode(isCode ? PostriscISD::PCREL_CODE_WRAPPER_EXT
                                : PostriscISD::PCREL_DATA_WRAPPER_EXT,
                         DL, Op.getValueType(),
                 withTargetFlags(Op, TF, DAG));
    } else {
      // This is the pic28 code model, the GOT is known to be smaller than 256MiB.
      TF = isCode ? PostriscMCExpr::VK_POSTRISC_JUMP
                  : PostriscMCExpr::VK_POSTRISC_PCREL_FWD;
      return DAG.getNode(isCode ? PostriscISD::PCREL_CODE_WRAPPER
                                : PostriscISD::PCREL_DATA_WRAPPER,
                         DL, Op.getValueType(),
                 withTargetFlags(Op, TF, DAG));
    }
  }

  // This is one of the absolute code models.
  switch (getTargetMachine().getCodeModel()) {
  default:
    LLVM_DEBUG(dbgs() << "Unsupported absolute code model: " << getTargetMachine().getCodeModel());
    llvm_unreachable("Unsupported absolute code model");
  case CodeModel::Tiny:
  case CodeModel::Small:
  case CodeModel::Medium: {
    return DAG.getNode(ISD::ADD, DL, PtrVT,
               DAG.getRegister(POSTRISC::gz, PtrVT),
               withTargetFlags(Op, PostriscMCExpr::VK_POSTRISC_OFFSET, DAG));
  }
  case CodeModel::Large: {
    return DAG.getNode(ISD::ADD, DL, PtrVT,
               DAG.getRegister(POSTRISC::gz, PtrVT),
               withTargetFlags(Op, PostriscMCExpr::VK_POSTRISC_OFFSET_EXT, DAG));
  }
  }
}

SDValue PostriscTargetLowering::LowerGlobalAddress(SDValue Op,
                                                SelectionDAG &DAG) const {
  GlobalAddressSDNode *GN = cast<GlobalAddressSDNode>(Op);
  const GlobalValue *GV = GN->getGlobal();
  LLVM_DEBUG(dbgs() << "GlobalAddress: " << GV->getGlobalIdentifier() << "\n");
  bool const isFunction = IsFunction(GV);
  return makeAddress(Op, DAG, isFunction);
}

SDValue PostriscTargetLowering::LowerExternalSymbol(SDValue Op,
                                               SelectionDAG &DAG) const {
  // ExternalSymbolSDNode *ES = cast<ExternalSymbolSDNode>(Op);
  return makeAddress(Op, DAG, false/*isFunction*/);
}

SDValue PostriscTargetLowering::LowerConstantPool(SDValue Op,
                                               SelectionDAG &DAG) const {
  //const ConstantPoolSDNode *CP = dyn_cast<ConstantPoolSDNode>(Op);
  LLVM_DEBUG(dbgs() << "ConstantPool:\n");
  return makeAddress(Op, DAG, false/*isCode*/);
}

SDValue PostriscTargetLowering::LowerBlockAddress(SDValue Op,
                                               SelectionDAG &DAG) const {
  //const BlockAddressSDNode *BA = dyn_cast<BlockAddressSDNode>(Op);
  LLVM_DEBUG(dbgs() << "BlockAddress:\n");
  return makeAddress(Op, DAG, true/*isCode*/);
}

SDValue
PostriscTargetLowering::LowerJumpTable(SDValue Op, SelectionDAG &DAG) const
{
  // JumpTableSDNode *JT = cast<JumpTableSDNode>(Op);
  LLVM_DEBUG(dbgs() << "LowerJumpTable:\n");
  return makeAddress(Op, DAG, false/*isCode*/);
  // return DAG.getNode(Postrisc::PCREL_DATA_WRAPPER, DL, PtrVT, Result);
}

static char const *getTlsModelName(TLSModel::Model model)
{
  switch (model) {
    case TLSModel::GeneralDynamic: return "GeneralDynamic";
    case TLSModel::LocalDynamic: return "LocalDynamic";
    case TLSModel::InitialExec: return "InitialExec";
    case TLSModel::LocalExec: return "LocalExec";
  }
  llvm_unreachable("Unknown thread model");
  return "unknown_thread_model";
}

SDValue PostriscTargetLowering::LowerGlobalTLSAddress(SDValue Op,
                                                   SelectionDAG &DAG) const {

  GlobalAddressSDNode *GA = cast<GlobalAddressSDNode>(Op);
  if (DAG.getTarget().useEmulatedTLS())
    return LowerToTLSEmulatedModel(GA, DAG);

  SDLoc DL(GA);
  const GlobalValue *GV = GA->getGlobal();
  EVT PtrVT = getPointerTy(DAG.getDataLayout());

  TLSModel::Model model = getTargetMachine().getTLSModel(GV);
  LLVM_DEBUG(dbgs() << "TlsModel=" << getTlsModelName(model) << "\n");

  bool const isExtCode = IsCodeModelExtInsnRequired(true/*code*/);
  bool const isExtData = IsCodeModelExtInsnRequired(false/*data*/);

  if (model == TLSModel::GeneralDynamic || model == TLSModel::LocalDynamic) {
    //
    // GOT with a TLS_index structure for variable x
    // target = __tls_get_addr(got_pointer + materialize(dtlndx_gd(x)))
    //
    bool const isGeneral = (model == TLSModel::GeneralDynamic);

    unsigned const GotTF = isGeneral
      ? (isExtData ? PostriscMCExpr::VK_POSTRISC_TLS_GD_GOT_OFFSET_EXT
                   : PostriscMCExpr::VK_POSTRISC_TLS_GD_GOT_OFFSET)
      : (isExtData ? PostriscMCExpr::VK_POSTRISC_TLS_LD_GOT_OFFSET_EXT
                   : PostriscMCExpr::VK_POSTRISC_TLS_LD_GOT_OFFSET);
    unsigned const callTF = isGeneral
      ? (isExtCode ? PostriscMCExpr::VK_POSTRISC_TLS_GD_CALL_EXT
                   : PostriscMCExpr::VK_POSTRISC_TLS_GD_CALL)
      : (isExtCode ? PostriscMCExpr::VK_POSTRISC_TLS_LD_CALL_EXT
                   : PostriscMCExpr::VK_POSTRISC_TLS_LD_CALL);

    SDValue Argument = DAG.getNode(
                        isExtData ? PostriscISD::PCREL_DATA_WRAPPER_EXT
                                  : PostriscISD::PCREL_DATA_WRAPPER,
                        DL, PtrVT,
                        withTargetFlags(Op, GotTF, DAG));

    SDValue Chain = DAG.getEntryNode();
    SDValue InGlue;

    Chain = DAG.getCALLSEQ_START(Chain, 1, 0, DL);
    Chain = DAG.getCopyToReg(Chain, DL, POSTRISC::r119, Argument, InGlue);
    InGlue = Chain.getValue(1);

    SDValue Callee = DAG.getTargetExternalSymbol("__tls_get_addr", PtrVT,
                         isExtCode ? PostriscMCExpr::VK_POSTRISC_JUMP_EXT
                                   : PostriscMCExpr::VK_POSTRISC_JUMP);

    SDValue Symbol = withTargetFlags(Op, callTF, DAG);

    SDVTList NodeTys = DAG.getVTList(MVT::i64, MVT::Other, MVT::Glue);
    const uint32_t *Mask = Subtarget->getRegisterInfo()->getCallPreservedMask(
        DAG.getMachineFunction(), CallingConv::C);
    assert(Mask && "Missing call preserved mask for calling convention");
    SDValue Ops[] = {Chain,
                     Callee,
                     Symbol,
                     DAG.getRegister(POSTRISC::r119, PtrVT),
                     DAG.getRegisterMask(Mask),
                     InGlue};
    Chain = DAG.getNode(isExtCode ? PostriscISD::TLS_CALL_EXT
                                  : PostriscISD::TLS_CALL,
                        DL, NodeTys, Ops);
    InGlue = Chain.getValue(1);

    // force linkinfo to be stored in link register
    unsigned const LinkRegister = POSTRISC::r118;
    Chain = DAG.getCopyToReg(Chain, DL,
              LinkRegister,
              Chain.getValue(0),
              InGlue);
    InGlue = Chain.getValue(1);

    Chain = DAG.getCopyFromReg(Chain, DL, LinkRegister, MVT::i64, InGlue);
    Chain = Chain.getValue(1);
    InGlue = Chain.getValue(2);

    Chain = DAG.getCALLSEQ_END(Chain, DAG.getIntPtrConstant(1, DL, true),
                               Chain.getValue(0), //DAG.getIntPtrConstant(0, DL, true),
                               InGlue, DL);
    InGlue = Chain.getValue(1);
    SDValue Ret = DAG.getCopyFromReg(Chain, DL, POSTRISC::r119, PtrVT, InGlue);

    if (isGeneral) // GeneralDynamic
      return Ret;

    // Local-dynamic
    //
    // GOT with a TLS_index structure for the current object/module
    //   tls_block = __tls_get_addr(got_pointer + materialize(tmndx_ld(x1)))
    // link-time tls offset
    //   target1 = tls_block + materialize(dtpoff(x1))  // The TLS offset for local symbol
    //   target2 = tls_block + materialize(dtpoff(x2))  // The TLS offset for local symbol R_POSTRISC_TLS_LD_OFFSET
    //
    unsigned const TF = isExtData ? PostriscMCExpr::VK_POSTRISC_TLS_LD_OFFSET_EXT
                                  : PostriscMCExpr::VK_POSTRISC_TLS_LD_OFFSET;
    SDValue wrapper = DAG.getNode(
                         isExtData ? PostriscISD::TLS_OFFSET_WRAPPER_EXT
                                   : PostriscISD::TLS_OFFSET_WRAPPER,
                         DL, PtrVT,
                         withTargetFlags(Op, TF, DAG));
    return DAG.getNode(ISD::ADD, DL, PtrVT, Ret, wrapper);
  }

  if (model == TLSModel::InitialExec) {
    //
    // GOT with the static TLS offset for symbol x (run-time)
    // target = thread_pointer + load[got_pointer + materialize(tpoff_ie(x))]
    // target = tp + load(ip + gottpoff(x)) // R_POSTRISC_TLS_IE_OFFSET
    //
    unsigned const TF = isExtData ? PostriscMCExpr::VK_POSTRISC_TLS_IE_OFFSET_EXT
                                  : PostriscMCExpr::VK_POSTRISC_TLS_IE_OFFSET;
    SDValue gottpoffset = DAG.getNode(
                         isExtData ? PostriscISD::PCREL_DATA_WRAPPER_EXT
                                   : PostriscISD::PCREL_DATA_WRAPPER,
                         DL, PtrVT,
                         withTargetFlags(Op, TF, DAG));

    SDValue Offset = DAG.getLoad(PtrVT, DL, DAG.getEntryNode(),
                                 gottpoffset,
                                 MachinePointerInfo());

    return DAG.getNode(ISD::ADD, DL, PtrVT,
                       DAG.getRegister(POSTRISC::tp, PtrVT),
                       Offset);
  }

  assert(model == TLSModel::LocalExec);
  //
  // link-time tls offset
  // target = thread_pointer + materialize(tpoff(x)) // R_POSTRISC_TLS_LE_OFFSET
  //
  unsigned const TF = isExtData ? PostriscMCExpr::VK_POSTRISC_TLS_LE_OFFSET_EXT
                                : PostriscMCExpr::VK_POSTRISC_TLS_LE_OFFSET;

  SDValue wrapper = DAG.getNode(
                      isExtData ? PostriscISD::TLS_OFFSET_WRAPPER_EXT
                                : PostriscISD::TLS_OFFSET_WRAPPER,
                      DL, PtrVT,
                      withTargetFlags(Op, TF, DAG));

  return DAG.getNode(ISD::ADD, DL, PtrVT,
                     DAG.getRegister(POSTRISC::tp, PtrVT),
                     wrapper);
}

SDValue PostriscTargetLowering::LowerVASTART(SDValue Op, SelectionDAG &DAG) const {
  MachineFunction &MF = DAG.getMachineFunction();
  PostriscMachineFunctionInfo *FuncInfo = MF.getInfo<PostriscMachineFunctionInfo>();

  SDLoc DL(Op);
  SDValue FI = DAG.getFrameIndex(FuncInfo->getVarArgsFrameIndex(),
                                 getPointerTy(MF.getDataLayout()));

  // vastart just stores the address of the VarArgsFrameIndex slot into the
  // memory location argument.
  const Value *SV = cast<SrcValueSDNode>(Op.getOperand(2))->getValue();
  return DAG.getStore(Op.getOperand(0), DL, FI, Op.getOperand(1),
                      MachinePointerInfo(SV));
}

SDValue PostriscTargetLowering::LowerDYNAMIC_STACKALLOC(SDValue Op, SelectionDAG &DAG) const {
  SDValue Chain = Op.getOperand(0);  // Legalize the chain.
  SDValue Size  = Op.getOperand(1);  // Legalize the size.
  MaybeAlign Alignment =
      cast<ConstantSDNode>(Op.getOperand(2))->getMaybeAlignValue();
  Align StackAlign = Subtarget->getFrameLowering()->getStackAlign();
  EVT VT = Size->getValueType(0);
  SDLoc dl(Op);

  // TODO: implement over-aligned alloca. (Note: also implies
  // supporting support for overaligned function frames + dynamic
  // allocations, at all, which currently isn't supported)
  if (Alignment && *Alignment > StackAlign) {
    const MachineFunction &MF = DAG.getMachineFunction();
    report_fatal_error("Function \"" + Twine(MF.getName()) + "\": "
                       "over-aligned dynamic alloca not supported.");
  }

  unsigned SPReg = POSTRISC::sp;
  SDValue SP = DAG.getCopyFromReg(Chain, dl, SPReg, VT);
  SDValue NewSP = DAG.getNode(ISD::SUB, dl, VT, SP, Size); // Value
  Chain = DAG.getCopyToReg(SP.getValue(1), dl, SPReg, NewSP);    // Output chain

  SDValue Ops[2] = { NewSP, Chain };
  return DAG.getMergeValues(Ops, dl);
}


static SDValue getFLUSHW(SDValue Op, SelectionDAG &DAG) {
  SDLoc dl(Op);
  SDValue Chain = DAG.getNode(PostriscISD::FLUSHW,
                              dl, MVT::Other, DAG.getEntryNode());
  return Chain;
}

static SDValue getFRAMEADDR(uint64_t depth, SDValue Op, SelectionDAG &DAG,
                            const PostriscSubtarget *Subtarget,
                            bool AlwaysFlush = false) {
  MachineFunction &MF = DAG.getMachineFunction();
  MachineFrameInfo &MFI = MF.getFrameInfo();

  MFI.setFrameAddressIsTaken(true);

  EVT VT = Op.getValueType();
  SDLoc dl(Op);
  unsigned stackBias = Subtarget->getStackPointerBias();

  SDValue FrameAddr;
  SDValue Chain;

  // flush first to make sure the windowed registers' values are in stack
  Chain = (depth || AlwaysFlush) ? getFLUSHW(Op, DAG) : DAG.getEntryNode();

  FrameAddr = DAG.getCopyFromReg(Chain, dl, POSTRISC::fp, VT);

  unsigned Offset = (Subtarget->is64Bit()) ? (stackBias + 112) : 56;

  while (depth--) {
    SDValue Ptr = DAG.getNode(ISD::ADD, dl, VT, FrameAddr,
                              DAG.getIntPtrConstant(Offset, dl));
    FrameAddr = DAG.getLoad(VT, dl, Chain, Ptr, MachinePointerInfo());
  }
  if (stackBias)
    FrameAddr = DAG.getNode(ISD::ADD, dl, VT, FrameAddr,
                            DAG.getIntPtrConstant(stackBias, dl));
  return FrameAddr;
}

SDValue PostriscTargetLowering::LowerFRAMEADDR(SDValue Op, SelectionDAG &DAG) const {

  uint64_t depth = Op.getConstantOperandVal(0);
  assert(depth == 0 && "LowerFRAMEADDR: nonzero depth not supported");
  return getFRAMEADDR(depth, Op, DAG, Subtarget);

}

SDValue PostriscTargetLowering::LowerRETURNADDR(SDValue Op, SelectionDAG &DAG) const {
  MachineFunction &MF = DAG.getMachineFunction();
  MachineFrameInfo &MFI = MF.getFrameInfo();
  MFI.setReturnAddressIsTaken(true);

  if (verifyReturnAddressArgumentIsConstant(Op, DAG))
    return SDValue();

  EVT VT = Op.getValueType();
  SDLoc dl(Op);
  uint64_t depth = Op.getConstantOperandVal(0);

  SDValue RetAddr;
  if (depth == 0) {
    auto PtrVT = getPointerTy(DAG.getDataLayout());
    Register RetReg = MF.addLiveIn(POSTRISC::r0, getRegClassFor(PtrVT));
    RetAddr = DAG.getCopyFromReg(DAG.getEntryNode(), dl, RetReg, VT);
    return RetAddr;
  }

  // Need frame address to find return address of the caller.
  SDValue FrameAddr = getFRAMEADDR(depth - 1, Op, DAG, Subtarget, true);

  unsigned Offset = (Subtarget->is64Bit()) ? 120 : 60;
  SDValue Ptr = DAG.getNode(ISD::ADD,
                            dl, VT,
                            FrameAddr,
                            DAG.getIntPtrConstant(Offset, dl));
  RetAddr = DAG.getLoad(VT, dl, DAG.getEntryNode(), Ptr, MachinePointerInfo());

  return RetAddr;
}

SDValue PostriscTargetLowering::LowerSTORE(SDValue Op, SelectionDAG &DAG) const
{
  SDLoc dl(Op);
  StoreSDNode *St = cast<StoreSDNode>(Op.getNode());

  EVT MemVT = St->getMemoryVT();

  if (MemVT == MVT::i64) {
    // Custom handling for i64 stores: turn it into a bitcast and a
    // v2i32 store.
    SDValue Val = DAG.getNode(ISD::BITCAST, dl, MVT::v2i32, St->getValue());
    SDValue Chain = DAG.getStore(
        St->getChain(), dl, Val, St->getBasePtr(), St->getPointerInfo(),
        St->getOriginalAlign(), St->getMemOperand()->getFlags(),
        St->getAAInfo());
    return Chain;
  }

  return SDValue();
}

SDValue PostriscTargetLowering::LowerADDC_ADDE_SUBC_SUBE(SDValue Op, SelectionDAG &DAG) const {

  if (Op.getValueType() != MVT::i64)
    return Op;

  SDLoc dl(Op);
  SDValue Src1 = Op.getOperand(0);
  SDValue Src1Lo = DAG.getNode(ISD::TRUNCATE, dl, MVT::i32, Src1);
  SDValue Src1Hi = DAG.getNode(ISD::SRL, dl, MVT::i64, Src1,
                               DAG.getConstant(32, dl, MVT::i64));
  Src1Hi = DAG.getNode(ISD::TRUNCATE, dl, MVT::i32, Src1Hi);

  SDValue Src2 = Op.getOperand(1);
  SDValue Src2Lo = DAG.getNode(ISD::TRUNCATE, dl, MVT::i32, Src2);
  SDValue Src2Hi = DAG.getNode(ISD::SRL, dl, MVT::i64, Src2,
                               DAG.getConstant(32, dl, MVT::i64));
  Src2Hi = DAG.getNode(ISD::TRUNCATE, dl, MVT::i32, Src2Hi);


  bool hasChain = false;
  unsigned hiOpc = Op.getOpcode();
  switch (Op.getOpcode()) {
  default:
    LLVM_DEBUG(dbgs() << "Invalid opcode" << Op.getOpcode() << "\n");
    llvm_unreachable("Invalid opcode");
  case ISD::ADDC: hiOpc = ISD::ADDE; break;
  case ISD::ADDE: hasChain = true; break;
  case ISD::SUBC: hiOpc = ISD::SUBE; break;
  case ISD::SUBE: hasChain = true; break;
  }
  SDValue Lo;
  SDVTList VTs = DAG.getVTList(MVT::i32, MVT::Glue);
  if (hasChain) {
    Lo = DAG.getNode(Op.getOpcode(), dl, VTs, Src1Lo, Src2Lo,
                     Op.getOperand(2));
  } else {
    Lo = DAG.getNode(Op.getOpcode(), dl, VTs, Src1Lo, Src2Lo);
  }
  SDValue Hi = DAG.getNode(hiOpc, dl, VTs, Src1Hi, Src2Hi, Lo.getValue(1));
  SDValue Carry = Hi.getValue(1);

  Lo = DAG.getNode(ISD::ZERO_EXTEND, dl, MVT::i64, Lo);
  Hi = DAG.getNode(ISD::ZERO_EXTEND, dl, MVT::i64, Hi);
  Hi = DAG.getNode(ISD::SHL, dl, MVT::i64, Hi,
                   DAG.getConstant(32, dl, MVT::i64));

  SDValue Dst = DAG.getNode(ISD::OR, dl, MVT::i64, Hi, Lo);
  SDValue Ops[2] = { Dst, Carry };
  return DAG.getMergeValues(Ops, dl);
}

// Custom lower UMULO/SMULO for POSTRISC. This code is similar to ExpandNode()
// in LegalizeDAG.cpp except the order of arguments to the library function.
SDValue PostriscTargetLowering::LowerUMULO_SMULO(SDValue Op, SelectionDAG &DAG) const
{
  unsigned opcode = Op.getOpcode();
  assert((opcode == ISD::UMULO || opcode == ISD::SMULO) && "Invalid Opcode.");

  bool isSigned = (opcode == ISD::SMULO);
  EVT VT = MVT::i64;
  EVT WideVT = MVT::i128;
  SDLoc dl(Op);
  SDValue LHS = Op.getOperand(0);

  if (LHS.getValueType() != VT)
    return Op;

  SDValue ShiftAmt = DAG.getConstant(63, dl, VT);

  SDValue RHS = Op.getOperand(1);
  SDValue HiLHS, HiRHS;
  if (isSigned) {
    HiLHS = DAG.getNode(ISD::SRA, dl, VT, LHS, ShiftAmt);
    HiRHS = DAG.getNode(ISD::SRA, dl, MVT::i64, RHS, ShiftAmt);
  } else {
    HiLHS = DAG.getConstant(0, dl, VT);
    HiRHS = DAG.getConstant(0, dl, MVT::i64);
  }

  SDValue Args[] = { HiLHS, LHS, HiRHS, RHS };

  TargetLowering::MakeLibCallOptions CallOptions;
  CallOptions.setSExt(isSigned);
  SDValue MulResult = makeLibCall(DAG,
                                      RTLIB::MUL_I128, WideVT,
                                      Args, CallOptions, dl).first;
  SDValue BottomHalf = DAG.getNode(ISD::EXTRACT_ELEMENT, dl, VT,
                                   MulResult, DAG.getIntPtrConstant(0, dl));
  SDValue TopHalf = DAG.getNode(ISD::EXTRACT_ELEMENT, dl, VT,
                                MulResult, DAG.getIntPtrConstant(1, dl));
  if (isSigned) {
    SDValue Tmp1 = DAG.getNode(ISD::SRA, dl, VT, BottomHalf, ShiftAmt);
    TopHalf = DAG.getSetCC(dl, MVT::i32, TopHalf, Tmp1, ISD::SETNE);
  } else {
    TopHalf = DAG.getSetCC(dl, MVT::i32, TopHalf, DAG.getConstant(0, dl, VT),
                           ISD::SETNE);
  }
  // MulResult is a node with an illegal type. Because such things are not
  // generally permitted during this phase of legalization, ensure that
  // nothing is left using the node. The above EXTRACT_ELEMENT nodes should have
  // been folded.
  assert(MulResult->use_empty() && "Illegally typed node still in use!");

  SDValue Ops[2] = { BottomHalf, TopHalf } ;
  return DAG.getMergeValues(Ops, dl);
}

SDValue PostriscTargetLowering::LowerATOMIC_LOAD_STORE(SDValue Op, SelectionDAG &DAG) const {
  if (isStrongerThanMonotonic(cast<AtomicSDNode>(Op)->getSuccessOrdering())) {
    // Expand with a fence.
    return SDValue();
  }

  // Monotonic load/stores are legal.
  return Op;
}

SDValue PostriscTargetLowering::LowerATOMIC_FENCE(SDValue Op, SelectionDAG &DAG) const {
  SDLoc dl(Op);
  AtomicOrdering FenceOrdering = static_cast<AtomicOrdering>(Op.getConstantOperandVal(1));
  SyncScope::ID FenceSSID = static_cast<SyncScope::ID>(Op.getConstantOperandVal(2));

  // singlethread fences only synchronize with signal handlers on the same
  // thread and thus only need to preserve instruction order, not actually
  // enforce memory ordering.
  if (FenceSSID == SyncScope::SingleThread)
    // MEMBARRIER is a compiler barrier; it codegens to a no-op.
    return DAG.getNode(ISD::MEMBARRIER, dl, MVT::Other, Op.getOperand(0));

  LLVM_DEBUG(dbgs() << "FenceOrdering=" << (int)FenceOrdering
                    << " FenceSSID=" << (int)FenceSSID << "\n");
  assert(FenceSSID == SyncScope::System);

  // FIXME: only for a sequentially-consistent
  LLVM_DEBUG(dbgs() << "lower atomic_fence: "; Op.dump());
  return Op;
}

SDValue PostriscTargetLowering::LowerINTRINSIC_WO_CHAIN(SDValue Op,
                                                     SelectionDAG &DAG) const {
  unsigned IntNo = Op.getConstantOperandVal(0);
  SDLoc dl(Op);
  switch (IntNo) {
  default: return SDValue();    // Don't custom lower most intrinsics.
  case Intrinsic::thread_pointer: {
    EVT PtrVT = getPointerTy(DAG.getDataLayout());
    return DAG.getRegister(POSTRISC::tp, PtrVT);
  }
  }
}

SDValue PostriscTargetLowering::
LowerOperation(SDValue Op, SelectionDAG &DAG) const {
  switch (Op.getOpcode()) {
  default:
    LLVM_DEBUG(dbgs() << "Should not custom lower this!" << Op.getOpcode() << "\n");
    llvm_unreachable("Should not custom lower this!");

  case ISD::RETURNADDR:         return LowerRETURNADDR(Op, DAG);
  case ISD::FRAMEADDR:          return LowerFRAMEADDR(Op, DAG);
  case ISD::GlobalTLSAddress:   return LowerGlobalTLSAddress(Op, DAG);
  case ISD::GlobalAddress:      return LowerGlobalAddress(Op, DAG);
  case ISD::ExternalSymbol:     return LowerExternalSymbol(Op, DAG);
  case ISD::BlockAddress:       return LowerBlockAddress(Op, DAG);
  case ISD::ConstantPool:       return LowerConstantPool(Op, DAG);
  case ISD::JumpTable:          return LowerJumpTable(Op, DAG);

  case ISD::VASTART:            return LowerVASTART(Op, DAG);
  case ISD::DYNAMIC_STACKALLOC: return LowerDYNAMIC_STACKALLOC(Op, DAG);
  case ISD::STORE:              return LowerSTORE(Op, DAG);
  case ISD::ADDC:
  case ISD::ADDE:
  case ISD::SUBC:
  case ISD::SUBE:               return LowerADDC_ADDE_SUBC_SUBE(Op, DAG);
  case ISD::UMULO:
  case ISD::SMULO:              return LowerUMULO_SMULO(Op, DAG);
  case ISD::ATOMIC_LOAD:
  case ISD::ATOMIC_STORE:       return LowerATOMIC_LOAD_STORE(Op, DAG);
  case ISD::ATOMIC_FENCE:       return LowerATOMIC_FENCE(Op, DAG);

  case ISD::INTRINSIC_WO_CHAIN: return LowerINTRINSIC_WO_CHAIN(Op, DAG);
  }
}

SDValue PostriscTargetLowering::bitcastConstantFPToInt(ConstantFPSDNode *C,
                                                    const SDLoc &DL,
                                                    SelectionDAG &DAG) const {
  APInt V = C->getValueAPF().bitcastToAPInt();
  SDValue Lo = DAG.getConstant(V.zextOrTrunc(32), DL, MVT::i32);
  SDValue Hi = DAG.getConstant(V.lshr(32).zextOrTrunc(32), DL, MVT::i32);
  if (DAG.getDataLayout().isLittleEndian())
    std::swap(Lo, Hi);
  return DAG.getBuildVector(MVT::v2i32, DL, {Hi, Lo});
}

SDValue PostriscTargetLowering::PerformBITCASTCombine(SDNode *N,
                                                   DAGCombinerInfo &DCI) const {
  SDLoc dl(N);
  SDValue Src = N->getOperand(0);

  if (isa<ConstantFPSDNode>(Src) && N->getSimpleValueType(0) == MVT::v2i32 &&
      Src.getSimpleValueType() == MVT::f64)
    return bitcastConstantFPToInt(cast<ConstantFPSDNode>(Src), dl, DCI.DAG);

  return SDValue();
}

SDValue PostriscTargetLowering::PerformDAGCombine(SDNode *N,
                                               DAGCombinerInfo &DCI) const {
  switch (N->getOpcode()) {
  default:
    break;
  case ISD::BITCAST:
    return PerformBITCASTCombine(N, DCI);
  }
  return SDValue();
}

MachineBasicBlock *
PostriscTargetLowering::EmitInstrWithCustomInserter(MachineInstr &MI,
                                                 MachineBasicBlock *BB) const {
  switch (MI.getOpcode()) {
  default:
    LLVM_DEBUG(dbgs() << "Unknown SELECT_CC! " << MI.getOpcode() << "\n");
    llvm_unreachable("Unknown SELECT_CC!");
  }
}

MachineBasicBlock *
PostriscTargetLowering::expandSelectCC(MachineInstr &MI, MachineBasicBlock *BB,
                                    unsigned BROpcode) const {
  const TargetInstrInfo &TII = *Subtarget->getInstrInfo();
  DebugLoc dl = MI.getDebugLoc();
  unsigned CC = MI.getOperand(3).getImm();

  // To "insert" a SELECT_CC instruction, we actually have to insert the
  // triangle control-flow pattern. The incoming instruction knows the
  // destination vreg to set, the condition code register to branch on, the
  // true/false values to select between, and the condition code for the branch.
  //
  // We produce the following control flow:
  //     ThisMBB
  //     |  \
  //     |  IfFalseMBB
  //     | /
  //    SinkMBB
  const BasicBlock *LLVM_BB = BB->getBasicBlock();
  MachineFunction::iterator It = ++BB->getIterator();

  MachineBasicBlock *ThisMBB = BB;
  MachineFunction *F = BB->getParent();
  MachineBasicBlock *IfFalseMBB = F->CreateMachineBasicBlock(LLVM_BB);
  MachineBasicBlock *SinkMBB = F->CreateMachineBasicBlock(LLVM_BB);
  F->insert(It, IfFalseMBB);
  F->insert(It, SinkMBB);

  // Transfer the remainder of ThisMBB and its successor edges to SinkMBB.
  SinkMBB->splice(SinkMBB->begin(), ThisMBB,
                  std::next(MachineBasicBlock::iterator(MI)), ThisMBB->end());
  SinkMBB->transferSuccessorsAndUpdatePHIs(ThisMBB);

  // Set the new successors for ThisMBB.
  ThisMBB->addSuccessor(IfFalseMBB);
  ThisMBB->addSuccessor(SinkMBB);

  BuildMI(ThisMBB, dl, TII.get(BROpcode))
    .addMBB(SinkMBB)
    .addImm(CC);

  // IfFalseMBB just falls through to SinkMBB.
  IfFalseMBB->addSuccessor(SinkMBB);

  // %Result = phi [ %TrueValue, ThisMBB ], [ %FalseValue, IfFalseMBB ]
  BuildMI(*SinkMBB, SinkMBB->begin(), dl, TII.get(POSTRISC::PHI),
          MI.getOperand(0).getReg())
      .addReg(MI.getOperand(1).getReg())
      .addMBB(ThisMBB)
      .addReg(MI.getOperand(2).getReg())
      .addMBB(IfFalseMBB);

  MI.eraseFromParent(); // The pseudo instruction is gone now.
  return SinkMBB;
}

//===----------------------------------------------------------------------===//
//                         Postrisc Inline Assembly Support
//===----------------------------------------------------------------------===//

/// getConstraintType - Given a constraint letter, return the type of
/// constraint it is for this target.
PostriscTargetLowering::ConstraintType
PostriscTargetLowering::getConstraintType(StringRef Constraint) const {
  if (Constraint.size() == 1) {
    switch (Constraint[0]) {
    default:  break;
    case 'r':
    case 'f':
    case 'e':
      return C_RegisterClass;
    case 'I': // SIMM21
      return C_Immediate;
    }
  }

  return TargetLowering::getConstraintType(Constraint);
}

TargetLowering::ConstraintWeight PostriscTargetLowering::
getSingleConstraintMatchWeight(AsmOperandInfo &info,
                               const char *constraint) const {
  ConstraintWeight weight = CW_Invalid;
  Value *CallOperandVal = info.CallOperandVal;
  // If we don't have a value, we can't do a match,
  // but allow it at the lowest weight.
  if (!CallOperandVal)
    return CW_Default;

  // Look at the constraint type.
  switch (*constraint) {
  default:
    weight = TargetLowering::getSingleConstraintMatchWeight(info, constraint);
    break;
  case 'I': // SIMM21
    if (ConstantInt *C = dyn_cast<ConstantInt>(info.CallOperandVal)) {
      if (isInt<20>(C->getSExtValue()))
        weight = CW_Constant;
    }
    break;
  }
  return weight;
}

/// LowerAsmOperandForConstraint - Lower the specified operand into the Ops
/// vector.  If it is invalid, don't add anything to Ops.
void PostriscTargetLowering::LowerAsmOperandForConstraint(
    SDValue Op, StringRef Constraint, std::vector<SDValue> &Ops,
    SelectionDAG &DAG) const {
  SDValue Result;

  // Only support length 1 constraints for now.
  if (Constraint.size() > 1)
    return;

  char ConstraintLetter = Constraint[0];
  switch (ConstraintLetter) {
  default: break;
  case 'I':
    if (ConstantSDNode *C = dyn_cast<ConstantSDNode>(Op)) {
      if (isInt<20>(C->getSExtValue())) {
        Result = DAG.getTargetConstant(C->getSExtValue(), SDLoc(Op),
                                       Op.getValueType());
        break;
      }
      return;
    }
  }

  if (Result.getNode()) {
    Ops.push_back(Result);
    return;
  }
  TargetLowering::LowerAsmOperandForConstraint(Op, Constraint, Ops, DAG);
}

std::pair<unsigned, const TargetRegisterClass *>
PostriscTargetLowering::getRegForInlineAsmConstraint(const TargetRegisterInfo *TRI,
                                                  StringRef Constraint,
                                                  MVT VT) const {
  if (Constraint.empty())
    return std::make_pair(0U, nullptr);

  if (Constraint.size() == 1) {
    switch (Constraint[0]) {
    default:
      return std::make_pair(0U, nullptr);
    case 'r':
    case 'f':
    case 'e':
      return std::make_pair(0U, &POSTRISC::GRRegClass);
    }
  }

  // Clang will correctly decode the usage of register name aliases into their official names.
  unsigned XRegFromAlias = StringSwitch<unsigned>(Constraint.upper())
#define X(NAME) .Case("{" #NAME "}", POSTRISC::NAME)
    X(r0)  X(r1)  X(r2)  X(r3)  X(r4)  X(r5)  X(r6)  X(r7)  X(r8)  X(r9)
    X(r10) X(r11) X(r12) X(r13) X(r14) X(r15) X(r16) X(r17) X(r18) X(r19)
    X(r20) X(r21) X(r22) X(r23) X(r24) X(r25) X(r26) X(r27) X(r28) X(r29)
    X(r30) X(r31) X(r32) X(r33) X(r34) X(r35) X(r36) X(r37) X(r38) X(r39)
    X(r40) X(r41) X(r42) X(r43) X(r44) X(r45) X(r46) X(r47) X(r48) X(r49)
    X(r50) X(r51) X(r52) X(r53) X(r54) X(r55) X(r56) X(r57) X(r58) X(r59)
    X(r60) X(r61) X(r62) X(r63) X(r64) X(r65) X(r66) X(r67) X(r68) X(r69)
    X(r70) X(r71) X(r72) X(r73) X(r74) X(r75) X(r76) X(r77) X(r78) X(r79)
    X(r80) X(r81) X(r82) X(r83) X(r84) X(r85) X(r86) X(r87) X(r88) X(r89)
    X(r90) X(r91) X(r92) X(r93) X(r94) X(r95) X(r96) X(r97) X(r98) X(r99)
    X(r100) X(r101) X(r102) X(r103) X(r104) X(r105) X(r106) X(r107) X(r108) X(r109)
    X(r110) X(r111) X(r112) X(r113) X(r114) X(r115) X(r116) X(r117) X(r118) X(r119)
    X(g0) X(g1) X(g2) X(g3) X(tp) X(fp) X(sp) X(gz)
#undef X
   .Default(POSTRISC::NoRegister);

  if (XRegFromAlias != POSTRISC::NoRegister)
    return std::make_pair(XRegFromAlias, &POSTRISC::GRRegClass);

  auto ResultPair =
      TargetLowering::getRegForInlineAsmConstraint(TRI, Constraint, VT);
  if (!ResultPair.second)
    return std::make_pair(0U, nullptr);

  return ResultPair;
}

bool
PostriscTargetLowering::isOffsetFoldingLegal(const GlobalAddressSDNode *GA) const {
  // LowerSymbolOperand should emit offset if we fold it in GlobalAddressNodes
  return true;
}

void PostriscTargetLowering::ReplaceNodeResults(SDNode *N,
                                             SmallVectorImpl<SDValue>& Results,
                                             SelectionDAG &DAG) const {

  SDLoc dl(N);

  // RTLIB::Libcall libCall = RTLIB::UNKNOWN_LIBCALL;

  switch (N->getOpcode()) {
  default:
    dbgs() << "Do not know how to custom type legalize this operation! " << N->getOpcode() << "\n";
    N->dump();
    llvm_unreachable("Do not know how to custom type legalize this operation!");

#if 0
  case ISD::READCYCLECOUNTER: {
    Results.push_back(DAG.getCopyFromReg(N->getOperand(0), dl, POSTRISC::itc, MVT::i64));
    Results.push_back(N->getOperand(0));
    return;
  }
#endif
  case ISD::LOAD: {
    LoadSDNode *Ld = cast<LoadSDNode>(N);
    // Custom handling only for i64: turn i64 load into a v2i32 load,
    // and a bitcast.
    if (Ld->getValueType(0) != MVT::i64 || Ld->getMemoryVT() != MVT::i64)
      return;

    SDLoc dl(N);
    SDValue LoadRes = DAG.getExtLoad(
        Ld->getExtensionType(), dl, MVT::v2i32, Ld->getChain(),
        Ld->getBasePtr(), Ld->getPointerInfo(), MVT::v2i32,
        Ld->getOriginalAlign(), Ld->getMemOperand()->getFlags(),
        Ld->getAAInfo());

    SDValue Res = DAG.getNode(ISD::BITCAST, dl, MVT::i64, LoadRes);
    Results.push_back(Res);
    Results.push_back(LoadRes.getValue(1));
    return;
  }
  }
}

// Override to enable LOAD_STACK_GUARD lowering on Linux.
bool PostriscTargetLowering::useLoadStackGuardNode() const {
  if (!Subtarget->isTargetLinux())
    return TargetLowering::useLoadStackGuardNode();
  return true;
}

// Override to disable global variable loading on Linux.
void PostriscTargetLowering::insertSSPDeclarations(Module &M) const {
  if (!Subtarget->isTargetLinux())
    return TargetLowering::insertSSPDeclarations(M);
}

//===-------------------------------------------------------------===//
// jumptable lowering
//===-------------------------------------------------------------===//

/// Return the entry encoding for a jump table in the
/// current function.  The returned value is a member of the
/// MachineJumpTableInfo::JTEntryKind enum.
unsigned PostriscTargetLowering::getJumpTableEncoding() const
{
  return MachineJumpTableInfo::EK_LabelDifference32;
#if 0
  // In GOT pic mode, each entry in the jump table is emitted as a @GOTOFF symbol.
  if (isPositionIndependent() && Subtarget.isPICStyleGOT())
    return MachineJumpTableInfo::EK_Custom32;

  // Otherwise, use the normal jump table encoding heuristics.
  return TargetLowering::getJumpTableEncoding();
#endif
}

const MCExpr *
PostriscTargetLowering::LowerCustomJumpTableEntry(const MachineJumpTableInfo *MJTI,
                                             const MachineBasicBlock *MBB,
                                             unsigned uid,MCContext &Ctx) const{
  assert(0);
  // assert(isPositionIndependent() && Subtarget.isPICStyleGOT());
  // In 32-bit ELF systems, our jump table entries are formed with @GOTOFF
  // entries.
  return MCSymbolRefExpr::create(MBB->getSymbol(),
                                 MCSymbolRefExpr::VK_GOTOFF, Ctx);
}

/// Returns relocation base for the given PIC jumptable.
SDValue PostriscTargetLowering::getPICJumpTableRelocBase(SDValue Table,
                                                    SelectionDAG &DAG) const {
#if 0
  if (!Subtarget.is64Bit())
    // This doesn't have SDLoc associated with it, but is not really the
    // same as a Register.
    return DAG.getNode(X86ISD::GlobalBaseReg, SDLoc(),
                       getPointerTy(DAG.getDataLayout()));
#endif
  return Table;
}

/// This returns the relocation base for the given PIC jumptable,
/// the same as getPICJumpTableRelocBase, but as an MCExpr.
const MCExpr *PostriscTargetLowering::
getPICJumpTableRelocBaseExpr(const MachineFunction *MF, unsigned JTI,
                             MCContext &Ctx) const {
#if 0
  // X86-64 uses RIP relative addressing based on the jump table label.
  if (Subtarget.isPICStyleRIPRel())
    return TargetLowering::getPICJumpTableRelocBaseExpr(MF, JTI, Ctx);

  // Otherwise, the reference is relative to the PIC base.
  return MCSymbolRefExpr::create(MF->getPICBaseSymbol(), Ctx);
#endif
  // The normal PIC reloc base is the label at the start of the jump table.
  switch (getTargetMachine().getCodeModel()) {
  case CodeModel::Tiny:
  case CodeModel::Small:
  case CodeModel::Medium:
    return TargetLowering::getPICJumpTableRelocBaseExpr(MF, JTI, Ctx);
  case CodeModel::Large:
  default:
    return MCSymbolRefExpr::create(MF->getPICBaseSymbol(), Ctx);
  }
  // return MCSymbolRefExpr::create(MF->getJTISymbol(JTI, Ctx), Ctx);
}

Instruction *PostriscTargetLowering::
emitLeadingFence(IRBuilderBase &Builder,
                 Instruction *I, AtomicOrdering Ord) const {
  if (Ord == AtomicOrdering::SequentiallyConsistent) {
    LLVM_DEBUG(dbgs() << "emitLeadingFence: SeqCst\n");
    return Builder.CreateFence(Ord);
  }
  if (isa<StoreInst>(I) && isReleaseOrStronger(Ord)) {
    LLVM_DEBUG(dbgs() << "emitLeadingFence: Store\n");
    return Builder.CreateFence(AtomicOrdering::Release);
  }
  LLVM_DEBUG(dbgs() << "emitLeadingFence: none\n");
  return nullptr;
}

Instruction *PostriscTargetLowering::
emitTrailingFence(IRBuilderBase &Builder,
                  Instruction *Inst, AtomicOrdering Ord) const {
  if (isa<LoadInst>(Inst) && isAcquireOrStronger(Ord))
    return Builder.CreateFence(AtomicOrdering::Acquire);
  return nullptr;
}

bool PostriscTargetLowering::
shouldInsertFencesForAtomic(const Instruction *I) const {
  LLVM_DEBUG(dbgs() << "shouldInsertFencesForAtomic\n");
  // we need fences in case of SEQ_CST ordering
  AtomicOrdering ordering;
  switch (I->getOpcode()) {
  default:
    LLVM_DEBUG(dbgs() << "Unknown opcode: " << I->getOpcode() << " no ordering detected\n");
    return false;
  case Instruction::Load:
    return false;
    // FIXME: there is no need for additional fence for load, because it is for store
    ordering = cast<LoadInst>(I)->getOrdering();
    LLVM_DEBUG(dbgs() << "Store: " << toIRString(ordering) << "\n");
    return ordering == AtomicOrdering::SequentiallyConsistent;
  case Instruction::Store:
    return false;
    ordering = cast<StoreInst>(I)->getOrdering();
    LLVM_DEBUG(dbgs() << "Store: " << toIRString(ordering) << "\n");
    return ordering == AtomicOrdering::SequentiallyConsistent;
  case Instruction::AtomicCmpXchg:
    ordering = cast<AtomicCmpXchgInst>(I)->getSuccessOrdering();
    LLVM_DEBUG(dbgs() << "AtomicCmpXchg: " << toIRString(ordering) << "\n");
    return ordering == AtomicOrdering::SequentiallyConsistent;
  case Instruction::AtomicRMW:
    ordering = cast<AtomicRMWInst>(I)->getOrdering();
    LLVM_DEBUG(dbgs() << "AtomicRMW: " << toIRString(ordering) << "\n");
    return ordering == AtomicOrdering::SequentiallyConsistent;
  }
}

// Whether AtomicExpandPass should automatically insert fences
// and reduce ordering for this atomic.
bool PostriscTargetLowering::
shouldInsertTrailingFenceForAtomicStore(const Instruction *I) const {
  // we need add fences in case of SEQ_CST ordering
  AtomicOrdering ordering;
  LLVM_DEBUG(dbgs() << "shouldInsertTrailingFenceForAtomicStore ");
  switch (I->getOpcode()) {
  default:
    LLVM_DEBUG(dbgs() << "Unknown opcode: " << I->getOpcode() << " no ordering detected\n");
    return false;
  case Instruction::Load:
    return false;
    // FIXME: there is no need for additional fence for load, because it is for store
    ordering = cast<LoadInst>(I)->getOrdering();
    LLVM_DEBUG(dbgs() << "Store: " << toIRString(ordering) << "\n");
    return ordering == AtomicOrdering::SequentiallyConsistent;
  case Instruction::Store:
    return false;
    ordering = cast<StoreInst>(I)->getOrdering();
    LLVM_DEBUG(dbgs() << "Store: " << toIRString(ordering) << "\n");
    return ordering == AtomicOrdering::SequentiallyConsistent;
  case Instruction::AtomicCmpXchg:
    ordering = cast<AtomicCmpXchgInst>(I)->getSuccessOrdering();
    LLVM_DEBUG(dbgs() << "AtomicCmpXchg: " << toIRString(ordering) << "\n");
    return ordering == AtomicOrdering::SequentiallyConsistent;
  case Instruction::AtomicRMW:
    ordering = cast<AtomicRMWInst>(I)->getOrdering();
    LLVM_DEBUG(dbgs() << "AtomicRMW: " << toIRString(ordering) << "\n");
    return ordering == AtomicOrdering::SequentiallyConsistent;
  }
}

bool PostriscTargetLowering::
isFMAFasterThanFMulAndFAdd(const MachineFunction &MF, EVT VT) const {
  return true;
}
