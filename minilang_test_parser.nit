# Generated by nitcc for the language minilang
import nitcc_runtime
import minilang_lexer
import minilang_parser
class TestParser_minilang
	super TestParser
	redef fun name do return "minilang"
	redef fun new_lexer(text) do return new Lexer_minilang(text)
	redef fun new_parser do return new Parser_minilang
end
var t = new TestParser_minilang
t.main
