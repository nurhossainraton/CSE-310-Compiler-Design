%option noyywrap
%x SINGLE_COMMENT_STATE
%x MULTI_COMMENT_STATE
%x STRING_STATE

%{

#include<bits/stdc++.h>
#include "1905117.h"
#include "y.tab.h"
using namespace std;

int line_count=1;
int error_count =0;
int line =0;
int i=0,j=0;
extern ofstream logout;
extern YYSTYPE yylval;
extern SymbolTable *symboltable;
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
CHARACTER '{LETTER}'|'(\\[nt\\afrbv0\'\"]')
WHITESPACE [ \t\f\r\v]+ 
MULOP "*"|"/"|"%"
INCOP "++"
DECOP "--"
RELOP "<"|"<="|">"|">="|"=="|"!=" 
LOGICOP "&&"|"||"
BITOP "&"|"|"|"^"|"<<"|">>"

DIGIT [0-9]
NEWLINE \n

FLOATNUM ([0-9]*\.?[0-9]+|[0-9]+\.)(E(+|-)?[0-9]+)?
REDUNDANT_DECIMAL {DIGIT}+\.{DIGIT}+\.({DIGIT}|\.)*
ILL_FORMED_NUMBER ({DIGIT}+\.?{DIGIT}*|\.{DIGIT}+)[Ee][+-]?{DIGIT}*\.({DIGIT}+)?
UNFINISHED_CONST_CHAR '{LETTER}*|'(\\[nt\\afrbv0\'\"])*
MUL_CHAR_ERROR '(([ -~]{-}['\\])([ -~]{-}['\\])+)'
INVALID_PREFIX [0-9][A-Za-z0-9_]*
EMPTY_CHAR_ERROR ''
UNRECOGNIZED_CHARACTER .


IF "if"
ELSE "else"
BREAK "break"
CASE "case"
CONTINUE "continue"
DO "do"
WHILE "while"
FOR "for"
VOID "void"
CHAR "char"
DEFAULT "default"
RETURN "return"
SWITCH "switch"
DOUBLE "double"
FLOAT "float"
INT "int"
PRINTLN "println"

%%


{IF} { 
	yylval.symInfo = new SymbolInfo(yytext,"KEYWORD",true);
	yylval.symInfo->startline = line_count;
	yylval.symInfo->endline = line_count;

	return IF; 
	}

{ELSE} { 
	yylval.symInfo = new SymbolInfo(yytext,"KEYWORD",true);
	yylval.symInfo->startline = line_count;
	yylval.symInfo->endline = line_count;
	return ELSE;
	 }

{BREAK} { 
	yylval.symInfo = new SymbolInfo(yytext,"KEYWORD",true);
	yylval.symInfo->startline = line_count;
	yylval.symInfo->endline = line_count;
	return BREAK; 
	}

{CASE} { 
	yylval.symInfo = new SymbolInfo(yytext,"KEYWORD",true);
	yylval.symInfo->startline = line_count;
	yylval.symInfo->endline = line_count;
	return CASE; 
	}

{CONTINUE} {
	yylval.symInfo = new SymbolInfo(yytext,"KEYWORD",true);
	yylval.symInfo->startline = line_count;
	yylval.symInfo->endline = line_count;
	 return CONTINUE; 
	 }
{DO} { 
	yylval.symInfo = new SymbolInfo(yytext,"KEYWORD",true);
	yylval.symInfo->startline = line_count;
	yylval.symInfo->endline = line_count;
	return DO; 
	}

{WHILE} { 
	return WHILE; 
	}

{FOR} { 
	yylval.symInfo = new SymbolInfo(yytext,"KEYWORD",true);
	yylval.symInfo->startline = line_count;
	yylval.symInfo->endline = line_count;
	return FOR; 
	}
{DEFAULT} { 
	yylval.symInfo = new SymbolInfo(yytext,"KEYWORD",true);
	yylval.symInfo->startline = line_count;
	yylval.symInfo->endline = line_count;
	return DEFAULT; 
	}
	
{RETURN} { 
    logout<<"Line# "<<line_count<<": Token <RETURN> Lexeme "<<yytext<<
	" found"<<endl;
	yylval.symInfo = new SymbolInfo(yytext,"RETURN",true);
	yylval.symInfo->startline = line_count;
	yylval.symInfo->endline = line_count;
	return RETURN; 
	}

{SWITCH} { 
	yylval.symInfo = new SymbolInfo(yytext,"KEYWORD",true);
	yylval.symInfo->startline = line_count;
	yylval.symInfo->endline = line_count;
	return SWITCH;
	}



{CHAR} { 
	yylval.symInfo = new SymbolInfo(yytext,"KEYWORD",true);
	yylval.symInfo->startline = line_count;
	yylval.symInfo->endline = line_count;
	return CHAR; 
	}
{DOUBLE} { 

	yylval.symInfo = new SymbolInfo(yytext,"KEYWORD",true);
	yylval.symInfo->startline = line_count;
	yylval.symInfo->endline = line_count;
	return DOUBLE;
	 }
{PRINTLN} { 
	logout<<"Line# "<<line_count<<": Token <PRINTLN> Lexeme "<<yytext<<
	" found"<<endl;
	yylval.symInfo = new SymbolInfo(yytext,"KEYWORD",true);
	yylval.symInfo->startline = line_count;
	yylval.symInfo->endline = line_count;
	return PRINTLN;
	 }


"int" {
	logout<<"Line# "<<line_count<<": Token <INT> Lexeme "<<yytext<<
	" found"<<endl;
    yylval.symInfo = new SymbolInfo(yytext,"INT","INT");
	yylval.symInfo->startline = line_count;
	yylval.symInfo->endline = line_count;
	return INT;
}

"float" {
	logout<<"Line# "<<line_count<<": Token <FLOAT> Lexeme "<<yytext<<
	" found"<<endl;
	yylval.symInfo = new SymbolInfo(yytext,"FLOAT","FLOAT");	
	yylval.symInfo->startline = line_count;
	yylval.symInfo->endline = line_count;
	return FLOAT;
}

"void" {
    logout<<"Line# "<<line_count<<": Token <VOID> Lexeme"<<yytext<<
	" found"<<endl;
	yylval.symInfo = new SymbolInfo(yytext,"VOID","VOID");
	yylval.symInfo->startline = line_count;
	yylval.symInfo->endline = line_count;
	return VOID;
}

{WHITESPACE} {}
{NEWLINE} {line_count++;}
		

"+"		|

"-"		{
			yylval.symInfo =  new SymbolInfo(yytext, "ADDOP",true);
			yylval.symInfo->startline = line_count;
			yylval.symInfo->endline = line_count;
	        return ADDOP;
			//insert in symbol table and print symbol table content(only non empty buckets)
			// There is a '|' in "+"'s rule, this means match execute the action for following rule
			//bool success = st.Insert(string (yytext),)
		}
		
{DIGIT}+ 	{
	           logout<<"Line# "<<line_count<<": Token <CONST_INT> Lexeme "<<yytext<<
	" found"<<endl;
				yylval.symInfo = new SymbolInfo(yytext,"CONST_INT","ID");
				yylval.symInfo->startline = line_count;
	            yylval.symInfo->endline = line_count;
	            return CONST_INT;
				//insert in symbol table and print symbol table content(only non empty buckets)
				//SymbolInfo *si=new SymbolInfo(string(yytext),"CONST_INT");
				
			}

{DIGIT}+(\.{DIGIT}+)?([Ee][+-]?{DIGIT}+)?  {
	            yylval.symInfo =  new SymbolInfo(yytext,"CONST_FLOAT",true);
				yylval.symInfo->startline = line_count;
	            yylval.symInfo->endline = line_count;
	            return CONST_FLOAT;
}

{CHARACTER}      {	
				logout<<"Line# "<<line_count<<": Token <CONST_CHAR> Lexeme "<<yytext<<
				" found"<<endl;
				yylval.symInfo->startline = line_count;
	            yylval.symInfo->endline = line_count;
}
[_A-Za-z][A-Za-z0-9_]*  {
                logout<<"Line# "<<line_count<<": Token <ID> Lexeme "<<yytext<<
				" found"<<endl;
				yylval.symInfo = new SymbolInfo(yytext,"ID",true);
				yylval.symInfo->startline = line_count;
				yylval.symInfo->endline = line_count;
	            return ID;
				//fprintf(logout,"%d",(int)success);
				
}	


{MULOP} {
	       	logout<<"Line# "<<line_count<<": Token <MULOP> Lexeme "<<yytext<<
			" found"<<endl;
	        yylval.symInfo =  new SymbolInfo(yytext, "MULOP",true);
			yylval.symInfo->startline = line_count;
	        yylval.symInfo->endline = line_count;
	        return MULOP;
}
{INCOP} {
	       logout<<"Line# "<<line_count<<": Token <INCOP> Lexeme "<<yytext<<
		   " found"<<endl;
           yylval.symInfo =  new SymbolInfo(yytext, "INCOP",true);
		   yylval.symInfo->startline = line_count;
	       yylval.symInfo->endline = line_count;
	       return INCOP;
}
{DECOP} {
	        logout<<"Line# "<<line_count<<": Token <DECOP> Lexeme "<<yytext<<
		    " found"<<endl;
            yylval.symInfo =  new SymbolInfo(yytext, "DECOP",true);
			yylval.symInfo->startline = line_count;
	        yylval.symInfo->endline = line_count;
	        return DECOP;
}

{RELOP} {
	        logout<<"Line# "<<line_count<<": Token <RELOP> Lexeme "<<yytext<<
			" found"<<endl;
            yylval.symInfo =  new SymbolInfo(yytext, "RELOP",true);
			yylval.symInfo->startline = line_count;
	        yylval.symInfo->endline = line_count;
	        return RELOP; 
}
{BITOP} {
	        logout<<"Line# "<<line_count<<": Token <BITOP> Lexeme "<<yytext<<
			" found"<<endl;
            yylval.symInfo=  new SymbolInfo(yytext, "BITOP",true);
			yylval.symInfo->startline = line_count;
	        yylval.symInfo->endline = line_count;
	        return BITOP; 
}
{LOGICOP} {
	        logout<<"Line# "<<line_count<<": Token <LOGICOP> Lexeme "<<yytext<<
			" found"<<endl;
            yylval.symInfo =  new SymbolInfo(yytext, "LOGICOP",true);
			yylval.symInfo->startline = line_count;
	        yylval.symInfo->endline = line_count;
	        return LOGICOP;
}
"=" {
	         logout<<"Line# "<<line_count<<": Token <ASSIGNOP> Lexeme "<<yytext<<
			" found"<<endl;
	        yylval.symInfo =  new SymbolInfo(yytext, "ASSIGNOP",true);
			yylval.symInfo->startline = line_count;
	        yylval.symInfo->endline = line_count;
	        return ASSIGNOP;
}
"!"  {
	 		logout<<"Line# "<<line_count<<": Token <NOT> Lexeme "<<yytext<<
			" found"<<endl;
			yylval.symInfo =  new SymbolInfo(yytext, "NOT",true);
			yylval.symInfo->startline = line_count;
	        yylval.symInfo->endline = line_count;
			return NOT;
}

"("  {
	 		logout<<"Line# "<<line_count<<": Token <LPAREN> Lexeme "<<yytext<<
			" found"<<endl;
			yylval.symInfo =  new SymbolInfo(yytext, "LPAREN",true);
			yylval.symInfo->startline = line_count;
	        yylval.symInfo->endline = line_count;
			return LPAREN;
}

")"  {
			logout<<"Line# "<<line_count<<": Token <RPAREN> Lexeme "<<yytext<<
			" found"<<endl;
			yylval.symInfo =  new SymbolInfo(yytext, "RPAREN",true);
			yylval.symInfo->startline = line_count;
	        yylval.symInfo->endline = line_count;
			return RPAREN;
}

"{"  {
	 		logout<<"Line# "<<line_count<<": Token <LCURL> Lexeme "<<yytext<<
			" found"<<endl;
			yylval.symInfo =  new SymbolInfo(yytext, "LCURL",true);
			yylval.symInfo->startline = line_count;
	        yylval.symInfo->endline = line_count;
			return LCURL;
   
}

"}"  {
	 		logout<<"Line# "<<line_count<<": Token <RCURL> Lexeme "<<yytext<<
			" found"<<endl;
			yylval.symInfo =  new SymbolInfo(yytext, "RCURL",true);
			yylval.symInfo->startline = line_count;
	        yylval.symInfo->endline = line_count;
			return RCURL;
   
}

"["  {
	 		logout<<"Line# "<<line_count<<": Token <LSQUARE> Lexeme "<<yytext<<
			" found"<<endl;
			yylval.symInfo =  new SymbolInfo(yytext, "LSQUARE",true);
			yylval.symInfo->startline = line_count;
	        yylval.symInfo->endline = line_count;
			return LSQUARE;
}

"]"  {
			 logout<<"Line# "<<line_count<<": Token <RSQUARE> Lexeme "<<yytext<<
			" found"<<endl;
			yylval.symInfo =  new SymbolInfo(yytext, "RSQUARE",true);
			yylval.symInfo->startline = line_count;
	        yylval.symInfo->endline = line_count;
			return RSQUARE;
}

","  {
	 		logout<<"Line# "<<line_count<<": Token <COMMA> Lexeme "<<yytext<<
			" found"<<endl;
			yylval.symInfo =  new SymbolInfo(yytext, "COMMA",true);
			yylval.symInfo->startline = line_count;
	        yylval.symInfo->endline = line_count;
			return COMMA;
    
}

";"  {
			 logout<<"Line# "<<line_count<<": Token <SEMICOLON> Lexeme "<<yytext<<
			" found"<<endl;
			yylval.symInfo=  new SymbolInfo(yytext, "SEMICOLON",true);
			yylval.symInfo->startline = line_count;
			yylval.symInfo->endline = line_count;
			return SEMICOLON;
}

{REDUNDANT_DECIMAL} {
            error_count++;
			logout<<"Error at line# "<<line_count<<": TOO_MANY_DECIMAL_POINTS"<<yytext<<
	        "found"<<endl;

}

{ILL_FORMED_NUMBER} {
                    error_count++;
				logout<<"Error at line# "<<line_count<<": TOO_MANY_DECIMAL_POINTS"<<yytext<<
	"found"<<endl;

}
{UNFINISHED_CONST_CHAR} {
                    error_count++;
					logout<<"Error at line# "<<line_count<<": UNFINISHED_CONST_CHAR"<<yytext<<
	"found"<<endl;
				
}
{MUL_CHAR_ERROR} {
                    error_count++;
					logout<<"Error at line# "<<line_count<<": MULTICHAR_CONST_CHAR"<<yytext<<
	"found"<<endl;
					

}
{INVALID_PREFIX} {
                    error_count++;
					logout<<"Error at line# "<<line_count<<": INVALID_ID_SUFFIX_NUM_PREFIX"<<yytext<<
	"found"<<endl;
					

}
{EMPTY_CHAR_ERROR} {
                    error_count++;
					logout<<"Error at line# "<<line_count<<" EMPTY_CONST_CHAR"<<yytext<<
	"found"<<endl;
					

}

\/\/ {
	memset(str,0,sizeof(str));
	scomment+="//";
	line=0;
	BEGIN SINGLE_COMMENT_STATE;

}
<SINGLE_COMMENT_STATE>[\r]?\n {
	line++;
	
	logout<<"Line# "<<line_count<<": Token <SINGLE LINE COMMENT> Lexeme "<<yytext<<" found"<<endl;
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
	 logout<<"Line# "<<line_count<<": Token <MULTI LINE COMMENT> Lexeme "<<yytext<<" found"<<endl;
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
	 logout<<"Error at line# "<<line_count<<": UNFINISHED_COMMENT "<<mcomment<<" found"<<endl;
    
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
		      
              logout<<"Line# "<<line_count<<": Token <SINGLE LINE STRING> Lexeme "<<slog<<" found"<<endl;
	  
	}
	
	else
	{
		logout<<"Line# "<<line_count<<": Token <SINGLE LINE STRING> Lexeme "<<slog<<" found"<<endl; 

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
	                logout<<"Error at line# "<<line_count<<": UNFINISHED_STRING "<<slog<<" found"<<endl;
				   sToken="";
				   slog = "";
	               line_count++;
				   error_count++;
				   BEGIN INITIAL;


} 
<STRING_STATE><<EOF>> {
	               logout<<"Error at line# "<<line_count<<": UNFINISHED_STRING "<<slog<<" found"<<endl;
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
					logout<<"Error at line# "<<line_count<<": UNRECOGNIZED_CHAR "<<slog<<" found"<<endl;

}




%%



