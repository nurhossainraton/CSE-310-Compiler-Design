%option noyywrap
%x SINGLE_COMMENT_STATE
%x MULTI_COMMENT_STATE
%x STRING_STATE

%{
#include <stdio.h>
#include <ctype.h>
#include <cstdio>
#include <cstdlib>
#include <string.h>
#include <vector>
#include "1905117.h"
using namespace std;

int line_count=1;
int error_count =0;
int line =0;
int i=0,j=0;
FILE *logout;
FILE *Tokenout;

 string scomment,mcomment ;
 string slog,sToken;
 char str[1000000];
 char str2[100000];


SymbolTable st(10);

string LowerCase(string s)
{
	for(auto &c:s) c = tolower(c);
    return s;
}
string UpperCase(string s){
    for(auto &c:s) c = toupper(c);
    return s;
}


char characterProcessor(char *ch){
        if(ch[1] != '\\'){
            return ch[1];
        } else if(ch[1] == '\\') {
            if(ch[2] == 'n')
                return (char)10;
                else if(ch[2] == '\\')
                return (char)92;
				else if(ch[2] == 'f')
                return (char)12;
                else if(ch[2] == 'a')
                return (char)7;
				else if(ch[2] == 't')
                return (char)9;
				else if(ch[2] == '\'')
                return (char)39;
				else if(ch[2] == 'b')
                return (char)8;
				else if(ch[2] == '\"')
                return (char)34; 
                else if(ch[2] == 'r')
                return (char)13;
                else if(ch[2] == 'v')
                return (char)11;
                else if(ch[2] == '0')
                return (char)0;
               
        }
        return *ch;
    }
%}
LETTER [a-zA-Z]
CHAR '{LETTER}'|'(\\[nt\\afrbv0\'\"]')
WHITESPACE [ \t\f\r\v]+ 
MULOP "*"|"/"|"%"
INCOP "++"|"--"
RELOP "<"|"<="|">"|">="|"=="|"!=" 
LOGICOP "&&"|"||"
BITOP "&"|"|"|"^"|"<<"|">>"

DIGIT [0-9]
NEWLINE \n
KEYWORD else|for|while|if|do|default|continue|switch|void|int|float|break|char|double|return|case
FLOAT ([0-9]*\.?[0-9]+|[0-9]+\.)(E(+|-)?[0-9]+)?
REDUNDANT_DECIMAL {DIGIT}+\.{DIGIT}+\.({DIGIT}|\.)*
ILL_FORMED_NUMBER ({DIGIT}+\.?{DIGIT}*|\.{DIGIT}+)[Ee][+-]?{DIGIT}*\.({DIGIT}+)?

UNFINISHED_CONST_CHAR '{LETTER}*|'(\\[nt\\afrbv0\'\"])*

MUL_CHAR_ERROR '(([ -~]{-}['\\])([ -~]{-}['\\])+)'


INVALID_PREFIX [0-9][A-Za-z0-9_]*
EMPTY_CHAR_ERROR ''
UNRECOGNIZED_CHARACTER .
%%

{WHITESPACE} {}
{NEWLINE} {line_count++;}
		
{KEYWORD}	{
	       
	       string cap = UpperCase(yytext);
		   string little =  LowerCase(yytext);
			fprintf(Tokenout,"<%s, %s>\n",const_cast<char*>(cap.c_str()),const_cast<char*>(little.c_str()));
			
			fprintf(logout,"Line# %d: Token <%s> ",line_count,const_cast<char*>(cap.c_str()));
			fprintf(logout,"Lexeme %s found\n",const_cast<char*>(little.c_str()));
		}

"+"		|

"-"		{
			fprintf(Tokenout,"<ADDOP, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <ADDOP> Lexeme %s found\n",line_count,yytext);
			//insert in symbol table and print symbol table content(only non empty buckets)
			// There is a '|' in "+"'s rule, this means match execute the action for following rule
			//bool success = st.Insert(string (yytext),)
		}
		
{DIGIT}+ 	{
				fprintf(Tokenout,"<CONST_INT, %s>\n",yytext);
				fprintf(logout,"Line# %d: Token <CONST_INT> Lexeme %s found\n",line_count,yytext);
				//insert in symbol table and print symbol table content(only non empty buckets)
				//SymbolInfo *si=new SymbolInfo(string(yytext),"CONST_INT");
				
			}

{DIGIT}+(\.{DIGIT}+)?([Ee][+-]?{DIGIT}+)?  {
	            fprintf(Tokenout,"<CONST_FLOAT, %s>\n",yytext);
	            fprintf(logout,"Line# %d: Token <CONST_FLOAT> Lexeme %s found\n",line_count,yytext);
}

{CHAR}      {
	            fprintf(Tokenout, "<CONST_CHAR, %c>\n",characterProcessor(yytext));
                fprintf(logout, "Line# %d: Token <CONST_CHAR> Lexeme %c found\n", line_count, characterProcessor(yytext));
}
[_A-Za-z][A-Za-z0-9_]*  {
                fprintf(Tokenout,"<ID, %s>\n",yytext);
	            fprintf(logout,"Line# %d: Token <ID> Lexeme %s found\n",line_count,yytext);
				bool success = st.InsertSymbol(string(yytext),"ID",logout);
				//fprintf(logout,"%d",(int)success);
				if(success) st.printAllScopeTable(logout);
}	      
{MULOP} {
	        fprintf(Tokenout,"<MULOP, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <MULOP> Lexeme %s found\n",line_count,yytext);
}
{INCOP} {
            fprintf(Tokenout,"<INCOP, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <INCOP> Lexeme %s found\n",line_count,yytext);
}
{RELOP} {
            fprintf(Tokenout,"<RELOP, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <RELOP> Lexeme %s found\n",line_count,yytext);
}
{BITOP} {
            fprintf(Tokenout,"<BITOP, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <BITOP> Lexeme %s found\n",line_count,yytext);
}
{LOGICOP} {
            fprintf(Tokenout,"<LOGICOP, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <LOGICOP> Lexeme %s found\n",line_count,yytext);
}
"=" {
	        fprintf(Tokenout,"<ASSIGNOP, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <ASSIGNOP> Lexeme %s found\n",line_count,yytext);
}
"(" {
	        fprintf(Tokenout,"<LPAREN, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <LPAREN> Lexeme %s found\n",line_count,yytext);
}
")" {
	        fprintf(Tokenout,"<RPAREN, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <RPAREN> Lexeme %s found\n",line_count,yytext);
}
"!" {
	        fprintf(Tokenout,"<NOT,%s>\n",yytext);
			fprintf(logout,"Line# %d: Token <NOT> Lexeme %s found\n",line_count,yytext);
}
"{" {
	        st.EnterScope();
	        fprintf(Tokenout,"<LCURL, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <LCURL> Lexeme %s found\n",line_count,yytext);
}
"}" {
	       
	        fprintf(Tokenout,"<RCURL, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <RCURL> Lexeme %s found\n",line_count,yytext);
			st.exitScope();
			

			 
}
"[" {
	        fprintf(Tokenout,"<LSQUARE, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <LSQUARE> Lexeme %s found\n",line_count,yytext);
}
"]" {
	        fprintf(Tokenout,"<RSQUARE, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <RSQUARE> Lexeme %s found\n",line_count,yytext);
}
"," {
	        fprintf(Tokenout,"<COMMA, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <COMMA> Lexeme %s found\n",line_count,yytext);
}
";" {
	        fprintf(Tokenout,"<SEMICOLON, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <SEMICOLON> Lexeme %s found\n",line_count,yytext);
			
}
{REDUNDANT_DECIMAL} {
                    error_count++;
					fprintf(logout,"Error at line# %d: TOO_MANY_DECIMAL_POINTS %s\n",line_count,yytext);

}

{ILL_FORMED_NUMBER} {
                    error_count++;
					fprintf(logout,"Error at line# %d: ILLFORMED_NUMBER %s\n",line_count,yytext);

}
{UNFINISHED_CONST_CHAR} {
                    error_count++;
					fprintf(logout,"Error at line# %d: UNFINISHED_CONST_CHAR %s\n",line_count,yytext);
					

}
{MUL_CHAR_ERROR} {
                    error_count++;
					fprintf(logout,"Error at line# %d: MULTICHAR_CONST_CHAR %s\n",line_count,yytext);

}
{INVALID_PREFIX} {
                    error_count++;
					fprintf(logout,"Error at line# %d: INVALID_ID_SUFFIX_NUM_PREFIX %s\n",line_count,yytext);

}
{EMPTY_CHAR_ERROR} {
                    error_count++;
					fprintf(logout,"Error at line# %d: EMPTY_CONST_CHAR %s\n",line_count,yytext);

}

\/\/ {
	memset(str,0,sizeof(str));
	scomment+="//";
	line=0;
	BEGIN SINGLE_COMMENT_STATE;

}
<SINGLE_COMMENT_STATE>[\r]?\n {
	line++;
	
	fprintf(logout,"Line# %d: Token <SINGLE LINE COMMENT> Lexeme %s found\n",line_count,const_cast<char*>(scomment.c_str()));
	line_count += line;
	scomment = "";
	BEGIN INITIAL;
}
<SINGLE_COMMENT_STATE>\\\r\n {
	line++;
	scomment += yytext;

}
<SINGLE_COMMENT_STATE>\\\n {
	line++;
	scomment += yytext;

}
<SINGLE_COMMENT_STATE>\\ {
    scomment += yytext;
}
<SINGLE_COMMENT_STATE>. {
    scomment += yytext;
}
<SINGLE_COMMENT_STATE><<EOF>> {

}
\/\* { 
	   mcomment = "/*";
	   line =0;
	   BEGIN MULTI_COMMENT_STATE;
}
<MULTI_COMMENT_STATE>\*\/ {
	 mcomment += "*/"; 
	 
	 fprintf(logout,"Line# %d: Token <MULTI LINE COMMENT> Lexeme %s found\n",line_count,const_cast<char*>(mcomment.c_str()));
	  line_count+=line;
	 BEGIN INITIAL;

}
<MULTI_COMMENT_STATE>\r?\n {
	line++;
    mcomment += yytext;
    
}


<MULTI_COMMENT_STATE>. {
    mcomment += yytext[0]; 
}
<MULTI_COMMENT_STATE><<EOF>> {
    error_count++;
	line_count += line;	
    fprintf(logout,"Error at line# %d: UNFINISHED_COMMENT %s \n",line_count,const_cast<char*>(mcomment.c_str()));
	mcomment="";
	
	BEGIN INITIAL;
}
\" {
	 slog = yytext;
     sToken = "";
	 line=line_count;
     BEGIN STRING_STATE;

}
<STRING_STATE>\" {
	
	slog += yytext;
	//sToken += yytext;
    
	if(line == line_count)
	{         
		      
              fprintf(Tokenout, "<SINGLE LINE STRING, %s>\n",const_cast<char*>(sToken.c_str()));
			  fprintf(logout,"Line# %d: Token <SINGLE LINE STRING> Lexeme %s found\n",line_count,const_cast<char*>(slog.c_str()));
			  
	}
	
	else
	{
		 fprintf(Tokenout, "<MULTI LINE STRING, %s>\n",const_cast<char*>(sToken.c_str()));
         fprintf(logout,"Line# %d: Token <MULTI LINE STRING> Lexeme %s found\n",line,const_cast<char*>(slog.c_str()));
		 

	}
	
	sToken="";
	slog = "";
	BEGIN INITIAL;
}
<STRING_STATE>\\[ntafbvr0\\\'\"] {
                                    slog += yytext;
                                    char element = yytext[1];
                                    if(element=='n'){sToken+='\n';}
                                    else if(element=='t'){sToken+='\t';}
                                    else if(element=='a'){sToken+='\a';}
                                    else if(element=='f'){sToken+='\f';}
                                    else if(element=='b'){sToken+='\b';}
                                    else if(element=='v'){sToken+='\v';}
                                    else if(element=='r'){sToken+='\r';}
                                    else if(element=='0'){sToken+='\n';}
                                    else if(element=='\\'){sToken+='\\';}
                                    else if(element=='\''){sToken+='\'';}
                                    else if(element=='\"'){sToken+='\"';}
                                    
}
<STRING_STATE>. {
	slog+= yytext;
	sToken += yytext;
}
<STRING_STATE>[\r]?\n {
	               
	               fprintf(logout,"Error at line# %d: UNFINISHED_STRING %s\n",line_count,const_cast<char*>(slog.c_str()));
				   sToken="";
				   slog = "";
	               line_count++;
				   error_count++;
				   BEGIN INITIAL;


} 
<STRING_STATE><<EOF>> {
	               
	               fprintf(logout,"Error at line# %d: UNFINISHED_STRING %s\n",line_count,const_cast<char*>(slog.c_str()));
				   sToken="";
				   slog = "";
	               line_count++;
				   error_count++;
				   BEGIN INITIAL;


} 
<STRING_STATE>\\\r?\n {
          slog += yytext;
		  line_count++;
}


{UNRECOGNIZED_CHARACTER} {
                    error_count++;
					fprintf(logout,"Error at line# %d: UNRECOGNIZED_CHAR %s\n",line_count,yytext);

}

<<EOF>> {
       st.printAllScopeTable(logout);
	   return 0;
}


%%

int main(int argc, char** argv) {
	if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}
	
	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}
	
	logout= fopen("log.txt","w");
	Tokenout= fopen("Token.txt","w");

	yyin= fin;
	yylex();
	//st.print();
	fprintf(logout,"Total lines: %d\n",line_count);
	fprintf(logout,"Total errors: %d\n",error_count);
	fclose(yyin);
	fclose(Tokenout);
	fclose(logout);
	return 0;
}
