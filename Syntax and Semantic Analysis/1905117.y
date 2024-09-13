%{
#include<bits/stdc++.h>
#include "1905117.h"


using namespace std;


extern FILE *yyin;
ofstream logout;
ofstream errorout;
ofstream parseTree;
extern int line_count;
extern int error_count;
FILE* fp;

SymbolTable *table =new SymbolTable(20);
SymbolInfo *sInfo = new SymbolInfo();


void yyerror(char *s)
{
	//write your code
}

bool isVoid(SymbolInfo* typeSpecifier){
	if( typeSpecifier->gettypeSpec() != "VOID" ){
		return false;
	}
	return true;
}


void printParseTree(int depth,SymbolInfo *symbolInfo)
{
	for(int i=0;i<depth;i++)
	{
      parseTree<<" ";
	}
	if(symbolInfo->getType() != "NON_TERMINAL") 
		parseTree<<symbolInfo->getType()<<" : "<<symbolInfo->getName();
	else
		parseTree<<symbolInfo->getName()<<" : ";
	for(int i=0;i<symbolInfo->children.size();i++)
	{
		if(symbolInfo->children[i]->getType() != "NON_TERMINAL")
			parseTree<<symbolInfo->children[i]->getType()<<" ";
		else
			parseTree<<symbolInfo->children[i]->getName()<<" ";
	}
	if(symbolInfo->isLeaf == true)
	{
		parseTree<<"\t<Line: "<<symbolInfo->startline<<">";
	}
	else

	parseTree<<"\t<Line: "<<symbolInfo->startline<<"-"<<symbolInfo->endline<<">";
	parseTree<<endl;
	for(int i=0;i<symbolInfo->children.size();i++)
	{
		printParseTree(depth+1,symbolInfo->children[i]);

	}
	
}
void error_check(SymbolInfo *sym)
{
	
}


int yyparse(void);
int yylex(void);

%}

%union{
	SymbolInfo *symInfo;
	
}

%token<symInfo> IF ELSE SWITCH CASE DEFAULT CONTINUE PRINTLN INCOP DECOP ASSIGNOP NOT LPAREN RPAREN LCURL RCURL LSQUARE RSQUARE COMMA SEMICOLON INT FLOAT VOID CONST_INT CONST_FLOAT ID ADDOP MULOP RELOP LOGICOP CONST_CHAR BITOP FOR WHILE DO BREAK CHAR DOUBLE RETURN 
%type<symInfo> start program unit func_declaration func_definition parameter_list compound_statement var_declaration type_specifier declaration_list statements statement expression_statement variable expression logic_expression rel_expression simple_expression term unary_expression factor argument_list arguments


%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE


%%

start : program
	{
		//write your code in this block in all the similar blocks below
	$$ = new SymbolInfo("start","NON_TERMINAL");
	logout<<"start : program"<<"\n";
	$$->children.push_back($1);
    $$->startline = $$->children[0]->startline;
	$$->endline = $$->children[0]->endline;	
	printParseTree(0,$$);
	logout<<"Total Lines : "<<line_count<<endl;
    logout<<"Total Error : "<<error_count<<endl;


	}
	;

program: program unit {
	$$ = new SymbolInfo("program", "NON_TERMINAL");
	logout<<"program : program unit"<<"\n";
	$$->children.push_back($1);
	$$->children.push_back($2);
	$$->startline = $$->children[0]->startline;
	$$->endline = $$->children[1]->endline;

	}
	| unit {
    $$ = new SymbolInfo("program", "NON_TERMINAL");
	logout<<"program : unit"<<"\n";
	$$->children.push_back($1);
	$$->startline = $$->children[0]->startline;
	$$->endline = $$->children[0]->endline;
	}
	;
	
unit: var_declaration {
	$$ = new SymbolInfo("unit", "NON_TERMINAL");
	logout<< "unit : var_declaration"<<"\n";
	$$->children.push_back($1);
	$$->startline = $$->children[0]->startline;
	$$->endline = $$->children[0]->endline;
	}

    | func_declaration {
    $$ = new SymbolInfo("unit", "NON_TERMINAL");
	logout<< "unit : func_declaration"<<"\n";
	$$->children.push_back($1);
	$$->startline = $$->children[0]->startline;
	$$->endline = $$->children[0]->endline;

	 }
    | func_definition {
    $$ = new SymbolInfo("unit", "NON_TERMINAL");
	logout<< "unit : func_definition"<<"\n";
	$$->children.push_back($1);
	$$->startline = $$->children[0]->startline;
	$$->endline = $$->children[0]->endline;
	 }
     ;
     
func_declaration: type_specifier ID LPAREN parameter_list RPAREN SEMICOLON {
	$$ = new SymbolInfo("func_declaration", "NON_TERMINAL");
	$$->children.push_back($1);
	$$->children.push_back($2);
	$$->children.push_back($3);
	$$->children.push_back($4);
	$$->children.push_back($5);
	$$->children.push_back($6);
	logout<< "func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON"<<endl;
	$$->startline = $$->children[0]->startline;
	$$->endline = $$->children[5]->endline;	
	$2->funcDec =true;
	$2->setParamList($4->getParamList());
	$2->settypeSpec($1->gettypeSpec());
	bool success = table->InsertSymbol($2->getName(),$2->gettypeSpec());
	if(success == false)
	{
	error_count++;
	errorout<<"Line# "<<line_count<<": "<<"multiple declaration of function "<<$2->getName()<<endl;

	}
	
	
	}

	| type_specifier ID LPAREN RPAREN SEMICOLON {
		$$ = new SymbolInfo("func_declaration", "NON_TERMINAL");
		$$->children.push_back($1);
		$$->children.push_back($2);
		$$->children.push_back($3);
		$$->children.push_back($4);
		$$->children.push_back($5);
		logout<< "func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON"<<endl;
		$$->startline = $$->children[0]->startline;
		$$->endline = $$->children[4]->endline;	
		$2->funcDec = true;
		$2->setParamList($4->getParamList());
		$2->settypeSpec($1->gettypeSpec());
		bool success = table->InsertSymbol($2->getName(),$2->gettypeSpec());
		if(success == false)
		{
		errorout<<"Line# "<<line_count<<": "<<" multiple declaration of function "<<$2->getName()<<endl;
        error_count++;
		}
	}
	;
		 
func_definition: type_specifier ID LPAREN parameter_list RPAREN {
	    bool success = table->InsertSymbol($2->getName(),$2->getType());
	    $2->settypeSpec($1->gettypeSpec());
		$2->setParamList(sInfo->getParamList());
		
		if(success == false)
		{
           SymbolInfo *temp = table->LookUP($2->getName());
		   if(temp->funcDec == false)
		   {
			  error_count++;
		      errorout<<"Line# "<<line_count<<": "<<" Conflicting types for "<<$2->getName()<<endl;
			
		   }
		   else
		   {
			if(temp->gettypeSpec() != $2->gettypeSpec())
			{
				error_count++;
		        errorout<<"Line# "<<line_count<<": "<<" Conflicting types for "<<$2->getName()<<endl;

			}
			if(temp->getParamList().size() != $2->getParamList().size() )
			{
				error_count++;
		        errorout<<"Line# "<<line_count<<": "<<" Conflicting types for "<<$2->getName()<<endl;

			}
			else
			{
				for(int i=0;i<temp->getParamList().size();i++){

					if( $2->paramList[i]->gettypeSpec()!= temp->paramList[i]->gettypeSpec()){
						errorout<<"Type mismatch for argument "<<i+1<<" of"<<$2->getName()<<endl;
						error_count++;

					}
			}
		   }
		}
		
		}
		else
		{
            $2->funcDef = true;
			$2->settypeSpec($1->gettypeSpec());
			$2->paramList = $4->paramList ;

		}
		
} compound_statement {
		$$ = new SymbolInfo("func_definition", "NON_TERMINAL");
		$$->children.push_back($1);
		$$->children.push_back($2);
		$$->children.push_back($3);
		$$->children.push_back($4);
		$$->children.push_back($5);
		$$->children.push_back($7);
		logout<< "func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement"<<endl;
		$$->startline = $$->children[0]->startline;
		$$->endline = $$->children[5]->endline;	
		// bool success = table->InsertSymbol($2->getName(),$2->gettypeSpec());
		// if(success == false)
		// {
		// 	if($2->funcDec == true)
		// 	{
				
		// 	}
		// }
	}

	| type_specifier ID LPAREN RPAREN compound_statement {
		$$ = new SymbolInfo("func_definition", "NON_TERMINAL");
		$$->children.push_back($1);
		$$->children.push_back($2);
		$$->children.push_back($3);
		$$->children.push_back($4);
		$$->children.push_back($5);
		logout<< "func_definition : type_specifier ID LPAREN RPAREN compound_statement"<<endl;
		$$->startline = $$->children[0]->startline;
		$$->endline = $$->children[4]->endline;
		
	}
	;				


parameter_list: parameter_list COMMA type_specifier ID {
        $$ = new SymbolInfo("parameter_list", "NON_TERMINAL");
		$$->children.push_back($1);
		$$->children.push_back($2);
		$$->children.push_back($3);
		$$->children.push_back($4);
		logout<< "parameter_list : parameter_list COMMA type_specifier ID"<<endl;
		$$->startline = $$->children[0]->startline;
	    $$->endline = $$->children[3]->endline;
		$$->setParamList($1->getParamList());
		$4->settypeSpec($3->gettypeSpec());
		$$->paramList.push_back($4);
		sInfo->setParamList($$->getParamList());
		if( $3->gettypeSpec() == "VOID" ){
		error_count++;
		errorout<<"Line# "<<line_count<<": "<<"Variable type cannot be void"<<endl;
			
	}

	}
		| parameter_list COMMA type_specifier {
        $$ = new SymbolInfo("parameter_list", "NON_TERMINAL");
		$$->children.push_back($1);
		$$->children.push_back($2);
		$$->children.push_back($3);
		logout<< "parameter_list : parameter_list COMMA type_specifier"<<endl;
		$$->startline = $$->children[0]->startline;
	    $$->endline = $$->children[2]->endline;
        $$->setParamList($1->getParamList());
		sInfo->setParamList($$->getParamList());
		if( $3->gettypeSpec() == "VOID" ){
		error_count++;
		errorout<<"Line# "<<line_count<<": "<<"Variable type cannot be void"<<endl;	
		}	
	}
 		| type_specifier ID {
        $$ = new SymbolInfo("parameter_list", "NON_TERMINAL");
		$$->children.push_back($1);
		$$->children.push_back($2);
		logout<< "parameter_list : type_specifier ID"<<endl;
		$$->startline = $$->children[0]->startline;
	    $$->endline = $$->children[1]->endline;
		$2->settypeSpec($1->gettypeSpec());
		$$->paramList.push_back($2);	
		if( $1->gettypeSpec() == "VOID" ){
		error_count++;
		errorout<<"Line# "<<line_count<<": "<<"Variable type cannot be void"<<endl;
		sInfo->setParamList($$->getParamList());
		}
		}
		| type_specifier {
        $$ = new SymbolInfo("parameter_list", "NON_TERMINAL");
		$$->children.push_back($1);
		logout<< "parameter_list : type_specifier"<<endl;
		$$->startline = $$->children[0]->startline;
	    $$->endline = $$->children[0]->endline;
		if( $1->gettypeSpec() == "VOID" ){
		errorout<<"Line# "<<line_count<<": "<<"Variable type cannot be void"<<endl;
		sInfo->setParamList($$->getParamList());

		}
		}
 		;

 		
compound_statement: LCURL {table->EnterScope();} statements RCURL {
        $$ = new SymbolInfo("compound_statement", "NON_TERMINAL");
		$$->children.push_back($1);
		$$->children.push_back($3);
		$$->children.push_back($4);
		logout<< "compound_statement : LCURL statements RCURL"<<endl;
		$$->startline = $$->children[0]->startline;
	    $$->endline = $$->children[2]->endline;
		table->printAllScopeTable(logout);
		table->exitScope();

	}
 		| LCURL {table->EnterScope();} RCURL {
        $$ = new SymbolInfo("compound_statement", "NON_TERMINAL");
		$$->children.push_back($1);
		$$->children.push_back($3);
		logout<< "compound_statement : LCURL RCURL"<<endl;
		$$->startline = $$->children[0]->startline;
	    $$->endline = $$->children[1]->endline;
		table->printAllScopeTable(logout);
		table->exitScope();

		}
 		;
 		    
var_declaration: type_specifier declaration_list SEMICOLON {
		$$ = new SymbolInfo("var_declaration", "NON_TERMINAL");
		$$->children.push_back($1);
		$$->children.push_back($2);
		$$->children.push_back($3);
		logout<< "var_declaration : type_specifier declaration_list SEMICOLON"<<"\n";
		$$->startline = $$->children[0]->startline;
		$$->endline = $$->children[2]->endline;
        if($1->gettypeSpec() =="VOID")
		{
			error_count++;
            errorout<<"Line# "<<line_count<<": "<<"Variable type cannot be void"<<endl;

		}
		else
		{
			for(auto symbolInfo:$2->getDecList()){
		     	bool success = table->InsertSymbol(symbolInfo->getName(),$1->gettypeSpec());
				if(success == false ){
			        error_count++;
					errorout<<"Line# "<<line_count<<": "<<" Conflicting types for "<<symbolInfo->getName()<<endl;
				}
				symbolInfo->settypeSpec($1->gettypeSpec());

			}
		}

	}
 		 ;
 		 
type_specifier: INT {
           $$ = new SymbolInfo("type_specifier", "NON_TERMINAL");
		   $$->children.push_back($1);
		   logout<< "type_specifier	: INT"<<"\n"; 
		   $$->startline = $$->children[0]->startline;
		   $$->endline = $$->children[0]->endline;
           $$->settypeSpec($1->gettypeSpec());

	}
 		| FLOAT {
            $$ = new SymbolInfo("type_specifier", "NON_TERMINAL");
			$$->children.push_back($1);
			logout<< "type_specifier	: FLOAT"<<"\n"; 
			$$->startline = $$->children[0]->startline;
	        $$->endline = $$->children[0]->endline;
            $$->settypeSpec($1->gettypeSpec());

		}
 		| VOID {
			$$ = new SymbolInfo("type_specifier", "NON_TERMINAL");
			$$->children.push_back($1);
			logout<< "type_specifier	: VOID"<<"\n";
			$$->startline = $$->children[0]->startline;
			$$->endline = $$->children[0]->endline; 
			$$->settypeSpec($1->gettypeSpec());

		}
 		;
 		
declaration_list: declaration_list COMMA ID {
	
           $$ = new SymbolInfo("declaration_list", "NON_TERMINAL");
		   $$->children.push_back($1);
		   $$->children.push_back($2);
		   $$->children.push_back($3);
		   logout<< "declaration_list : declaration_list COMMA ID "<<"\n"; 
		   $$->startline = $$->children[0]->startline;
		   $$->endline = $$->children[2]->endline;
		   $$->setDecList($1->getDecList());
		   $$->declarationList.push_back($3);

	}
 		  | declaration_list COMMA ID LSQUARE CONST_INT RSQUARE {
           $$ = new SymbolInfo("declaration_list", "NON_TERMINAL");
		   $$->children.push_back($1);
		   $$->children.push_back($2);
		   $$->children.push_back($3);
		   $$->children.push_back($4);
		   $$->children.push_back($5);
		   $$->children.push_back($6);
		   logout<< "declaration_list : declaration_list COMMA ID LSQUARE CONST_INT RSQUARE "<<"\n"; 
		   $$->startline = $$->children[0]->startline;
		   $$->endline = $$->children[5]->endline;
		   $$->declarationList.push_back($3);


		  }
 		  | ID {
           $$ = new SymbolInfo("declaration_list", "NON_TERMINAL");
		   $$->children.push_back($1);
		   logout<< "declaration_list : ID"<<"\n"; 
		   $$->startline = $$->children[0]->startline;
	       $$->endline = $$->children[0]->endline;
		   $$->declarationList.push_back($1);

		  }
 		  | ID LSQUARE CONST_INT RSQUARE {
			$$ = new SymbolInfo("declaration_list", "NON_TERMINAL");
			$$->children.push_back($1);
			$$->children.push_back($2);
			$$->children.push_back($3);
			$$->children.push_back($4);
			logout<< "declaration_list : ID LSQUARE CONST_INT RSQUARE"<<"\n"; 
			$$->startline = $$->children[0]->startline;
		    $$->endline = $$->children[3]->endline;
			$$->declarationList.push_back($1);
			$1->array=true;
		  }
 		  ;
 		  
statements: statement {
            $$ = new SymbolInfo("statements", "NON_TERMINAL");
		    $$->children.push_back($1);
			logout<< "statements: statement"<<"\n";
			$$->startline = $$->children[0]->startline;
		    $$->endline = $$->children[0]->endline;


	}
	   | statements statement {
            $$ = new SymbolInfo("statements", "NON_TERMINAL");
		    $$->children.push_back($1);
		    $$->children.push_back($2);
			logout<< "statements: statements statement"<<"\n";
			$$->startline = $$->children[0]->startline;
		    $$->endline = $$->children[1]->endline;
	   }
	   ;
	   
statement: var_declaration {
           $$ = new SymbolInfo("statement", "NON_TERMINAL");
		   $$->children.push_back($1);
		   logout<< "statement: var_declaration"<<"\n";
		   $$->startline = $$->children[0]->startline;
		   $$->endline = $$->children[0]->endline;
	  }
	  | expression_statement{
		 $$ = new SymbolInfo("statement", "NON_TERMINAL"); 
		 $$->children.push_back($1);
		 logout<< "statement: expression_statement"<<"\n";
		 $$->startline = $$->children[0]->startline;
		 $$->endline = $$->children[0]->endline;
	  }
	  | compound_statement {
		 $$ = new SymbolInfo("statement", "NON_TERMINAL");
		 $$->children.push_back($1);
		 logout<< "statement: compound_statement"<<"\n";
		 $$->startline = $$->children[0]->startline;
		 $$->endline = $$->children[0]->endline;

	  }
	  | FOR LPAREN expression_statement expression_statement expression RPAREN statement{
		 $$ = new SymbolInfo("statement", "NON_TERMINAL");
		 $$->children.push_back($1);
		 $$->children.push_back($2);
		 $$->children.push_back($3);
		 $$->children.push_back($4);
		 $$->children.push_back($5);
		 $$->children.push_back($6);
		 $$->children.push_back($7);
		 logout<< "statement: FOR LPAREN expression_statement expression_statement expression RPAREN statement"<<"\n";
         $$->startline = $$->children[0]->startline;
		 $$->endline = $$->children[6]->endline;
	  }
	  | IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE {
		 $$ = new SymbolInfo("statement", "NON_TERMINAL");
		 $$->children.push_back($1);
		 $$->children.push_back($2);
		 $$->children.push_back($3);
		 $$->children.push_back($4);
		 $$->children.push_back($5); 
		 logout<< "statement: FOR LPAREN expression_statement expression_statement expression RPAREN statement"<<"\n";
         $$->startline = $$->children[0]->startline;
		 $$->endline = $$->children[4]->endline;

	  }
	  | IF LPAREN expression RPAREN statement ELSE statement{
		 $$ = new SymbolInfo("statement", "NON_TERMINAL");
		 $$->children.push_back($1);
		 $$->children.push_back($2);
		 $$->children.push_back($3);
		 $$->children.push_back($4);
		 $$->children.push_back($5);
		 $$->children.push_back($6);
		 $$->children.push_back($7);
		 logout<< "statement: IF LPAREN expression RPAREN statement ELSE statement"<<"\n";
         $$->startline = $$->children[0]->startline;
		 $$->endline = $$->children[6]->endline;

	  }
	  | WHILE LPAREN expression RPAREN statement {
		 $$ = new SymbolInfo("statement", "NON_TERMINAL");
		 $$->children.push_back($1);
		 $$->children.push_back($2);
		 $$->children.push_back($3);
		 $$->children.push_back($4);
		 $$->children.push_back($5);
		 logout<< "statement: WHILE LPAREN expression RPAREN statement"<<"\n";
         $$->startline = $$->children[0]->startline;
		 $$->endline = $$->children[4]->endline;
	  }
	  | PRINTLN LPAREN ID RPAREN SEMICOLON {
		 $$ = new SymbolInfo("statement", "NON_TERMINAL");
		 $$->children.push_back($1);
		 $$->children.push_back($2);
		 $$->children.push_back($3);
		 $$->children.push_back($4);
		 $$->children.push_back($5);
		 logout<< "statement: PRINTLN LPAREN ID RPAREN SEMICOLON"<<"\n";
         $$->startline = $$->children[0]->startline;
		 $$->endline = $$->children[4]->endline;
		 if(table->LookUP($3->getName()) == nullptr)
		 {
			error_count++;
		    errorout<<"Line# "<<line_count<<": "<<"Undeclared variable "<<$3->getName()<<endl;

		 }
	  }
	  | RETURN expression SEMICOLON {
		 $$ = new SymbolInfo("statement", "NON_TERMINAL");
		 $$->children.push_back($1);
		 $$->children.push_back($2);
		 $$->children.push_back($3);
		 logout<< "statement: RETURN expression SEMICOLON"<<"\n";
		 $$->startline = $$->children[0]->startline;
		 $$->endline = $$->children[2]->endline;

	  }
	  ;
	  
expression_statement: SEMICOLON		{
            $$ = new SymbolInfo("expression_statement", "NON_TERMINAL");
			$$->children.push_back($1);
			logout<< "expression_statement: SEMICOLON"<<"\n";
			$$->startline = $$->children[0]->startline;
		    $$->endline = $$->children[0]->endline;
		 
	}	
			| expression SEMICOLON {
            $$ = new SymbolInfo("expression_statement", "NON_TERMINAL");
            $$->children.push_back($1);
		    $$->children.push_back($2);
			logout<< "expression_statement: expression SEMICOLON"<<"\n";
            $$->startline = $$->children[0]->startline;
		    $$->endline = $$->children[1]->endline;
			$$->settypeSpec($1->gettypeSpec());
			}
			;
	  
variable: ID {
            $$ = new SymbolInfo("variable", "NON_TERMINAL");
			$$->children.push_back($1);
			logout<< "variable: ID "<<"\n";
			$$->startline = $$->children[0]->startline;
	        $$->endline = $$->children[0]->endline;
			SymbolInfo *ptr = table->LookUP($1->getName());
			if( ptr == nullptr)
			{
				error_count++;
				errorout<<"Line# "<<line_count<<": "<<"Undeclared variable "<<$1->getName()<<endl;
			}
			else if(ptr-> array == true)
			{
                error_count++;
				errorout<<"Line# "<<line_count<<": "<<"Type mismatch "<<$1->getName()<<" is an array"<<endl;
			}
			else if(ptr->funcDec == true)
			{
				error_count++;
				errorout<<"Line# "<<line_count<<": "<<"Redeclaration "<<$1->getName()<<endl;

			}
			else
			{
				$$->array = ptr->array;
				$$->settypeSpec(ptr->gettypeSpec());
			}
			

	}
	 | ID LSQUARE expression RSQUARE {
            $$ = new SymbolInfo("variable", "NON_TERMINAL");
            $$->children.push_back($1);
		    $$->children.push_back($2);
		    $$->children.push_back($3);
		    $$->children.push_back($4);
			logout<< "variable: ID LSQUARE expression RSQUARE"<<"\n";
			$$->startline = $$->children[0]->startline;
		    $$->endline = $$->children[3]->endline;
			SymbolInfo *ptr = table->LookUP($1->getName());
			if( ptr == nullptr)
			{
				error_count++;
				errorout<<"Line# "<<line_count<<": "<<"Undeclared variable "<<$1->getName()<<endl;
			}
			else if(ptr->array == false)
			{
				error_count++;
				errorout<<"Line# "<<line_count<<": "<<"Not an array "<<$1->getName()<<endl;

			}
			else if(ptr->funcDec == true)
			{
				error_count++;
				errorout<<"Line# "<<line_count<<": "<<"Redeclaration "<<$1->getName()<<endl;

			}
			else
			{
				$$->settypeSpec(ptr->gettypeSpec());
			}
			if($3->gettypeSpec() != "INT" )
			{
				error_count++;
				errorout<<"Line# "<<line_count<<": "<<"Array Subscript is not an integer "<<endl;
			}


	 }
	 ;
	 
 expression: logic_expression	{
            $$ = new SymbolInfo("expression", "NON_TERMINAL");
			$$->children.push_back($1);
			logout<< "expression: logic_expression"<<"\n";
			$$->startline = $$->children[0]->startline;
		    $$->endline = $$->children[0]->endline;
			$$->settypeSpec($1->gettypeSpec());

 	}
	   | variable ASSIGNOP logic_expression {
            $$ = new SymbolInfo("expression", "NON_TERMINAL");
			$$->children.push_back($1);
		    $$->children.push_back($2);
		    $$->children.push_back($3);
			logout<< "expression: variable ASSIGNOP logic_expression"<<"\n";
			$$->startline = $$->children[0]->startline;
		    $$->endline = $$->children[2]->endline;
			if($3->gettypeSpec()=="VOID")
			{
				error_count++;
				errorout<<"Line# "<<line_count<<": "<<"Void cannot be used in expression "<<endl;
			}
			else if($1->gettypeSpec() == "INT" && $3->gettypeSpec() == "FLOAT")
			{
				error_count++;
				errorout<<"Line# "<<line_count<<": "<<" Warning: possible loss of data in assignment of FLOAT to INT"<<endl;
			}


	   }	
	   ;
			
logic_expression: rel_expression 	{
            $$ = new SymbolInfo("logic_expression", "NON_TERMINAL");
			$$->children.push_back($1);
			logout<< "logic_expression: rel_expression"<<"\n";
			$$->startline = $$->children[0]->startline;
		    $$->endline = $$->children[0]->endline;
            $$->settypeSpec($1->gettypeSpec());
			$$->array = $1->array;
			


	}
		 | rel_expression LOGICOP rel_expression {
            $$ = new SymbolInfo("logic_expression", "NON_TERMINAL");
			$$->children.push_back($1);
		    $$->children.push_back($2);
		    $$->children.push_back($3);
			logout<< "logic_expression: rel_expression LOGICOP rel_expression"<<"\n";
            $$->startline = $$->children[0]->startline;
		    $$->endline = $$->children[2]->endline;
			$$->settypeSpec("INT");

		 }	
		 ;
			
rel_expression: simple_expression {
            $$ = new SymbolInfo("rel_expression", "NON_TERMINAL");
			$$->children.push_back($1);
			logout<< "rel_expression: simple_expression"<<"\n";
            $$->startline = $$->children[0]->startline;
		    $$->endline = $$->children[0]->endline;
			$$->array = $1->array;
	
	}
		| simple_expression RELOP simple_expression	{
            $$ = new SymbolInfo("rel_expression", "NON_TERMINAL");
			$$->children.push_back($1);
		    $$->children.push_back($2);
		    $$->children.push_back($3);
			logout<< "rel_expression: simple_expression RELOP simple_expression"<<"\n";
            $$->startline = $$->children[0]->startline;
		    $$->endline = $$->children[2]->endline;
            if($1->gettypeSpec() == "VOID" || $3->gettypeSpec() == "VOID")
			{
				error_count++;
				errorout<<"Line# "<<line_count<<": "<<" Void cannot be used in expression"<<endl;

			}
			else 
			$$->settypeSpec("INT");
		}
		;
				
simple_expression: term {
            $$ = new SymbolInfo("simple_expression", "NON_TERMINAL");
			$$->children.push_back($1);
			logout<< "simple_expression: term"<<"\n";
			$$->startline = $$->children[0]->startline;
		    $$->endline = $$->children[0]->endline;
			$$->settypeSpec($1->gettypeSpec());
			$$->array = $1->array;
			


	}
		  | simple_expression ADDOP term {
            $$ = new SymbolInfo("simple_expression", "NON_TERMINAL");
			$$->children.push_back($1);
		    $$->children.push_back($2);
		    $$->children.push_back($3);
			logout<< "simple_expression: simple_expression ADDOP term"<<"\n";
			$$->startline = $$->children[0]->startline;
		    $$->endline = $$->children[2]->endline;
            if($1->gettypeSpec() =="VOID" ||$3->gettypeSpec() =="VOID")
			{
				error_count++;
				errorout<<"Line# "<<line_count<<": "<<" Void cannot be used in expression"<<endl;

			}
			else if($1->gettypeSpec() =="FLOAT" ||$3->gettypeSpec() =="FLOAT")
			{
				$$->settypeSpec("FLOAT");

			}
			else
			$$->settypeSpec("INT");


		  }
		  ;
					
term:   unary_expression {
            $$ = new SymbolInfo("term", "NON_TERMINAL");
			$$->children.push_back($1);
			logout<< "term : unary_expression "<<"\n";
			$$->startline = $$->children[0]->startline;
		    $$->endline = $$->children[0]->endline;
            $$->array = $1->array;
			$$->settypeSpec($1->gettypeSpec());
			
	}
     |  term MULOP unary_expression {
		    $$ = new SymbolInfo("term", "NON_TERMINAL");
			$$->children.push_back($1);
		    $$->children.push_back($2);
		    $$->children.push_back($3);
			logout<< "term : term MULOP unary_expression"<<"\n";
			$$->startline = $$->children[0]->startline;
		    $$->endline = $$->children[2]->endline;
            if($1->gettypeSpec() =="VOID" || $3->gettypeSpec() =="VOID")
			{
				error_count++;
				errorout<<"Line# "<<line_count<<": "<<" Void cannot be used in expression"<<endl;

			}
			else if($1->gettypeSpec() =="FLOAT" || $3->gettypeSpec() =="FLOAT")
			{
				$$->settypeSpec("FLOAT");

			}
			else
			$$->settypeSpec("INT");
			if($2->getName()=="%" && $3->getName() =="0")
			{
				error_count++;
				errorout<<"Line# "<<line_count<<": "<<"Warning: division by zero i=0f=1Const=0"<<endl;

			}
			else if($2->getName()=="%" && ($1->gettypeSpec() != "INT" || $3->gettypeSpec() != "INT" ))
			{
				error_count++;
				errorout<<"Line# "<<line_count<<": "<<"Operands of modulus must be integers "<<endl;

			}

	 }
     ;

unary_expression: ADDOP unary_expression  {
		    $$ = new SymbolInfo("unary_expression", "NON_TERMINAL");
			$$->children.push_back($1);
		    $$->children.push_back($2);	
			logout<< "unary_expression : ADDOP unary_expression"<<"\n";
			$$->startline = $$->children[0]->startline;
		    $$->endline = $$->children[1]->endline;
			if($2->gettypeSpec()=="VOID")
			{
				error_count++;
				errorout<<"Line# "<<line_count<<": "<<" Void cannot be used in expression"<<endl;
				
			}
			else
			$$->settypeSpec($2->gettypeSpec());


	}
		 | NOT unary_expression {
		    $$ = new SymbolInfo("unary_expression", "NON_TERMINAL");
			$$->children.push_back($1);
		    $$->children.push_back($2);
			logout<< "unary_expression : NOT unary_expression"<<"\n";
			$$->startline = $$->children[0]->startline;
		    $$->endline = $$->children[1]->endline;
			if($2->gettypeSpec()=="VOID")
			{
				error_count++;
				errorout<<"Line# "<<line_count<<": "<<" Void cannot be used in expression"<<endl;
				
			}
			else
			$$->settypeSpec("INT");

		 }
		 | factor {
		    $$ = new SymbolInfo("unary_expression", "NON_TERMINAL");
			$$->children.push_back($1);
			logout<< "unary_expression : factor"<<"\n";
			$$->startline = $$->children[0]->startline;
		    $$->endline = $$->children[0]->endline;
			$$->settypeSpec($1->gettypeSpec());
			$$->array =$1->array;


		 }
		 ;
	
factor: variable {
			$$ = new SymbolInfo("factor", "NON_TERMINAL");
			$$->children.push_back($1);
			logout<< "factor : variable"<<"\n";
			$$->startline = $$->children[0]->startline;
			$$->endline = $$->children[0]->endline;
			$$->settypeSpec($1->gettypeSpec());
			$$->array =$1->array;

	}
	| ID LPAREN argument_list RPAREN {
			$$ = new SymbolInfo("factor", "NON_TERMINAL");
			$$->children.push_back($1);
			$$->children.push_back($2);
			$$->children.push_back($3);
			$$->children.push_back($4);
			logout<< "factor : ID LPAREN argument_list RPAREN"<<"\n";
			$$->startline = $$->children[0]->startline;
			$$->endline = $$->children[3]->endline;


			SymbolInfo *ptr = table->LookUP($1->getName());
            if( ptr == nullptr ){
			error_count++;
			errorout<<"Line# "<<line_count<<": "<<"Undeclared function "<<$1->getName()<<endl;
		    }
		    else{
			$$->settypeSpec(ptr->gettypeSpec());
			if( ptr->funcDec == false  && ptr->funcDef== false){
				error_count++;
				errorout<<"Line# "<<line_count<<": "<<$1->getName()<<" is not a function"<<endl;
			}else if( $3->paramList.size() > ptr->paramList.size()){
				error_count++;
				errorout<<"Too many arguments to function "<<$1->getName()<<endl;
			}
			else if( $3->paramList.size() < ptr->paramList.size()){
				error_count++;
				errorout<<"Too few arguments to function "<<$1->getName()<<endl;
			}
			else{
	
				for(int i=0;i<$3->paramList.size();i++){

					if( ($3->paramList[i]->array ==true)  && (ptr->paramList[i]->array == false )){
						error_count++;
						errorout<<"Type mismatch "<<$3->paramList[i]->getName()+" is an array"<<endl;
					}
					else if( ($3->paramList[i]->array ==false)  && (ptr->paramList[i]->array == true ))
					{
						error_count++;
						errorout<<"Type mismatch "<<ptr->paramList[i]->getName()+" is an array"<<endl;

					}
					if( $3->paramList[i]->gettypeSpec()!= ptr->paramList[i]->gettypeSpec()){
						error_count++;
						errorout<<"Type mismatch for argument "<<i+1<<" of"<<$1->getName()<<endl;

					}
					
				}
			}
		  }
	}

	
	| LPAREN expression RPAREN {
			$$ = new SymbolInfo("factor", "NON_TERMINAL");
			$$->children.push_back($1);
			$$->children.push_back($2);
			$$->children.push_back($3);
			logout<< "factor : LPAREN expression RPAREN"<<"\n";
			$$->startline = $$->children[0]->startline;
			$$->endline = $$->children[2]->endline;
			$$->settypeSpec($1->gettypeSpec());

	}
	| CONST_INT {
			$$ = new SymbolInfo("factor", "NON_TERMINAL");
			$$->children.push_back($1);
			logout<< "factor : CONST_INT"<<"\n";
			$$->startline = $$->children[0]->startline;
			$$->endline = $$->children[0]->endline;
			$$->settypeSpec("INT");
			
	}
	| CONST_FLOAT{
			$$ = new SymbolInfo("factor", "NON_TERMINAL");
			$$->children.push_back($1);
			logout<< "factor : CONST_FLOAT"<<"\n";
			$$->startline = $$->children[0]->startline;
			$$->endline = $$->children[0]->endline;
			$$->settypeSpec("FLOAT");

	}
	| variable INCOP{
			$$ = new SymbolInfo("factor", "NON_TERMINAL");
			$$->children.push_back($1);
			$$->children.push_back($2);
			logout<< "factor : variable INCOP"<<"\n";
			$$->startline = $$->children[0]->startline;
			$$->endline = $$->children[1]->endline;

			if( $1->gettypeSpec() == "VOID" ){
			error_count++;
			errorout<<"Void function used in expression"<<endl;
		    }
			else{
			$$->settypeSpec($1->gettypeSpec());
		}

	} 
	| variable DECOP{
			$$ = new SymbolInfo("factor", "NON_TERMINAL");
			$$->children.push_back($1);
			$$->children.push_back($2);
			logout<< "factor : variable DECOP"<<"\n";
			$$->startline = $$->children[0]->startline;
			$$->endline = $$->children[1]->endline;
			if( $1->gettypeSpec() == "VOID" ){
			errorout<<"Void function used in expression"<<endl;
		    }
			else{
			$$->settypeSpec($1->gettypeSpec());
		}
	}
	;
	
argument_list: arguments{
			$$ = new SymbolInfo("argument_list", "NON_TERMINAL");
			$$->children.push_back($1);
			logout<< "argument_list: arguments"<<"\n";
			$$->startline = $$->children[0]->startline;
			$$->endline = $$->children[0]->endline;
			$$->setParamList($1->getParamList());
	}
		|
		;
	
arguments: arguments COMMA logic_expression{
			$$ = new SymbolInfo("arguments", "NON_TERMINAL");
			$$->children.push_back($1);
			$$->children.push_back($2);
			$$->children.push_back($3);
			logout<<"arguments : arguments COMMA logic_expression"<<"\n";
			$$->startline = $$->children[0]->startline;
			$$->endline = $$->children[2]->endline;
			$$->setParamList($1->getParamList());
			$$->paramList.push_back($3);


	}

	    | logic_expression {
			$$ = new SymbolInfo("arguments", "NON_TERMINAL");
			$$->children.push_back($1);
			logout<<"arguments : logic_expression"<<"\n";
			$$->startline = $$->children[0]->startline;
			$$->endline = $$->children[0]->endline;
			$$->paramList.push_back($1);
			
		  }
	      ;
 

%%
int main(int argc,char *argv[])
{
	table= new SymbolTable(11);
	

	if((fp=fopen(argv[1],"r"))==NULL)
	{
		printf("Cannot Open Input File.\n");
		exit(1);
	}

	logout.open("log.txt");
	errorout.open("error.txt");
	parseTree.open("tree.txt");
	
	yyin=fp;
	yyparse();
	
	logout.close();
	errorout.close();
	parseTree.close();
	
	return 0;
}

