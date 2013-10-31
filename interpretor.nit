module interpretor

import minilang_test_parser

class Interpretor
    super Visitor

    var values = new Array[Int]
    var conditions = new Array[Bool]
    var variables = new ArrayMap[String, Int]

    redef fun visit(n) do n.accept_interpretor(self)
end

redef class Node
    fun accept_interpretor(v: Interpretor) do visit_children(v)
end

redef class Nexpr_int
    redef fun accept_interpretor(v) do
        v.values.push(n_int.text.to_i)
    end
end

redef class Nexpr_neg
    redef fun accept_interpretor(v) do
        super
        v.values.push(-v.values.pop)
    end
end


redef class Nexpr_add
    redef fun accept_interpretor(v) do
        super
        v.values.push(v.values.pop + v.values.pop)
    end
end

redef class Nexpr_mul
    redef fun accept_interpretor(v) do
        super
        v.values.push(v.values.pop * v.values.pop)
    end
end

redef class Nexpr_sub
    redef fun accept_interpretor(v) do
        super
        var right = v.values.pop
        var left = v.values.pop
        v.values.push(left - right)
    end
end

redef class Nexpr_div
    redef fun accept_interpretor(v) do
        super
        var right = v.values.pop
        var left = v.values.pop
        v.values.push(left / right)
    end
end

redef class Nstmt_print
    redef fun accept_interpretor(v) do
        super
        print v.values.pop
    end
end

redef class Nstmt_print_str
    redef fun accept_interpretor(v) do
        print n_str.text.substring(1, n_str.text.length - 2)
    end
end

redef class Nstmt_assign
    redef fun accept_interpretor(v) do
        super
        v.variables[n_left.text] = v.values.pop
    end
end

redef class Nexpr_var
    redef fun accept_interpretor(v) do
        super
        v.values.push(v.variables[n_id.text])
    end
end

redef class Ncond_eq
    redef fun accept_interpretor(v) do
        super
        v.conditions.push(v.values.pop == v.values.pop)
    end
end

redef class Ncond_ne
    redef fun accept_interpretor(v) do
        super
        v.conditions.push(v.values.pop != v.values.pop)
    end
end

redef class Ncond_gte
    redef fun accept_interpretor(v) do
        super
        var right = v.values.pop
        var left = v.values.pop
        v.conditions.push(left >= right)
    end
end

redef class Ncond_lte
    redef fun accept_interpretor(v) do
        super
        var right = v.values.pop
        var left = v.values.pop
        v.conditions.push(left <= right)
    end
end

redef class Ncond_gt
    redef fun accept_interpretor(v) do
        super
        var right = v.values.pop
        var left = v.values.pop
        v.conditions.push(left > right)
    end
end

redef class Ncond_lt
    redef fun accept_interpretor(v) do
        super
        var right = v.values.pop
        var left = v.values.pop
        v.conditions.push(left < right)
    end
end

redef class Nstmt_if
    redef fun accept_interpretor(v) do
        v.enter_visit(n_cond)
        if v.conditions.pop then v.enter_visit(n_stmts)
    end
end

var t = new TestParser_minilang
var n = t.main
var v = new Interpretor
v.enter_visit(n)
