//===-- lib/Parser/prescan.h ------------------------------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef FORTRAN_PARSER_PRESCAN_H_
#define FORTRAN_PARSER_PRESCAN_H_

// Defines a fast Fortran source prescanning phase that implements some
// character-level features of the language that can be inefficient to
// support directly in a backtracking parser.  This phase handles Fortran
// line continuation, comment removal, card image margins, padding out
// fixed form character literals on truncated card images, file
// inclusion, and driving the Fortran source preprocessor.

#include "flang/Parser/characters.h"
#include "flang/Parser/message.h"
#include "flang/Parser/provenance.h"
#include "flang/Parser/token-sequence.h"
#include "flang/Support/Fortran-features.h"
#include <bitset>
#include <optional>
#include <string>
#include <unordered_set>

namespace Fortran::parser {

class Messages;
class Preprocessor;

class Prescanner {
public:
  Prescanner(Messages &, CookedSource &, Preprocessor &,
      common::LanguageFeatureControl);
  Prescanner(
      const Prescanner &, Preprocessor &, bool isNestedInIncludeDirective);
  Prescanner(const Prescanner &) = delete;
  Prescanner(Prescanner &&) = delete;

  const AllSources &allSources() const { return allSources_; }
  AllSources &allSources() { return allSources_; }
  const Messages &messages() const { return messages_; }
  Messages &messages() { return messages_; }
  const Preprocessor &preprocessor() const { return preprocessor_; }
  Preprocessor &preprocessor() { return preprocessor_; }
  common::LanguageFeatureControl &features() { return features_; }

  Prescanner &set_preprocessingOnly(bool yes) {
    preprocessingOnly_ = yes;
    return *this;
  }
  Prescanner &set_expandIncludeLines(bool yes) {
    expandIncludeLines_ = yes;
    return *this;
  }
  Prescanner &set_fixedForm(bool yes) {
    inFixedForm_ = yes;
    return *this;
  }
  Prescanner &set_encoding(Encoding code) {
    encoding_ = code;
    return *this;
  }
  Prescanner &set_fixedFormColumnLimit(int limit) {
    fixedFormColumnLimit_ = limit;
    return *this;
  }

  Prescanner &AddCompilerDirectiveSentinel(const std::string &);

  void Prescan(ProvenanceRange);
  void Statement();
  void NextLine();

  // Callbacks for use by Preprocessor.
  bool IsAtEnd() const { return nextLine_ >= limit_; }
  bool IsNextLinePreprocessorDirective() const;
  TokenSequence TokenizePreprocessorDirective();
  Provenance GetCurrentProvenance() const { return GetProvenance(at_); }

  const char *IsCompilerDirectiveSentinel(const char *, std::size_t) const;
  const char *IsCompilerDirectiveSentinel(CharBlock) const;
  // 'first' is the sentinel, 'second' is beginning of payload
  std::optional<std::pair<const char *, const char *>>
  IsCompilerDirectiveSentinel(const char *p) const;

  template <typename... A> Message &Say(A &&...a) {
    return messages_.Say(std::forward<A>(a)...);
  }

private:
  struct LineClassification {
    enum class Kind {
      Comment,
      ConditionalCompilationDirective,
      IncludeDirective, // #include
      DefinitionDirective, // #define & #undef
      PreprocessorDirective,
      IncludeLine, // Fortran INCLUDE
      CompilerDirective,
      Source
    };
    LineClassification(Kind k, std::size_t po = 0, const char *s = nullptr)
        : kind{k}, payloadOffset{po}, sentinel{s} {}
    LineClassification(LineClassification &&) = default;
    LineClassification &operator=(LineClassification &&) = default;
    Kind kind;
    std::size_t payloadOffset; // byte offset of content
    const char *sentinel; // if it's a compiler directive
  };

  void BeginSourceLine(const char *at) {
    at_ = at;
    column_ = 1;
    tabInCurrentLine_ = false;
  }

  void BeginSourceLineAndAdvance() {
    BeginSourceLine(nextLine_);
    NextLine();
  }

  void BeginStatementAndAdvance() {
    BeginSourceLineAndAdvance();
    slashInCurrentStatement_ = false;
    preventHollerith_ = false;
    parenthesisNesting_ = 0;
    continuationLines_ = 0;
    isPossibleMacroCall_ = false;
    disableSourceContinuation_ = false;
  }

  Provenance GetProvenance(const char *sourceChar) const {
    return startProvenance_ + (sourceChar - start_);
  }

  ProvenanceRange GetProvenanceRange(
      const char *first, const char *afterLast) const {
    std::size_t bytes = afterLast - first;
    return {startProvenance_ + (first - start_), bytes};
  }

  void EmitChar(TokenSequence &tokens, char ch) {
    tokens.PutNextTokenChar(ch, GetCurrentProvenance());
  }

  void EmitInsertedChar(TokenSequence &tokens, char ch) {
    Provenance provenance{allSources_.CompilerInsertionProvenance(ch)};
    tokens.PutNextTokenChar(ch, provenance);
  }

  char EmitCharAndAdvance(TokenSequence &tokens, char ch) {
    EmitChar(tokens, ch);
    NextChar();
    return *at_;
  }

  bool InCompilerDirective() const { return directiveSentinel_ != nullptr; }
  bool InOpenMPConditionalLine() const {
    return directiveSentinel_ && directiveSentinel_[0] == '$' &&
        !directiveSentinel_[1];
    ;
  }
  bool InFixedFormSource() const {
    return inFixedForm_ && !inPreprocessorDirective_ && !InCompilerDirective();
  }

  bool IsCComment(const char *p) const {
    return p[0] == '/' && p[1] == '*' &&
        (inPreprocessorDirective_ ||
            (!inCharLiteral_ &&
                features_.IsEnabled(
                    common::LanguageFeature::ClassicCComments)));
  }

  void CheckAndEmitLine(TokenSequence &, Provenance newlineProvenance);
  void LabelField(TokenSequence &);
  void EnforceStupidEndStatementRules(const TokenSequence &);
  void SkipToEndOfLine();
  bool MustSkipToEndOfLine() const;
  void NextChar();
  // True when input flowed to a continuation line
  bool SkipToNextSignificantCharacter();
  void SkipCComments();
  void SkipSpaces();
  static const char *SkipWhiteSpace(const char *);
  const char *SkipWhiteSpaceIncludingEmptyMacros(const char *) const;
  const char *SkipWhiteSpaceAndCComments(const char *) const;
  const char *SkipCComment(const char *) const;
  bool NextToken(TokenSequence &);
  bool HandleExponent(TokenSequence &);
  bool HandleKindSuffix(TokenSequence &);
  bool HandleExponentAndOrKindSuffix(TokenSequence &);
  void QuotedCharacterLiteral(TokenSequence &, const char *start);
  void Hollerith(TokenSequence &, int count, const char *start);
  bool PadOutCharacterLiteral(TokenSequence &);
  bool SkipCommentLine(bool afterAmpersand);
  bool IsFixedFormCommentLine(const char *) const;
  const char *IsFreeFormComment(const char *) const;
  std::optional<std::size_t> IsIncludeLine(const char *) const;
  void FortranInclude(const char *quote);
  const char *IsPreprocessorDirectiveLine(const char *) const;
  const char *FixedFormContinuationLine(bool atNewline);
  const char *FreeFormContinuationLine(bool ampersand);
  bool IsImplicitContinuation() const;
  bool FixedFormContinuation(bool atNewline);
  bool FreeFormContinuation();
  bool Continuation(bool mightNeedFixedFormSpace);
  std::optional<LineClassification> IsFixedFormCompilerDirectiveLine(
      const char *) const;
  std::optional<LineClassification> IsFreeFormCompilerDirectiveLine(
      const char *) const;
  LineClassification ClassifyLine(const char *) const;
  LineClassification ClassifyLine(
      TokenSequence &, Provenance newlineProvenance) const;
  void SourceFormChange(std::string &&);
  bool CompilerDirectiveContinuation(TokenSequence &, const char *sentinel);
  bool SourceLineContinuation(TokenSequence &);

  Messages &messages_;
  CookedSource &cooked_;
  Preprocessor &preprocessor_;
  AllSources &allSources_;
  common::LanguageFeatureControl features_;
  bool preprocessingOnly_{false};
  bool expandIncludeLines_{true};
  bool isNestedInIncludeDirective_{false};
  bool backslashFreeFormContinuation_{false};
  bool inFixedForm_{false};
  int fixedFormColumnLimit_{72};
  Encoding encoding_{Encoding::UTF_8};
  int parenthesisNesting_{0};
  int prescannerNesting_{0};
  int continuationLines_{0};
  bool isPossibleMacroCall_{false};
  bool afterPreprocessingDirective_{false};
  bool disableSourceContinuation_{false};

  Provenance startProvenance_;
  const char *start_{nullptr}; // beginning of current source file content
  const char *limit_{nullptr}; // first address after end of current source
  const char *nextLine_{nullptr}; // next line to process; <= limit_
  const char *directiveSentinel_{nullptr}; // current compiler directive

  // These data members are state for processing the source line containing
  // "at_", which goes to up to the newline character before "nextLine_".
  const char *at_{nullptr}; // next character to process; < nextLine_
  int column_{1}; // card image column position of next character
  bool tabInCurrentLine_{false};
  bool slashInCurrentStatement_{false};
  bool preventHollerith_{false}; // CHARACTER*4HIMOM not Hollerith
  bool inCharLiteral_{false};
  bool continuationInCharLiteral_{false};
  bool inPreprocessorDirective_{false};

  // True after processing a continuation that can't be allowed
  // to appear in the middle of an identifier token, but is fixed form,
  // or is free form and doesn't have a space character handy to use as
  // a separator when:
  // a) (standard) doesn't begin with a leading '&' on the continuation
  //     line, but has a non-blank in column 1, or
  // b) (extension) does have a leading '&', but didn't have one
  //    on the continued line.
  bool brokenToken_{false};

  // When a free form continuation marker (&) appears at the end of a line
  // before a INCLUDE or #include, we delete it and omit the newline, so
  // that the first line of the included file is truly a continuation of
  // the line before.  Also used when the & appears at the end of the last
  // line in an include file.
  bool omitNewline_{false};
  bool skipLeadingAmpersand_{false};

  const std::size_t firstCookedCharacterOffset_{cooked_.BufferedBytes()};

  const Provenance spaceProvenance_{
      allSources_.CompilerInsertionProvenance(' ')};
  const Provenance backslashProvenance_{
      allSources_.CompilerInsertionProvenance('\\')};

  // To avoid probing the set of active compiler directive sentinel strings
  // on every comment line, they're checked first with a cheap Bloom filter.
  static const int prime1{1019}, prime2{1021};
  std::bitset<prime2> compilerDirectiveBloomFilter_; // 128 bytes
  std::unordered_set<std::string> compilerDirectiveSentinels_;
};
} // namespace Fortran::parser
#endif // FORTRAN_PARSER_PRESCAN_H_
