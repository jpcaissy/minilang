module literal_analysis

import minilang_test_parser

class LiteralAnalysis
    super Visitor

    redef fun visit(n) do n.accept_literal(self)
end

redef class Node
    fun accept_literal(v: LiteralAnalysis) do visit_children(v)
end

redef class Nexpr_int
    var value: nullable Int
    redef fun accept_literal(v) do
        value = n_int.text.to_i
        if value.to_s != n_int.text then
            print "Error: Integer overflow"
            exit(-1)
        end
    end
end
