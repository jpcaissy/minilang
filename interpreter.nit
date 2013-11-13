module interpreter

import minilang_test_parser
import literal_analysis

class Variable
	var value: Int
end

class Scope
	var variables = new ArrayMap[String, Variable]

	init do
	end

	init inherit(s: Scope) do
		for key,value in s.variables do
			variables[key] = value
		end
	end


end

class Interpreter
	super Visitor

	var scopes = new Array[Scope]
	var values = new Array[Int]
	var conditions = new Array[Bool]

	redef fun visit(n) do n.accept_interpreter(self)
end

redef class Node
	fun accept_interpreter(v: Interpreter) do
		v.scopes.push(new Scope)
		visit_children(v)
	end
end

redef class Nexpr_int
	redef fun accept_interpreter(v) do
		v.values.push(value.as(not null))
	end
end

redef class Nexpr_read
	redef fun accept_interpreter(v) do
		v.values.push(stdin.read_line.to_i)
	end
end

redef class Nexpr_neg
	redef fun accept_interpreter(v) do
		super
		v.values.push(-v.values.pop)
	end
end


redef class Nexpr_add
	redef fun accept_interpreter(v) do
		super
		v.values.push(v.values.pop + v.values.pop)
	end
end

redef class Nexpr_mul
	redef fun accept_interpreter(v) do
		super
		v.values.push(v.values.pop * v.values.pop)
	end
end

redef class Nexpr_sub
	redef fun accept_interpreter(v) do
		super
		var right = v.values.pop
		var left = v.values.pop
		v.values.push(left - right)
	end
end

redef class Nexpr_div
	redef fun accept_interpreter(v) do
		super
		var right = v.values.pop
		var left = v.values.pop
		v.values.push(left / right)
	end
end

redef class Nstmt_print
	redef fun accept_interpreter(v) do
		super
		print v.values.pop
	end
end

redef class Nstmt_print_str
	redef fun accept_interpreter(v) do
		print n_str.text.substring(1, n_str.text.length - 2)
	end
end

redef class Nstmt_assign
	redef fun accept_interpreter(v) do
		super
		v.scopes.first.variables[n_left.text] = new Variable(v.values.pop)
	end
end

redef class Nexpr_var
	redef fun accept_interpreter(v) do
		super
		v.values.push(v.scopes.first.variables[n_id.text].value)
	end
end

redef class Ncond_eq
	redef fun accept_interpreter(v) do
		super
		v.conditions.push(v.values.pop == v.values.pop)
	end
end

redef class Ncond_ne
	redef fun accept_interpreter(v) do
		super
		v.conditions.push(v.values.pop != v.values.pop)
	end
end

redef class Ncond_gte
	redef fun accept_interpreter(v) do
		super
		var right = v.values.pop
		var left = v.values.pop
		v.conditions.push(left >= right)
	end
end

redef class Ncond_lte
	redef fun accept_interpreter(v) do
		super
		var right = v.values.pop
		var left = v.values.pop
		v.conditions.push(left <= right)
	end
end

redef class Ncond_gt
	redef fun accept_interpreter(v) do
		super
		var right = v.values.pop
		var left = v.values.pop
		v.conditions.push(left > right)
	end
end

redef class Ncond_lt
	redef fun accept_interpreter(v) do
		super
		var right = v.values.pop
		var left = v.values.pop
		v.conditions.push(left < right)
	end
end

redef class Nstmt_if
	redef fun accept_interpreter(v) do
		v.enter_visit(n_cond)
		if v.conditions.pop then
			v.enter_visit(n_stmts)
		else
			v.enter_visit(n_else)
		end
	end
end

redef class Nelse_elseif
	redef fun accept_interpreter(v) do
		v.enter_visit(n_cond)
		if v.conditions.pop then
			v.enter_visit(n_stmts)
		else
			v.enter_visit(n_else)
		end
	end
end

redef class Nstmt_while
	redef fun accept_interpreter(v) do
		v.enter_visit(n_cond)
		while v.conditions.pop do
			v.enter_visit(n_stmts)
			v.enter_visit(n_cond)
		end
	end
end

