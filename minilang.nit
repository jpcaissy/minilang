module minilang

import literal_analysis
import interpreter
import minilang_test_parser
import scope_analysis

var t = new TestParser_minilang
var n = t.main
var literal = new LiteralAnalysis
literal.enter_visit(n)
var scope = new ScopeAnalysis
scope.enter_visit(n)
var interpreter = new Interpreter
interpreter.enter_visit(n)
