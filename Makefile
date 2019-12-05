build:
	bison -d rosacees.y -o rosacees.bison.cpp -Wnone
	flex -o rosacees.lex.cpp rosacees.l
	g++ -g -c rosacees.cpp -o rosacees.o 
	g++ -g -c sha256.cpp -o sha256.o
	g++ rosacees.bison.cpp rosacees.lex.cpp rosacees.o sha256.o -o rosacees

run:
	./rosacees

ex:
	./rosacees exemple