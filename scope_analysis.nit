module scope_analysis

import minilang_test_parser

class Scope
    var variables = new HashSet[String]

    init do
    end

    init inherit(s: Scope) do
        variables.add_all(s.variables)
    end

end


class ScopeAnalysis
    super Visitor

    var scopes = new Array[Scope]
    redef fun visit(n) do n.accept_scope(self)
end

redef class Nstmt_if
    redef fun accept_scope(v: ScopeAnalysis) do
        v.scopes.insert(new Scope.inherit(v.scopes.first), 0)
        v.enter_visit(n_stmts)
        v.scopes.shift

        v.scopes.insert(new Scope.inherit(v.scopes.first), 0)
        v.enter_visit(n_else)
        v.scopes.shift
    end
end

redef class Node
    fun accept_scope(v: ScopeAnalysis) do 
        v.scopes.push(new Scope)
        visit_children(v)
    end
end

redef class Nstmt_decl
    redef fun accept_scope(v: ScopeAnalysis) do
        v.scopes.first.variables.add(n_id.text)
    end
end


redef class Nstmt_assign
    redef fun accept_scope(v: ScopeAnalysis) do
        if not v.scopes.first.variables.has(n_left.text) then
            print "Undeclared variable"
            exit(1)
        end
    end
end
