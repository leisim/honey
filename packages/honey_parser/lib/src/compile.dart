import 'package:antlr4/antlr4.dart';
import 'package:antlr4/src/util/bit_set.dart';
import 'package:honey_core/honey_core.dart';
import 'package:honey_parser/src/visitors/script_visitor.dart';

import 'antlr.dart';

final strRegex = RegExp(
  "[^\"]+|\"(?:\"|[^\\\"])*\"",
  multiLine: true,
);

CompilationResult compileHoneyTalk(String script) {
  final scriptLc = script.replaceAllMapped(strRegex, (match) {
    final value = match.group(0)!;
    return value.startsWith('"') ? value : value.toLowerCase();
  });

  final chars = InputStream.fromString(scriptLc);
  final lexer = HoneyTalkLexer(chars);
  final tokens = CommonTokenStream(lexer);
  final parser = HoneyTalkParser(tokens);

  CompilationResult? error;
  parser.removeErrorListeners();
  parser.addErrorListener(HoneyErrorListener((e) {
    error = e;
  }));

  final statements = parser.script().accept(ScriptVisitor())!;

  return error ?? CompilationResult(statements: statements);
}

class HoneyErrorListener extends ErrorListener {
  final Function(CompilationResult error) errorListener;

  HoneyErrorListener(this.errorListener);

  @override
  void reportAmbiguity(Parser recognizer, DFA dfa, int startIndex,
      int stopIndex, bool exact, BitSet? ambigAlts, ATNConfigSet configs) {}

  @override
  void reportAttemptingFullContext(Parser recognizer, DFA dfa, int startIndex,
      int stopIndex, BitSet? conflictingAlts, ATNConfigSet configs) {}

  @override
  void reportContextSensitivity(Parser recognizer, DFA dfa, int startIndex,
      int stopIndex, int prediction, ATNConfigSet configs) {}

  @override
  void syntaxError(
      Recognizer<ATNSimulator> recognizer,
      Object? offendingSymbol,
      int? line,
      int charPositionInLine,
      String msg,
      RecognitionException<IntStream>? e) {
    final token = offendingSymbol is Token ? offendingSymbol.text : null;
    final result = CompilationResult(
      errorLine: line ?? 0,
      errorColumn: charPositionInLine,
      errorToken: token,
    );
    errorListener(result);
  }
}

class CompilationResult {
  final List<Statement>? statements;
  final int? errorLine;
  final int? errorColumn;
  final String? errorToken;

  CompilationResult({
    this.statements,
    this.errorLine,
    this.errorColumn,
    this.errorToken,
  });

  bool get hasError => errorLine != null;
}
