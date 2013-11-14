module minilang

import literal_analysis
import interpreter
import minilang_test_parser
import scope_analysis
import semantic_analysis

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
print "*** Launching interpreter ***"
var interpreter = new Interpreter
interpreter.enter_visit(n)
