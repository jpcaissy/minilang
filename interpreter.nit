module interpreter

import minilang_test_parser
import literal_analysis

class Method
	var node: Node
	var params: Array[String]
end

class Variable
	var value: nullable Int
	init do
		value = null
	end
end

class Scope
	var variables = new ArrayMap[String, Variable]
	var methods = new ArrayMap[String, Method]

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

class Interpreter
	super Visitor

	var scopes = new Array[Scope]
	var values = new Array[Int]
	var conditions = new Array[Bool]
	var params = new Array[String]
	var has_return = false

	redef fun visit(n) do n.accept_interpreter(self)

	init do
		scopes.push(new Scope)
	end
end

redef class Node
	fun accept_interpreter(v: Interpreter) do
		visit_children(v)
	end
end

redef class Ndef
	redef fun accept_interpreter(v) do
		if v.has_return then return

		v.scopes.first.methods[n_id.text] = new Method(self, new Array[String])
		if n_params != null then
			v.enter_visit(n_params.as(not null))
		end
		while not v.params.is_empty do
			v.scopes.first.methods[n_id.text].params.push(v.params.pop)
		end
	end
end

redef class Nparam
	redef fun accept_interpreter(v) do
		if v.has_return then return
		v.params.push(n_id.text)
	end
end


redef class Ncall
	redef fun accept_interpreter(v) do
		v.scopes.insert(new Scope.inherit(v.scopes.first), 0)

		if n_arguments != null then
			v.enter_visit(n_arguments.as(not null))
		end

		for param in v.scopes.first.methods[n_id.text].params do
			v.scopes.first.variables[param] = new Variable
			v.scopes.first.variables[param].value = v.values.pop
		end

		v.scopes.first.methods[n_id.text].node.visit_children(v)

		v.scopes.shift
		v.has_return = false
	end
end

redef class Nstmt_return
	redef fun accept_interpreter(v) do
		if n_expr != null then
			v.enter_visit(n_expr.as(not null))
		end
		v.has_return = true
	end
end

redef class Nexpr_int
	redef fun accept_interpreter(v) do
		if v.has_return then return
		v.values.push(value.as(not null))
	end
end

redef class Nexpr_read
	redef fun accept_interpreter(v) do
		if v.has_return then return
		v.values.push(stdin.read_line.to_i)
	end
end

redef class Nexpr_neg
	redef fun accept_interpreter(v) do
		if v.has_return then return
		super
		v.values.push(-v.values.pop)
	end
end


redef class Nexpr_add
	redef fun accept_interpreter(v) do
		if v.has_return then return
		super
		v.values.push(v.values.pop + v.values.pop)
	end
end

redef class Nexpr_mul
	redef fun accept_interpreter(v) do
		if v.has_return then return
		super
		v.values.push(v.values.pop * v.values.pop)
	end
end

redef class Nexpr_sub
	redef fun accept_interpreter(v) do
		if v.has_return then return
		super
		var right = v.values.pop
		var left = v.values.pop
		v.values.push(left - right)
	end
end

redef class Nexpr_div
	redef fun accept_interpreter(v) do
		if v.has_return then return
		super
		var right = v.values.pop
		var left = v.values.pop
		v.values.push(left / right)
	end
end

redef class Nstmt_print
	redef fun accept_interpreter(v) do
		if v.has_return then return
		super
		print v.values.pop
	end
end

redef class Nstmt_print_str
	redef fun accept_interpreter(v) do
		if v.has_return then return
		print n_str.text.substring(1, n_str.text.length - 2)
	end
end

redef class Nstmt_assign
	redef fun accept_interpreter(v) do
		if v.has_return then return
		super
		v.scopes.first.variables[n_id.text].value = v.values.pop
	end
end

redef class Nstmt_decl
	redef fun accept_interpreter(v) do
		if v.has_return then return
		super
		v.scopes.first.variables[n_id.text] = new Variable
	end
end


redef class Nexpr_var
	redef fun accept_interpreter(v) do
		if v.has_return then return
		super
		v.values.push(v.scopes.first.variables[n_id.text].value.as(not null))
	end
end

redef class Ncond_eq
	redef fun accept_interpreter(v) do
		if v.has_return then return
		super
		v.conditions.push(v.values.pop == v.values.pop)
	end
end

redef class Ncond_ne
	redef fun accept_interpreter(v) do
		if v.has_return then return
		super
		v.conditions.push(v.values.pop != v.values.pop)
	end
end

redef class Ncond_gte
	redef fun accept_interpreter(v) do
		if v.has_return then return
		super
		var right = v.values.pop
		var left = v.values.pop
		v.conditions.push(left >= right)
	end
end

redef class Ncond_lte
	redef fun accept_interpreter(v) do
		if v.has_return then return
		super
		var right = v.values.pop
		var left = v.values.pop
		v.conditions.push(left <= right)
	end
end

redef class Ncond_gt
	redef fun accept_interpreter(v) do
		if v.has_return then return
		super
		var right = v.values.pop
		var left = v.values.pop
		v.conditions.push(left > right)
	end
end

redef class Ncond_lt
	redef fun accept_interpreter(v) do
		if v.has_return then return
		super
		var right = v.values.pop
		var left = v.values.pop
		v.conditions.push(left < right)
	end
end

redef class Nstmt_if
	redef fun accept_interpreter(v) do
		if v.has_return then return
		v.enter_visit(n_cond)

		v.scopes.insert(new Scope.inherit(v.scopes.first), 0)

		if v.conditions.pop then
			v.enter_visit(n_stmts)
		else
			v.enter_visit(n_else)
		end

		v.scopes.shift
	end
end

redef class Nelse_elseif
	redef fun accept_interpreter(v) do
		if v.has_return then return
		v.enter_visit(n_cond)

		v.scopes.insert(new Scope.inherit(v.scopes.first), 0)

		if v.conditions.pop then
			v.enter_visit(n_stmts)
		else
			v.enter_visit(n_else)
		end

		v.scopes.shift
	end
end

redef class Nstmt_while
	redef fun accept_interpreter(v) do
		if v.has_return then return
		v.enter_visit(n_cond)

		v.scopes.insert(new Scope.inherit(v.scopes.first), 0)
		while v.conditions.pop do
			v.enter_visit(n_stmts)
			v.enter_visit(n_cond)
		end
		v.scopes.shift
	end
end

