module minilang_interpreter

import literal_analysis
import scope_analysis
import semantic_analysis
import interpreter
import minilang_test_parser

var t = new TestParser_minilang
var n = t.main
print "*** Literal analysis ***"
var literal = new LiteralAnalysis
literal.enter_visit(n)
print "*** Scope analysis ***"
var scope = new ScopeAnalysis
scope.enter_visit(n)
print "*** Semantic analysis ***"
var semantic = new SemanticAnalysis
semantic.enter_visit(n)
print "*** Interpreting code ***"
var interpreter = new Interpreter
interpreter.enter_visit(n)
