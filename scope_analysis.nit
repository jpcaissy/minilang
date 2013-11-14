module scope_analysis

import minilang_test_parser

class Variable
	var assigned = false
end

class Scope
	var variables = new ArrayMap[String, Variable]
	var methods = new ArrayMap[String, Node]

	init do
	end

	init inherit(s: Scope) do
		for key,value in s.variables do
			variables[key] = value
		end
		for key,value in s.methods do
			methods[key] = value
		end
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

redef class Ndef
	redef fun accept_scope(v: ScopeAnalysis) do
		var new_scope = new Scope.inherit(v.scopes.first)
		v.scopes.insert(new_scope, 0)

		if n_params != null then
			v.enter_visit(n_params.as(not null))
		end

		v.enter_visit(n_stmts)
		v.scopes.shift
	end
end

redef class Nparam
	redef fun accept_scope(v: ScopeAnalysis) do
		v.scopes.first.variables[n_id.text] = new Variable
		v.scopes.first.variables[n_id.text].assigned = true
	end
end


redef class Nstmt_while
	redef fun accept_scope(v: ScopeAnalysis) do
		v.scopes.insert(new Scope.inherit(v.scopes.first), 0)
		v.enter_visit(n_stmts)
		v.scopes.shift
	end
end

redef class Nelse_else
	redef fun accept_scope(v: ScopeAnalysis) do
		v.scopes.insert(new Scope.inherit(v.scopes.first), 0)
		v.enter_visit(n_stmts)
		v.scopes.shift
	end
end

redef class Nelse_elseif
	redef fun accept_scope(v: ScopeAnalysis) do
		v.scopes.insert(new Scope.inherit(v.scopes.first), 0)
		v.enter_visit(n_stmts)
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
	redef fun accept_scope(v) do
		super
		v.scopes.first.variables[n_id.text] = new Variable
	end
end

redef class Nexpr_var
	redef fun accept_scope(v: ScopeAnalysis) do
		if not v.scopes.first.variables.has_key(n_id.text) then
			print "Undeclared variable"
			exit(1)
		end

		if not v.scopes.first.variables[n_id.text].assigned then
			print "Unassigned variable"
			exit(1)
		end
	end
end

redef class Nstmt_assign
	redef fun accept_scope(v) do
		if not v.scopes.first.variables.has_key(n_left.text) then
			print "Undeclared variable"
			exit(1)
		end
		v.scopes.first.variables[n_left.text].assigned = true
	end
end
