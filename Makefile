build:
	bison -d rosacees.y -o rosacees.bison.cpp
	flex -o rosacees.lex.cpp rosacees.l
	g++ -g -c rosacees.cpp -o rosacees.o 
	g++ rosacees.bison.cpp rosacees.lex.cpp rosacees.o -o rosacees

run:
	./rosacees

ex:
	./rosacees exemple