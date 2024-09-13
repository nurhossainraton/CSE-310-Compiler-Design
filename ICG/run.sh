yacc -d -y 1905117.y
g++ -w -c -o y.o y.tab.c
flex 1905117.l
g++ -w -c -o l.o lex.yy.c
g++ y.o l.o -lfl -o run
./run in.c
