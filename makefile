.PHONY: clean
base: a.out



a.out:
	bison -d parser.y
	flex lexer.l
	g++ -ll lex.yy.c parser.tab.c 
	
simple.pdf:
	./a.out [filename].py
	dot -Tpdf output.dot -o simple.pdB

clean:
	rm -f a.out lex.yy.c parser.tab* parser_with_actions.t*


