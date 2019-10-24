all:
	flex -o rosacees.lex.cpp rosacees.l
	bison -d rosacees.y -o rosacees.bison.cpp
	g++ rosacees.lex.cpp rosacees.bison.cpp -o rosacees
	./rosacees