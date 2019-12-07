build:
	@echo " ________________________________________"
	@echo "|          _,--._.-,                     |"
	@echo "|         /\\_r-,\\_ )                     |"
	@echo "|      .-.) _;='_/ (.;                   |"
	@echo "|       \\ \\'     \\/S )                   |"
	@echo "|        L.'-. _.'|-'                    |"
	@echo "|       <_\`-'\\'_.'/                      |"
	@echo "|          \`'-._( \\    Rosacées++        |"
	@echo "|           ___   \\\\,      ___           |"
	@echo "|           \\ .'-. \\\\   .-'_. /          |"
	@echo "|            '._' '.\\\\/.-'_.'            |"
	@echo "|               '--\`\`\\('--'              |"
	@echo "|                     \\\\                 |"
	@echo "|                     \`\\\\,               |"
	@echo "|                       \\|               |"
	@echo " \`\`\`\`\`\`\`\`\`\`\`\`\`\`\`\`\`\`\`\`\`\`\`\`\`\`\`\`\`\`\`\`\`\`\`\`\`\`\`\`\`"
	bison -d rosacees.y -o rosacees.bison.cpp -Wnone
	flex -o rosacees.lex.cpp rosacees.l
	g++ -g -c rosacees.cpp -o rosacees.o 
	g++ -g -c sha256.cpp -o sha256.o
	g++ rosacees.bison.cpp rosacees.lex.cpp rosacees.o sha256.o -o rosacees

run:
	./rosacees

ex:
	./rosacees exemple.rpp

compile:
	./rosacees exemple.rpp compile