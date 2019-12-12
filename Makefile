build:
	@echo " ________________________________________"
	@echo "|          _,--._.-,                     |"
	@echo "|         /\\_r-,\\_ )                     |"
	@echo "|      .-.) _;='_/ (.;                   |"
	@echo "|       \\ \\'     \\/S )                   |"
	@echo "|        L.'-. _.'|-'                    |"
	@echo "|       <_\`-'\\'_.'/                      |"
	@echo "|          \`'-._( \\    Rosacées          |"
	@echo "|           ___   \\\\,      ___           |"
	@echo "|           \\ .'-. \\\\   .-'_. /          |"
	@echo "|            '._' '.\\\\/.-'_.'            |"
	@echo "|               '--\`\`\\('--'              |"
	@echo "|                     \\\\                 |"
	@echo "|                     \`\\\\,               |"
	@echo "|                       \\|               |"
	@echo " \`\`\`\`\`\`\`\`\`\`\`\`\`\`\`\`\`\`\`\`\`\`\`\`\`\`\`\`\`\`\`\`\`\`\`\`\`\`\`\`\`"
	bison -d src/rosacees.y -o src/rosacees.bison.cpp -Wnone
	flex -o src/rosacees.lex.cpp src/rosacees.l
	g++ -g -c src/rosacees.cpp -o o/rosacees.o 
	g++ -g -c src/sha256.cpp -o o/sha256.o
	g++ -g -c src/encrypt.cpp -o o/encrypt.o
	g++ src/rosacees.bison.cpp src/rosacees.lex.cpp o/rosacees.o o/sha256.o o/encrypt.o -o rosacees

run:
	./rosacees

ex:
	./rosacees exemple.rpp

compile:
	./rosacees exemple.rpp -c