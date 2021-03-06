import 'package:honey/honey.dart';
import 'package:honey_core/honey_core.dart';
import 'package:honey/src/runner/context/honey_context.dart';

abstract class LogicFunctions {
  static const functions = {
    'and': and,
    'or': or,
    'not': not,
  };

  static Future<Expression> and(HoneyContext ctx, FunctionParams params) async {
    final left = await params.getAndEval(ctx, 0);
    final right = await params.getAndEval(ctx, 1);
    var result = false;
    if (left is ValueExp && right is ValueExp) {
      result = left.asBool && right.asBool;
    }
    return ValueExp(result, retry: left.retry || right.retry);
  }

  static Future<Expression> or(HoneyContext ctx, FunctionParams params) async {
    final left = await params.getAndEval(ctx, 0);
    final right = await params.getAndEval(ctx, 1);
    var result = false;
    if (left is ValueExp && right is ValueExp) {
      result = left.asBool || right.asBool;
    }
    return ValueExp(result, retry: left.retry || right.retry);
  }

  static Future<Expression> not(HoneyContext ctx, FunctionParams params) async {
    final exp = await params.getAndEval(ctx, 0);
    if (exp is ValueExp) {
      return ValueExp(exp.asBool, retry: exp.retry);
    } else {
      return ValueExp.empty(retry: exp.retry);
    }
  }
}
