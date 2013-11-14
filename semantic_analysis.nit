module semantic_analysis

import minilang_test_parser

class SemanticAnalysis
	super Visitor

	redef fun visit(n) do n.accept_semantic(self)
end

redef class Node
	fun accept_semantic(v: SemanticAnalysis) do visit_children(v)
end

