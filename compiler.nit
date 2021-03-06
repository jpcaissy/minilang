module compiler

import minilang_test_parser
import literal_analysis

class Compiler
	super Visitor

	var writer : OStream
	var level = 0
	init do
		writer = new OFStream.open("out.py")
	end
	redef fun visit(n) do n.accept_compiler(self)
end

redef class Node
	fun accept_compiler(v: Compiler) do
		visit_children(v)
	end
	
	fun indent(v: Compiler) do v.writer.write("    "*v.level)
end

redef class Nstmt_print_str
	redef fun accept_compiler(v) do
		indent(v)
		v.writer.write("print({n_str.text})")
		v.writer.write("\n")
	end
end

redef class Nstmt_print
	redef fun accept_compiler(v) do
		indent(v)
		v.writer.write("print(")
		visit_children(v)
		v.writer.write(")")
		v.writer.write("\n")
	end
end

redef class Nexpr_int
	redef fun accept_compiler(v) do
		v.writer.write(value.as(not null).to_s)
	end
end

redef class Nexpr_mod
	redef fun accept_compiler(v) do
		v.enter_visit(n_left)
		v.writer.write("%")
		v.enter_visit(n_right)
	end
end

redef class Nexpr_mul
	redef fun accept_compiler(v) do
		v.enter_visit(n_left)
		v.writer.write("*")
		v.enter_visit(n_right)
	end
end

redef class Nexpr_div
	redef fun accept_compiler(v) do
		v.enter_visit(n_left)
		v.writer.write("/")
		v.enter_visit(n_right)
	end
end

redef class Nexpr_add
	redef fun accept_compiler(v) do
		v.enter_visit(n_left)
		v.writer.write("+")
		v.enter_visit(n_right)
	end
end

redef class Nexpr_sub
	redef fun accept_compiler(v) do
		v.enter_visit(n_left)
		v.writer.write("-")
		v.enter_visit(n_right)
	end
end

redef class Nexpr_neg
	redef fun accept_compiler(v) do
		v.writer.write("-")
		v.enter_visit(n_expr_4)
	end
end

redef class Nexpr_par
	redef fun accept_compiler(v) do
		v.writer.write("(")
		visit_children(v)
		v.writer.write(")")
	end
end

redef class Ncond_ne
	redef fun accept_compiler(v) do
		v.enter_visit(n_left)
		v.writer.write("!=")
		v.enter_visit(n_right)
	end
end


redef class Ncond_lte
	redef fun accept_compiler(v) do
		v.enter_visit(n_left)
		v.writer.write("<=")
		v.enter_visit(n_right)
	end
end


redef class Ncond_gte
	redef fun accept_compiler(v) do
		v.enter_visit(n_left)
		v.writer.write(">=")
		v.enter_visit(n_right)
	end
end


redef class Ncond_lt
	redef fun accept_compiler(v) do
		v.enter_visit(n_left)
		v.writer.write("<")
		v.enter_visit(n_right)
	end
end


redef class Ncond_gt
	redef fun accept_compiler(v) do
		v.enter_visit(n_left)
		v.writer.write(">")
		v.enter_visit(n_right)
	end
end

redef class Ncond_eq
	redef fun accept_compiler(v) do
		v.enter_visit(n_left)
		v.writer.write("==")
		v.enter_visit(n_right)
	end
end

redef class Nstmt_if
	redef fun accept_compiler(v) do
		indent(v)
		v.writer.write("if ")
		v.enter_visit(n_cond)
		v.writer.write(":\n")
		v.level += 1
		if n_stmts.number_of_children == 0 then
			indent(v)
			v.writer.write("pass\n")
		else
			v.enter_visit(n_stmts)
		end
		v.level -= 1
		v.enter_visit(n_else)
	end
end

redef class Nelse_elseif
	redef fun accept_compiler(v) do
		indent(v)
		v.writer.write("elif ")
		v.enter_visit(n_cond)
		v.writer.write(":\n")
		v.level += 1
		v.enter_visit(n_stmts)
		v.level -= 1
		v.enter_visit(n_else)
	end
end

redef class Nelse_else
	redef fun accept_compiler(v) do
		indent(v)
		v.writer.write("else:\n")
		v.level += 1
		v.enter_visit(n_stmts)
		v.level -= 1
	end
end

redef class Nstmt_while
	redef fun accept_compiler(v) do
		indent(v)
		v.writer.write("while ")
		v.enter_visit(n_cond)
		v.writer.write(":\n")
		v.level += 1
		v.enter_visit(n_stmts)
		v.level -= 1
	end
end

redef class Nstmt_decl
	redef fun accept_compiler(v) do
		#nothing
	end
end

redef class Nstmt_assign
	redef fun accept_compiler(v) do
		indent(v)
		v.writer.write("var_{n_id.text} = ")
		v.enter_visit(n_expr)
		v.writer.write("\n")
	end
end

redef class Nparams_multiple
	redef fun accept_compiler(v) do
		v.enter_visit(n_params)
		v.writer.write(", ")
		v.enter_visit(n_param)
	end
end

redef class Nparam
	redef fun accept_compiler(v) do
		v.writer.write("var_{n_id.text}")
	end
end

redef class Ndef
	redef fun accept_compiler(v) do
		indent(v)
		v.writer.write("def fun_{n_id.text}(")
		if n_params != null then
			v.enter_visit(n_params.as(not null))
		else
			indent(v)
			v.writer.write("pass")
		end
		v.writer.write("):\n")
		v.level += 1
		v.enter_visit(n_stmts)
		v.level -= 1
	end
end

redef class Nexpr_var
	redef fun accept_compiler(v) do
		v.writer.write("var_{n_id.text}")
	end
end

redef class Nstmt_return
	redef fun accept_compiler(v) do
		indent(v)
		v.writer.write("return\n")
	end
end

redef class Nstmt_call
	redef fun accept_compiler(v) do
		indent(v)
		v.enter_visit(n_call)
	end
end

redef class Ncall
	redef fun accept_compiler(v) do
		if n_arguments != null then
			v.enter_visit(n_arguments.as(not null))
		end
		v.writer.write("fun_{n_id.text}(")
		v.writer.write(")\n")
	end
end

redef class Narguments_multiple
	redef fun accept_compiler(v) do
		v.enter_visit(n_arguments)
		v.writer.write(", ")
		v.enter_visit(n_expr)
	end
end

