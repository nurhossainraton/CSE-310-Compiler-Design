%{
#include<bits/stdc++.h>
#include "1905117.h"
#include <vector>
using namespace std;

using namespace std;


extern FILE *yyin;
ofstream logout;
ofstream errorout;
ofstream parseTree;
ofstream codeoutput,optoutput,test; 
extern int line_count;
extern int error_count;
FILE* fp;

SymbolTable *table =new SymbolTable(20);
SymbolTable *symtable2 =new SymbolTable(20);
SymbolInfo *sInfo = new SymbolInfo();
vector<string> globalVariables;
vector<string> localVariables;
bool isGlobal,isLocal;
int stackoffset =0;
int level =1,x=1,a,b,c,d,y=0;
map<string,string> labelMap;

void yyerror(char *s)
{
	//write your code
}
void expression_statementFunc(SymbolInfo *s);
void compound_statementFunc(SymbolInfo *s);
void variableFunc(SymbolInfo *symblInfo);
void expressionFunc(SymbolInfo *symblInfo);
void logic_expressionFunc(SymbolInfo *symblInfo);
void rel_expressionFunc(SymbolInfo *symblInfo);
void simple_expressionFunc(SymbolInfo *symblInfo);
void termFunc(SymbolInfo *symblInfo);
void unary_expression(SymbolInfo *symblInfo);
void factorFunc(SymbolInfo *symblInfo);

string newlevel()
{
	return "L"+to_string(level++);
}

string newlabel(string label)
{
	return label+"_"+to_string(level++);
}

bool isVoid(SymbolInfo* typeSpecifier){
	if( typeSpecifier->gettypeSpec() != "VOID" ){
		return false;
	}
	return true;
}

string getAdrress(SymbolInfo *s)
{
	if(s->getChildren()[0]->array)
	codeoutput<<"\tPOP BX"<<endl;

	return s->getChildren()[0]->getasmName();
}

void unaryCode(SymbolInfo *s,bool b)
{
	string operation;
    if(b)
	operation = "INC";
	else
	operation = "DEC";

	codeoutput<<"\tPUSH "<<getAdrress(s)<<endl;
	codeoutput<<"\t"<<operation<<" "<<getAdrress(s)<<endl;

}

void printParseTree(int depth,SymbolInfo *symbolInfo)
{
	for(int i=0;i<depth;i++)
	{
      parseTree<<" ";
	}
	// if(symbolInfo->getType() != "NON_TERMINAL") 
	// 	parseTree<<symbolInfo->getType()<<" : "<<symbolInfo->getName();
	// else
	// 	parseTree<<symbolInfo->getName()<<" : ";
	// for(int i=0;i<symbolInfo->children.size();i++)
	// {
	// 	if(symbolInfo->children[i]->getType() != "NON_TERMINAL")
	// 		parseTree<<symbolInfo->children[i]->getType()<<" ";
	// 	else
	// 		parseTree<<symbolInfo->children[i]->getName()<<" ";
	// }
	if(symbolInfo->isLeaf == true)
	{
		parseTree<<symbolInfo-> getType() <<" : "<<symbolInfo->getName()<<"\t";
		parseTree<<"\t<Line: "<<symbolInfo->startline<<">"<<endl;
	}
	else
    {
		parseTree<<symbolInfo-> getType() <<" : "<<symbolInfo->getName()<<"\t";
		parseTree<<"\t<Line: "<<symbolInfo->startline<<"-"<<symbolInfo->endline<<">"<<endl;

	}
	
	for(int i=0;i<symbolInfo->children.size();i++)
	{
		printParseTree(depth+1,symbolInfo->children[i]);

	}
	
}
void getVars(vector<SymbolInfo*> &v,SymbolInfo *si)
{
	//codeoutput<<"abd"<<endl;
	if(si->getChildren().size() == 3 || si->getChildren().size() ==6)
	{
		
		getVars(v,si->getChildren()[0]);
		v.push_back(si->getChildren()[2]);
		
	}
	
	else
	{
		
		v.push_back(si->getChildren()[0]);
		
		
		
	}
	
	
}

void argumentsFunc(SymbolInfo *s)
{
	if(s->getChildren().size() == 3)
	{
		argumentsFunc(s->getChildren()[0]);
		logic_expressionFunc(s->getChildren()[2]);
	}
	else
	logic_expressionFunc(s->getChildren()[0]);
}

void argument_listFunc(SymbolInfo *s)
{
	if(s->getChildren().size() == 1)
	{
		argumentsFunc(s->getChildren()[0]);
	}
}

void factorFunc(SymbolInfo *s)
{
	if(s->getChildren().size()==1)
	{

	if(s->getChildren()[0]->getType() == "CONST_INT")
	{
		//codeoutput<<"L"<<level<<":"<<endl;
		//level++;
		codeoutput<<"\tPUSH "<<s->getChildren()[0]->getName()<<endl;
		
	}

	else
	{
		variableFunc(s->getChildren()[0]);
		codeoutput<<"\tPUSH "<<getAdrress(s->getChildren()[0])<<endl;
	}
	}

	else if(s->getChildren().size()==2)
	{
          variableFunc(s->getChildren()[0]);

		  if(s->getChildren()[1]->getType() == "INCOP")
		  {
			unaryCode(s->getChildren()[0],true);
		  }
		  else
		  unaryCode(s->getChildren()[0],false);
	}

	else if(s->getChildren().size()==3)
	{
            expressionFunc(s->getChildren()[1]);
	}
	
	else if(s->getChildren().size()==4)
	{
         argument_listFunc(s->getChildren()[2]);

		 codeoutput<<"\tPUSH 0"<<endl; // BP+4
		codeoutput<<"\tCALL "<<s->getChildren()[0]->getName()<<endl;
		codeoutput<<"\tPOP AX"<<endl;
		
        codeoutput<<"\tADD SP, "<<to_string(s->getChildren()[2]->getParamList().size()*2)<<endl;
		
        if(s->getChildren()[0]->gettypeSpec() != "VOID"){
			codeoutput<<"\tPUSH AX"<<endl;
		}else{
			codeoutput<<"\tPUSH 0"<<endl;
		}
	}
	

}

void unary_expression(SymbolInfo *s)
{
	if(s->getChildren().size()==1)
	factorFunc(s->getChildren()[0]);

	else
	{
       unary_expression(s->getChildren()[1]);
	   string type = s->getChildren()[0]->getType();
	   if(type == "NOT")
	   {
		string level1,level2;
		level1 = newlevel();
		level2 = newlevel();

		codeoutput<<"\tPOP AX"<<endl;
        codeoutput<<"\tCMP AX, 0"<<endl;
        codeoutput<<"\tJE "<<level1<<endl;
        codeoutput<<"\tPUSH 0"<<endl;
        codeoutput<<"\tJMP "<<level2<<endl;
        codeoutput<<level1<<":\n\tPUSH 1"<<endl;
        codeoutput<<level2<<":"<<endl;
	   }

	   else
	   {
		  if( s->getChildren()[0]->getName() == "-")
		  {
			    codeoutput<<"\tPOP AX"<<endl;
                codeoutput<<"\tNEG AX"<<endl;
                codeoutput<<"\tPUSH AX"<<endl;
		  }

	   }
	}
}

void termFunc(SymbolInfo *s)
{
	if(s->getChildren().size()==1)
	unary_expression(s->getChildren()[0]);
	else
	{
		string operation;
		termFunc(s->getChildren()[0]);
		//codeoutput<<"\tMOV CX,AX"<<endl;
		unary_expression(s->getChildren()[2]);
        codeoutput<<"\tPOP BX"<<endl;
		codeoutput<<"\tPOP AX"<<endl;
		codeoutput<<"\tXOR DX, DX"<<endl;

		operation = s->getChildren()[1]->getName() == "*" ? "IMUL" : "IDIV";
		codeoutput<<"\t"<<operation<<" BX"<<endl;

		string result = s->getChildren()[1]->getName() == "%" ? "DX" : "AX";
		codeoutput<<"\tPUSH "<<result<<endl;

		if(s->getChildren()[1]->getName()== "*")
		{
            //codeoutput<<"MUL CX\n\tPUSH DX\n\tPOP AX"<<endl;
		}
		else
		{
            //codeoutput<<"DIV CX\n\tPUSH DX\n\tPOP AX"<<endl;
		}


	}
}

void simple_expressionFunc(SymbolInfo *s)
{
	if(s->getChildren().size()==1)
	termFunc(s->getChildren()[0]);
	else
	{
		simple_expressionFunc(s->getChildren()[0]);
		test<<"\tMOV DX, AX"<<endl;
		termFunc(s->getChildren()[2]);
		test<<"\tADD AX, DX"<<endl;
        
		string operation;

		codeoutput<<"\tPOP BX"<<endl;
        codeoutput<<"\tPOP AX"<<endl;

        
		if(s->getChildren()[1]->getName() == "+")
        operation ="ADD" ;
		else
		operation = "SUB";

        codeoutput<<"\t"<<operation<<" AX, BX"<<endl;
        codeoutput<<"\tPUSH AX"<<endl;

		
	}
}

string jumpInsfrmRelop(string relop){
    if(relop == "<") return "JL";
    if(relop == "<=") return "JLE";
    if(relop == ">") return "JG";
    if(relop == ">=") return "JGE";
    if(relop == "==") return "JE";
    if(relop == "!=") return "JNE";
}


void rel_expressionFunc(SymbolInfo *s)
{
	if(s->getChildren().size()==1)
	simple_expressionFunc(s->getChildren()[0]);

	else
	{
		simple_expressionFunc(s->getChildren()[0]);
		simple_expressionFunc(s->getChildren()[2]);

        string leveltrue,endlevel,operation;

		leveltrue = newlevel();
		endlevel = newlevel();
		operation = jumpInsfrmRelop(s->getChildren()[1]->getName());

		codeoutput<<"\tPOP BX"<<endl;
		codeoutput<<"\tPOP AX"<<endl;
		codeoutput<<"\tCMP AX, BX"<<endl;
		codeoutput<<"\t"<<operation<<" "<<leveltrue<<endl;
		codeoutput<<"\tPUSH 0\n\tJMP "<<endlevel<<endl;
		codeoutput<<"\t"<<leveltrue<<":\n\tPUSH 1"<<endl;
		codeoutput<<endlevel<<":"<<endl;

	}
}

void logic_expressionFunc(SymbolInfo *s)
{
	if(s->getChildren().size()==1)
	rel_expressionFunc(s->getChildren()[0]);
	else if(s->getChildren().size()==3)
	{
		string bval ;
		rel_expressionFunc(s->getChildren()[0]);
		codeoutput<<"\tPOP AX"<<endl;
		if(s->getChildren()[1]->getName() == "&&")
		 bval = "1";
		else
		bval = "0";
		codeoutput<<"CMP AX, "<<bval<<endl;
		string jlvl = newlevel();
        codeoutput<<"\tJNE "<<jlvl<<endl;
		s->getChildren()[0]->setlevel(jlvl);

		rel_expressionFunc(s->getChildren()[2]);

		codeoutput<<"\tPOP AX"<<endl;

        if(s->getChildren()[1]->getName() == "&&")
		bval = "1";
		else
		bval = "0";

		
		codeoutput<<"\tCMP AX, "<<bval<<endl;
		codeoutput<<"\tJNE "<<s->getChildren()[0]->getlevel()<<endl;
        
		if(s->getChildren()[1]->getName() == "&&")
		bval = "1";
		else
		bval = "0";

		
		codeoutput<<"\tPUSH "<<bval<<endl;
		string logicEnd = newlevel();
		codeoutput<<"\tJMP "<<logicEnd<<endl;
		codeoutput<<s->getChildren()[0]->getlevel()<<":"<<endl;

        if(s->getChildren()[1]->getName() == "&&")
		bval = "0";
		else
		bval = "1";
		
		
		codeoutput<<"\tPUSH "<<bval<<endl;
		codeoutput<<logicEnd+":"<<endl;

	}
}

void idFunc(SymbolInfo *s)
{
	for(int i=0;i<localVariables.size();i++)
	{
		
		if(s->getName() == localVariables[i])
		{
		    codeoutput<<"MOV AX, [BP-"<<(i+1)*2<<"]"<<endl;
			x=0;
			y=1;
			break;
		}
		
	}
	if(y==0)
	{
		
			codeoutput<<"\tMOV "<<s->getName()<<", AX"<<endl;
			codeoutput<<"\tPUSH AX"<<endl;
			codeoutput<<"\tPOP AX"<<endl;
			
		
	}
	
}

void variableFunc(SymbolInfo *s)
{
	SymbolInfo *t = table->LookUP(s->getChildren()[0]->getName());
	s->getChildren()[0]->setasmName(t->getasmName());
	
	// if(s->getChildren().size()==1)
	// idFunc(s->getChildren()[0]);
	if(s->getChildren().size() == 4)
	{
		expressionFunc(s->getChildren()[2]);
		
		codeoutput<<"\tPOP AX"<<endl;
        codeoutput<<"\tSHL AX, 1"<<endl;
        codeoutput<<"\tLEA BX, "<<s->getasmName()<<endl;
        codeoutput<<"\tSUB BX, AX"<<endl;
        codeoutput<<"\tPUSH BX"<<endl;

		s->getChildren()[0]->setasmName("[BX]");
	}
	
}

void expressionFunc(SymbolInfo *s)
{
	test<<"in expressionFunc"<<endl;
	if(s->children.size() == 3)
	{
		codeoutput<<"L"<<level<<":"<<endl;
		level++;
		variableFunc(s->getChildren()[0]);
		logic_expressionFunc(s->getChildren()[2]);
		codeoutput<<"\tPOP AX"<<endl;
		codeoutput<<"\tMOV "<<getAdrress(s->getChildren()[0])<<", AX" <<endl;
		codeoutput<<"\tPUSH AX"<<endl;
		
		
	}
	else
	{
		logic_expressionFunc(s->getChildren()[0]);
	}

}

void printFunc(SymbolInfo *si)
{
	codeoutput<<"\tCALL print_output"<<endl;
	codeoutput<<"\tCALL new_line"<<endl;
}

void vardecFunc(SymbolInfo *si)
{
	test<<"var here"<<endl;
	vector<SymbolInfo*> localvar;
	getVars(localvar,si->getChildren()[1]);
	

	// for(int i=0;i<localVariables.size();i++)
	// {
	// 	codeoutput<<"\tSUB SP,2"<<endl;
	// }
	
	for(SymbolInfo*v : localvar)
	{
		table->InsertSymbol(v->getName(),v->getType());
	}

    
	for(SymbolInfo* v : localvar)
	{
         SymbolInfo *s = table->LookUP(v->getName());
		 test<<"name is "<<s->getName()<<endl;
		 if(s->array)
		 {
			s->setsizeOfArray(v->getsizeOfArray());
		 }
		 if(s->array ==false)
		{
		 	stackoffset+=2;
			codeoutput<<"\tSUB SP,2"<<endl;
			s->setasmName(" [BP-" + to_string(stackoffset) + "]");
		 	
		 }
		else if(s->array == true)
		{
			  int startOfArray = stackoffset+2;
			  int size = s->getsizeOfArray();
			  string str = to_string(startOfArray);
			  s->setasmName(" [BP-" + to_string(startOfArray) + "]");

			  stackoffset+=(size*2);
			  codeoutput<<"\tSUB SP,"<<(size*2)<<"\t";

		}

	}
	
}

void getAllStatements(vector<SymbolInfo*> &st, SymbolInfo *si)
{
   if(si->getChildren().size()==2)
	{
		getAllStatements(st,si->getChildren()[0]);
		st.push_back(si->getChildren()[1]);

	}
	else
	st.push_back(si->getChildren()[0]);
}

void expressionstamentFunc(SymbolInfo *s)
{
	if(s->getChildren().size()==2)
	{
		expressionFunc(s->getChildren()[0]);
	}
}

void statementFunc(SymbolInfo *s)
{
	
    
	if(s->getChildren()[0]->getType() == "var_declaration")
	vardecFunc(s->getChildren()[0]);

	else if(s->getChildren()[0]->getType() == "expression_statement")
	{
      //test<<"Expression  "<<endl;
      
		// test<<"Expression is "<<s->getChildren()[0]->getChildren()[0]->getType()<<endl;
         expressionstamentFunc(s->getChildren()[0]);
		 codeoutput<<"\tPOP AX"<<endl;
	  
	  
	}

	else if(s->getChildren()[0]->getType() == "compound_statement")
	{
      //test<<"Expression  "<<endl;
      
		// test<<"Expression is "<<s->getChildren()[0]->getChildren()[0]->getType()<<endl;
         compound_statementFunc(s->getChildren()[0]);
		 //codeoutput<<"\tPOP AX"<<endl;
	  
	  
	}
	
    else if(s->getChildren().size() == 7)
	{
		
        else if(s->getChildren()[0]->getName()=="if"){
            expressionFunc(s->getChildren()[2]);
            
            string endif = newlabel("END_IF");
            codeoutput<<"\tPOP AX"<<endl;
            codeoutput<<"\tCMP AX, 0"<<endl;
            codeoutput<<"\tJE "<<endif<<endl;
            s->getChildren()[2]->setlevel(endif);

            statementFunc(s->getChildren()[4]);

            string elseEnd = newlabel("END_ELSE");
            codeoutput<<"\tJMP "<<elseEnd<<endl; 
            codeoutput<<"\t"<<s->getChildren()[0]->getlevel()+":"<<endl;
            s->getChildren()[0]->setlevel(elseEnd);

            statementFunc(s->getChildren()[6]);

            codeoutput<<"\t"<<s->getChildren()[0]->getlevel()+":"<<endl;

        }
	}

	else if(s->getChildren().size() == 5)
	{
		//codeoutput<<"L"<<level++<<":"<<endl;
		//codeoutput<<"In print"<<endl;
		if(s->getChildren()[0]->getName() == "if")
		{
            expressionFunc(s->getChildren()[2]);

            codeoutput<<"\tPOP AX"<<endl;
            codeoutput<<"\tCMP AX, 0"<<endl;
			string endif = newlabel("END_IF");
			
            codeoutput<<"\tJE "<<endif<<endl;
            s->getChildren()[2]->setlevel(endif);

            statementFunc(s->getChildren()[4]);
			codeoutput<<s->getChildren()[0]->getlevel()<<":"<<endl;
		}

         
		else if(s->getChildren()[0]->getName() == "println")
		{
        test<<"in primnt"<<endl;
		SymbolInfo *t =table->LookUP(s->getChildren()[2]->getName());
		codeoutput<<"\tMOV BX, "<<t->getasmName()<<endl;
		
		codeoutput<<"\tCALL print_output"<<endl;
	    codeoutput<<"\tCALL new_line"<<endl;
		}
		
		


		//printFunc(s->getChildren()[0]);
	
	}

	else if(s->getChildren().size() == 3)
	{
		expressionFunc(s->getChildren()[1]);

       codeoutput<<"\tPOP AX"<<endl;
       codeoutput<<"\tMOV [BP+4], AX"<<endl;

       codeoutput<<"\tADD SP, "+to_string(stackoffset)<<endl;
       codeoutput<<"\tPOP BP"<<endl;
       codeoutput<<"\tRET"<<endl;
	}
}

void error_check(SymbolInfo *sym)
{ 

}

void startOfstatementsFunc(SymbolInfo *symblInfo)
{
	test<<"startOfstatementsFunc"<<endl;
	vector<SymbolInfo*> allstatements;
	
	getAllStatements(allstatements,symblInfo);
	for(SymbolInfo* st:allstatements)
	{
		statementFunc(st);
	}
	

	
}

void compound_statementFunc(SymbolInfo *symblInfo)
{
		test<<"compound_statementFunc"<<endl;
	   
       if(symblInfo->getChildren().size() == 3)
	   startOfstatementsFunc(symblInfo->getChildren()[1]);
}

void getProgramUnit(vector<SymbolInfo*> & programUnit,SymbolInfo *sinfo)
{
	if(sinfo->getName() != "unit")
	{
		getProgramUnit(programUnit,sinfo->getChildren()[0]);
		programUnit.push_back(sinfo->getChildren()[1]);
	}
	else
	{
		programUnit.push_back(sinfo->getChildren()[0]);
	}
}

void func_definitionFunc(SymbolInfo *symblInfo)
{
	   test<<"func_definitionFunc"<<endl;
       if(symblInfo->getChildren().size() == 5)
	   {
		compound_statementFunc(symblInfo->getChildren()[4]);
	   }
	   else
		compound_statementFunc(symblInfo->getChildren()[5]);

}


void expression_statementFunc(SymbolInfo *symblInfo)
{
   
}




void startFunc(SymbolInfo *symblInfo)
{
	vector<SymbolInfo*>programUnit;
    
	

	getProgramUnit(programUnit,symblInfo->getChildren()[0]);
	
	for(SymbolInfo* u:programUnit)
	{

		if(u->getName()=="var_declaration")
		{
			SymbolInfo *s = u->getChildren()[0];
			
			//codeoutput<<s->getName()<<endl;
			vector<SymbolInfo *>variables;
			getVars(variables,s->getChildren()[1]);


			// for(SymbolInfo* var: variables)
			// {
			// 	//codeoutput<<var->getName()<<endl;
			// 	table->InsertSymbol(var->getName(),var->getType());
			// }
			//table->printAllScopeTable(test);
            
			for(SymbolInfo* var: variables){
				SymbolInfo *s =table->LookUP(var->getName());
				test<<s->getName()<<" "<<s->array<<" ";
				if(s->array == true)
				{
					s->setsizeOfArray(var->getsizeOfArray());
				}
				if(s->array == false)
				{
					
				  codeoutput<<"\t"<<s->getName()<<" DW "<<1<<" DUP (0000H)"<<endl;
				}
				else if(s->array)
				{
				  //codeoutput<<"test array"<<endl;
				  codeoutput<<"\t"<<s->getName()<<" DW "<<s->getsizeOfArray()<<" DUP (0000H)"<<endl;

				}
				s->setasmName(s->getName());
			}
			

		}
	}
	codeoutput<<".CODE"<<endl;
	for(SymbolInfo* u:programUnit)
	{
		test<<u->getName()<<endl;
		stackoffset =0;
		if(u->getName() == "func_definition")
		{
			test<<"came"<<endl;
			SymbolInfo* t = u->getChildren()[0]->getChildren()[1];
			//codeoutput<<t->getName()<<endl;
		    if(t->getName() =="main")
			{
			 codeoutput<<"main PROC"<<endl;
		     codeoutput<<"\tMOV AX, @DATA"<<endl;
			 codeoutput<<"\tMOV DS, AX"<<endl;
			 codeoutput<<"\tPUSH BP"<<endl;
			 codeoutput<<"\tMOV BP,SP"<<endl;
			 //test<<"func_definitionFunc"<<endl;
			 func_definitionFunc(u->getChildren()[0]);
			}
		
		}
	}
	codeoutput<<"\tMOV AX,4CH\n\tINT 21H"<<endl;
	codeoutput<<"main ENDP\nnew_line proc\n\tpush ax\n\tpush dx\n\tmov ah,2\n\tmov dl,cr\n\tint 21h\n\tmov ah,2\n\tmov dl,lf\n\tint 21h\n\tpop dx\n\tpop ax\n\tret\nnew_line endp\nprint_output proc  ;print what is in ax\n\tpush ax\n\tpush bx\n\tpush cx\n\tpush dx\n\tpush si\n\tlea si,number\n\tmov bx,10\n\tadd si,4\n\tcmp ax,0\n\tjnge negate\n\tprint:\n\txor dx,dx\n\tdiv bx\n\tmov [si],dl\n\tadd [si],'0'\n\tdec si\n\tcmp ax,0\n\tjne print\n\tinc si\n\tlea dx,si\n\tmov ah,9\n\tint 21h\n\tpop si\n\tpop dx\n\tpop cx\n\tpop bx\n\tpop ax\n\tret\n\tnegate:\n\tpush ax\n\tmov ah,2\n\tmov dl,'-'\n\tint 21h\n\tpop ax\n\tneg ax\n\tjmp print\nprint_output endp\nEND main\n"<<endl;

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

start :program
	{
		//write your code in this block in all the similar blocks below
	$$ = new SymbolInfo("program","start");

	codeoutput<<".MODEL SMALL"<<endl;
	codeoutput<<".STACK 1000H"<<endl;
    codeoutput<<".Data"<<endl;
	codeoutput<<"\tCR EQU 0DH"<<endl;
	codeoutput<<"\tLF EQU 0AH"<<endl;
	codeoutput<<"\tnumber DB \"00000$\""<<endl;

	table->printAllScopeTable(test);
	
    

	logout<<"start : program"<<"\n";
	$$->children.push_back($1);
    $$->startline = $$->children[0]->startline;
	$$->endline = $$->children[0]->endline;	
	printParseTree(0,$$);
	startFunc($$);

	logout<<"Total Lines : "<<line_count<<endl;
    logout<<"Total Error : "<<error_count<<endl;
	


	}
	;

program: program unit {
	$$ = new SymbolInfo("program unit", "program");
	logout<<"program : program unit"<<"\n";
	$$->children.push_back($1);
	$$->children.push_back($2);
	$$->startline = $$->children[0]->startline;
	$$->endline = $$->children[1]->endline;

	}
	| unit {
    $$ = new SymbolInfo("unit", "program");
	logout<<"program : unit"<<"\n";
	$$->children.push_back($1);
	$$->startline = $$->children[0]->startline;
	$$->endline = $$->children[0]->endline;
	}
	;
	
unit: var_declaration {
	$$ = new SymbolInfo("var_declaration", "unit");
	logout<< "unit : var_declaration"<<"\n";
	$$->children.push_back($1);
	$$->startline = $$->children[0]->startline;
	$$->endline = $$->children[0]->endline;
	}

    | func_declaration {
    $$ = new SymbolInfo("func_declaration", "unit");
	logout<< "unit : func_declaration"<<"\n";
	$$->children.push_back($1);
	$$->startline = $$->children[0]->startline;
	$$->endline = $$->children[0]->endline;

	 }
    | func_definition {
    $$ = new SymbolInfo("func_definition", "unit");
	logout<< "unit : func_definition"<<"\n";
	$$->children.push_back($1);
	$$->startline = $$->children[0]->startline;
	$$->endline = $$->children[0]->endline;
	 }
     ;
     
func_declaration: type_specifier ID LPAREN parameter_list RPAREN SEMICOLON {
	$$ = new SymbolInfo("type_specifier ID LPAREN parameter_list RPAREN SEMICOLON", "func_declaration");
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
	sInfo->setParamList({});
	bool success = table->InsertSymbol($2->getName(),$2->gettypeSpec());
	if(success == false)
	errorout<<"Line# "<<line_count<<": "<<"multiple declaration of function "<<$2->getName()<<endl;
	
	
	}

	| type_specifier ID LPAREN RPAREN SEMICOLON {
		$$ = new SymbolInfo("type_specifier ID LPAREN RPAREN SEMICOLON", "func_declaration");
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
		sInfo->setParamList({});
		bool success = table->InsertSymbol($2->getName(),$2->gettypeSpec());
		if(success == false)
		errorout<<"Line# "<<line_count<<": "<<" multiple declaration of function "<<$2->getName()<<endl;
	}
	;
		 
func_definition: type_specifier ID LPAREN parameter_list RPAREN {
	    bool success = table->InsertSymbol($2->getName(),$2->getType());
	    $2->settypeSpec($1->gettypeSpec());
		$2->setParamList(sInfo->getParamList());
		$2->funcDef =true;
		if(success == false)
		{
           SymbolInfo *temp = table->LookUP($2->getName());
		   if(temp->funcDec == false)
		   {
		      errorout<<"Line# "<<line_count<<": "<<" Conflicting types for "<<$2->getName()<<endl;
			
		   }
		   else
		   {
			if(temp->gettypeSpec() != $2->gettypeSpec())
			{
		        errorout<<"Line# "<<line_count<<": "<<" Conflicting types for "<<$2->getName()<<endl;

			}
			if(temp->getParamList().size() != $2->getParamList().size() )
			{
		        errorout<<"Line# "<<line_count<<": "<<" Conflicting types for "<<$2->getName()<<endl;

			}
			else
			{
				for(int i=0;i<temp->getParamList().size();i++){

					if( $2->paramList[i]->gettypeSpec()!= temp->paramList[i]->gettypeSpec()){
						errorout<<"Type mismatch for argument "<<i+1<<" of"<<$2->getName()<<endl;

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
		//stackoffset=0;
} compound_statement {
		$$ = new SymbolInfo("type_specifier ID LPAREN parameter_list RPAREN compound_statement", "func_definition");
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
		$$ = new SymbolInfo("type_specifier ID LPAREN RPAREN compound_statement", "func_definition");
		$$->children.push_back($1);
		$$->children.push_back($2);
		$$->children.push_back($3);
		$$->children.push_back($4);
		$$->children.push_back($5);
		logout<< "func_definition : type_specifier ID LPAREN RPAREN compound_statement"<<endl;
		$$->startline = $$->children[0]->startline;
		$$->endline = $$->children[4]->endline;
		for(string gval:globalVariables)
	  {
		//codeoutput<<"\t"<<gval<<" DW 1 DUP (0000H)"<<endl;
	  }
	  if($2->getName()=="main")
	  {
		// codeoutput<<".CODE"<<endl;
		// codeoutput<<"main PROC"<<endl;
		// codeoutput<<"\tMOV AX, @DATA"<<endl;
	    // codeoutput<<"\tMOV DS, AX"<<endl;
		// codeoutput<<"\tPUSH BP"<<endl;
	  }
	 // for(string lval:localVariables)
	 // codeoutput<<"\tSUB SP,2"<<endl;
	//codeoutput<<".CODE"<<endl;
		
	}
	;				


parameter_list: parameter_list COMMA type_specifier ID {
        $$ = new SymbolInfo("parameter_list COMMA type_specifier ID", "parameter_list");
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
	
		if( $3->gettypeSpec() == "VOID" ){
		errorout<<"Line# "<<line_count<<": "<<"Variable type cannot be void"<<endl;
		sInfo->setParamList($$->getParamList());
			
	}

	}
		| parameter_list COMMA type_specifier {
        $$ = new SymbolInfo("parameter_list COMMA type_specifier", "parameter_list");
		$$->children.push_back($1);
		$$->children.push_back($2);
		$$->children.push_back($3);
		logout<< "parameter_list : parameter_list COMMA type_specifier"<<endl;
		$$->startline = $$->children[0]->startline;
	    $$->endline = $$->children[2]->endline;
		SymbolInfo *id = new SymbolInfo("ID","");
		id->settypeSpec($3->gettypeSpec());
        $$->setParamList($1->getParamList());
		$$->paramList.push_back(id);
		sInfo->setParamList($$->getParamList());
		if( $3->gettypeSpec() == "VOID" ){
		errorout<<"Line# "<<line_count<<": "<<"Variable type cannot be void"<<endl;	
		}	
	}
 		| type_specifier ID {
        $$ = new SymbolInfo("type_specifier ID", "parameter_list");
		$$->children.push_back($1);
		$$->children.push_back($2);
		logout<< "parameter_list : type_specifier ID"<<endl;
		$$->startline = $$->children[0]->startline;
	    $$->endline = $$->children[1]->endline;
		$2->settypeSpec($1->gettypeSpec());
		$$->paramList.push_back($2);	
		if( $1->gettypeSpec() == "VOID" ){
		errorout<<"Line# "<<line_count<<": "<<"Variable type cannot be void"<<endl;
		sInfo->setParamList($$->getParamList());
		}
		}
		| type_specifier {
        $$ = new SymbolInfo("type_specifier", "parameter_list");
		$$->children.push_back($1);
		logout<< "parameter_list : type_specifier"<<endl;
		$$->startline = $$->children[0]->startline;
	    $$->endline = $$->children[0]->endline;
		SymbolInfo *id = new SymbolInfo("ID","");
		id->settypeSpec($1->gettypeSpec());
		$$->paramList.push_back($1);	
		if( $1->gettypeSpec() == "VOID" ){
		errorout<<"Line# "<<line_count<<": "<<"Variable type cannot be void"<<endl;
		sInfo->setParamList($$->getParamList());

		}
		}
 		;

 		
compound_statement: LCURL {
	table->EnterScope();
	for(auto symbInfo : sInfo->getParamList())
	{
	bool success = table->InsertSymbol(symbInfo->getName(),symbInfo->getType());


	}
	sInfo->setParamList({});



 } statements RCURL {
        $$ = new SymbolInfo("LCURL statements RCURL", "compound_statement");
		$$->children.push_back($1);
		$$->children.push_back($3);
		$$->children.push_back($4);
		logout<< "compound_statement : LCURL statements RCURL"<<endl;
		$$->startline = $$->children[0]->startline;
	    $$->endline = $$->children[2]->endline;
		table->printAllScopeTable(logout);
		table->exitScope();
		// codeoutput<<"MOV AX,4CH"<<endl;
	    // codeoutput<<"INT 21H"<<endl;

	}
 		| LCURL {table->EnterScope();
		for(auto symbInfo : sInfo->getParamList())
				{
				bool success = table->InsertSymbol(symbInfo->getName(),symbInfo->getType());

				}
	    sInfo->setParamList({});

		} RCURL {
        $$ = new SymbolInfo("LCURL RCURL", "compound_statement");
		$$->children.push_back($1);
		$$->children.push_back($3);
		logout<< "compound_statement : LCURL RCURL"<<endl;
		$$->startline = $$->children[0]->startline;
	    $$->endline = $$->children[1]->endline;
		table->printAllScopeTable(logout);
		table->exitScope();
		// codeoutput<<"MOV AX,4CH"<<endl;
	    // codeoutput<<"INT 21H"<<endl;

		}
 		;
 		    
var_declaration: type_specifier declaration_list SEMICOLON {
		$$ = new SymbolInfo("type_specifier declaration_list SEMICOLON", "var_declaration");
		$$->children.push_back($1);
		$$->children.push_back($2);
		$$->children.push_back($3);
		logout<< "var_declaration : type_specifier declaration_list SEMICOLON"<<"\n";
		$$->startline = $$->children[0]->startline;
		$$->endline = $$->children[2]->endline;
		//codeoutput<<"abc"<<endl;
        if($1->gettypeSpec() =="VOID")
        errorout<<"Line# "<<line_count<<": "<<"Variable type cannot be void"<<endl;
		else
		{
			for(auto symbolInfo:$2->getDecList()){
				symbolInfo->settypeSpec($1->gettypeSpec());
		     	bool success = table->InsertSymbol(symbolInfo->getName(),symbolInfo->getType());
				
				// if(success)
				// codeoutput<<"s"<<endl;
				if(success == false ){
					
					errorout<<"Line# "<<line_count<<": "<<" Conflicting types for "<<symbolInfo->getName()<<endl;
				}
				else if(table->getScopeCount() == 1)
				{

					globalVariables.push_back(symbolInfo->getName());
				}
				else
				{
					
				    localVariables.push_back(symbolInfo->getName());

				}
				
			}
			

		}

	}
 		 ;
 		 
type_specifier: INT {
           $$ = new SymbolInfo("INT", "type_specifier");
		   $$->children.push_back($1);
		   logout<< "type_specifier	: INT"<<"\n"; 
		   $$->startline = $$->children[0]->startline;
		   $$->endline = $$->children[0]->endline;
           $$->settypeSpec($1->gettypeSpec());

	}
 		| FLOAT {
            $$ = new SymbolInfo("FLOAT", "type_specifier");
			$$->children.push_back($1);
			logout<< "type_specifier	: FLOAT"<<"\n"; 
			$$->startline = $$->children[0]->startline;
	        $$->endline = $$->children[0]->endline;
            $$->settypeSpec($1->gettypeSpec());

		}
 		| VOID {
			$$ = new SymbolInfo("VOID", "type_specifier");
			$$->children.push_back($1);
			logout<< "type_specifier	: VOID"<<"\n";
			$$->startline = $$->children[0]->startline;
			$$->endline = $$->children[0]->endline; 
			$$->settypeSpec($1->gettypeSpec());

		}
 		;
 		
declaration_list: declaration_list COMMA ID {
	
           $$ = new SymbolInfo("declaration_list COMMA ID", "declaration_list");
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
           $$ = new SymbolInfo("declaration_list COMMA ID LSQUARE CONST_INT RSQUARE", "declaration_list");
		   $$->children.push_back($1);
		   $$->children.push_back($2);
		   $$->children.push_back($3);
		   $$->children.push_back($4);
		   $$->children.push_back($5);
		   $$->children.push_back($6);
		   logout<< "declaration_list : declaration_list COMMA ID LSQUARE CONST_INT RSQUARE "<<"\n"; 
		   $$->startline = $$->children[0]->startline;
		   $$->endline = $$->children[5]->endline;
		   $$->setDecList($1->getDecList());
		   $3->array =true;
		   $3->setsizeOfArray(stoi($5->getName()));

		   codeoutput<<"test"<<endl;

		   $$->declarationList.push_back($3);


		  }
 		  | ID {
           $$ = new SymbolInfo("ID", "declaration_list");
		   $$->children.push_back($1);
		   logout<< "declaration_list : ID"<<"\n"; 
		   $$->startline = $$->children[0]->startline;
	       $$->endline = $$->children[0]->endline;
		   $$->declarationList.push_back($1);
		  
		  }
 		  | ID LSQUARE CONST_INT RSQUARE {
			$$ = new SymbolInfo("ID LSQUARE CONST_INT RSQUARE", "declaration_list");
			$$->children.push_back($1);
			$$->children.push_back($2);
			$$->children.push_back($3);
			$$->children.push_back($4);
			logout<< "declaration_list : ID LSQUARE CONST_INT RSQUARE"<<"\n"; 
			$$->startline = $$->children[0]->startline;
		    $$->endline = $$->children[3]->endline;
            $1->array=true;
			$1->setsizeOfArray(stoi(($3->getName())));

			$$->declarationList.push_back($1);
			
			
		    codeoutput<<"test1"<<endl;

		  }
 		  ;
 		  
statements: statement {
            $$ = new SymbolInfo("statement", "statements");
		    $$->children.push_back($1);
			logout<< "statements: statement"<<"\n";
			$$->startline = $$->children[0]->startline;
		    $$->endline = $$->children[0]->endline;


	}
	   | statements statement {
            $$ = new SymbolInfo("statements statement", "statements");
		    $$->children.push_back($1);
		    $$->children.push_back($2);
			logout<< "statements: statements statement"<<"\n";
			$$->startline = $$->children[0]->startline;
		    $$->endline = $$->children[1]->endline;
	   }
	   ;
	   
statement: var_declaration {
           $$ = new SymbolInfo("var_declaration", "statement");
		   $$->children.push_back($1);
		   logout<< "statement: var_declaration"<<"\n";
		   $$->startline = $$->children[0]->startline;
		   $$->endline = $$->children[0]->endline;
	  }
	  | expression_statement{
		 $$ = new SymbolInfo("expression_statement", "statement"); 
		 $$->children.push_back($1);
		 logout<< "statement: expression_statement"<<"\n";
		 $$->startline = $$->children[0]->startline;
		 $$->endline = $$->children[0]->endline;
	  }
	  | compound_statement {
		 $$ = new SymbolInfo("compound_statement", "statement");
		 $$->children.push_back($1);
		 logout<< "statement: compound_statement"<<"\n";
		 $$->startline = $$->children[0]->startline;
		 $$->endline = $$->children[0]->endline;

	  }
	  | FOR LPAREN expression_statement expression_statement expression RPAREN statement{
		 $$ = new SymbolInfo("FOR LPAREN expression_statement expression_statement expression RPAREN statement", "statement");
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
		 $$ = new SymbolInfo("IF LPAREN expression RPAREN statement", "statement");
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
		 $$ = new SymbolInfo("IF LPAREN expression RPAREN statement ELSE statement", "statement");
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
		 $$ = new SymbolInfo("WHILE LPAREN expression RPAREN statement", "statement");
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
		 $$ = new SymbolInfo("PRINTLN LPAREN ID RPAREN SEMICOLON", "statement");
		 $$->children.push_back($1);
		 $$->children.push_back($2);
		 $$->children.push_back($3);
		 $$->children.push_back($4);
		 $$->children.push_back($5);
		 logout<< "statement: PRINTLN LPAREN ID RPAREN SEMICOLON"<<"\n";
         $$->startline = $$->children[0]->startline;
		 $$->endline = $$->children[4]->endline;
		 if(table->LookUP($3->getName()) == nullptr)
		 errorout<<"Line# "<<line_count<<": "<<"Undeclared variable "<<$3->getName()<<endl;
	  }
	  | RETURN expression SEMICOLON {
		 $$ = new SymbolInfo("RETURN expression SEMICOLON", "statement");
		 $$->children.push_back($1);
		 $$->children.push_back($2);
		 $$->children.push_back($3);
		 logout<< "statement: RETURN expression SEMICOLON"<<"\n";
		 $$->startline = $$->children[0]->startline;
		 $$->endline = $$->children[2]->endline;

	  }
	  ;
	  
expression_statement: SEMICOLON		{
            $$ = new SymbolInfo("SEMICOLON", "expression_statement");
			$$->children.push_back($1);
			logout<< "expression_statement: SEMICOLON"<<"\n";
			$$->startline = $$->children[0]->startline;
		    $$->endline = $$->children[0]->endline;
		 
	}	
			| expression SEMICOLON {
            $$ = new SymbolInfo("expression SEMICOLON", "expression_statement");
            $$->children.push_back($1);
		    $$->children.push_back($2);
			logout<< "expression_statement: expression SEMICOLON"<<"\n";
            $$->startline = $$->children[0]->startline;
		    $$->endline = $$->children[1]->endline;
			$$->settypeSpec($1->gettypeSpec());
			}
			;
	  
variable: ID {
            $$ = new SymbolInfo("ID", "variable");
			$$->children.push_back($1);
			logout<< "variable: ID "<<"\n";
			$$->startline = $$->children[0]->startline;
	        $$->endline = $$->children[0]->endline;
			SymbolInfo *ptr = table->LookUP($1->getName());
			if( ptr == nullptr)
			{
				errorout<<"Line# "<<line_count<<": "<<"Undeclared variable "<<$1->getName()<<endl;
			}
			else if(ptr-> array == true)
			{

				errorout<<"Line# "<<line_count<<": "<<"Type mismatch "<<$1->getName()<<" is an array"<<endl;
			}
			else if(ptr->funcDec == true)
			{
				errorout<<"Line# "<<line_count<<": "<<"Redeclaration "<<$1->getName()<<endl;

			}
			else
			{
				$$->array = ptr->array;
				$$->settypeSpec(ptr->gettypeSpec());
			}
			// SymbolInfo *s = table->LookUP($1->getName());
			// if(s != nullptr)
			// //codeoutput<<"MOV AX, [BP-"<<s->getOffset()<<"]"<<endl;
			

	}
	 | ID LSQUARE expression RSQUARE {
            $$ = new SymbolInfo("ID LSQUARE expression RSQUARE", "variable");
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
				errorout<<"Line# "<<line_count<<": "<<"Undeclared variable "<<$1->getName()<<endl;
			}
			else if(ptr->array == false)
			{
				errorout<<"Line# "<<line_count<<": "<<"Not an array "<<$1->getName()<<endl;
				$$->settypeSpec(ptr->gettypeSpec());

			}
			else if(ptr->funcDec == true)
			{
				errorout<<"Line# "<<line_count<<": "<<"Redeclaration "<<$1->getName()<<endl;

			}
			else
			{
				$$->settypeSpec(ptr->gettypeSpec());
			}
			if($3->gettypeSpec() != "INT" )
			{
				errorout<<"Line# "<<line_count<<": "<<"Array Subscript is not an integer "<<endl;
			}


	 }
	 ;
	 
 expression: logic_expression	{
            $$ = new SymbolInfo("logic_expression", "expression");
			$$->children.push_back($1);
			logout<< "expression: logic_expression"<<"\n";
			$$->startline = $$->children[0]->startline;
		    $$->endline = $$->children[0]->endline;
			$$->settypeSpec($1->gettypeSpec());

			$$->settypeSpec($1->gettypeSpec());
			$$->array= $1->array;

 	}
	   | variable ASSIGNOP logic_expression {
            $$ = new SymbolInfo("variable ASSIGNOP logic_expression", "expression");
			$$->children.push_back($1);
		    $$->children.push_back($2);
		    $$->children.push_back($3);
			logout<< "expression: variable ASSIGNOP logic_expression"<<"\n";
			$$->startline = $$->children[0]->startline;
		    $$->endline = $$->children[2]->endline;
			if($3->gettypeSpec()=="VOID")
			{
				errorout<<"Line# "<<line_count<<": "<<"Void cannot be used in expression "<<endl;
			}
			else if($1->gettypeSpec() == "INT" && $3->gettypeSpec() == "FLOAT")
			{
				errorout<<"Line# "<<line_count<<": "<<" Warning: possible loss of data in assignment of FLOAT to INT"<<endl;
			}
			
			//codeoutput<<"MOV AX, [BP-"<<$1->getOffset()<<"]"<<endl;



	   }	
	   ;
			
logic_expression: rel_expression 	{
            $$ = new SymbolInfo("rel_expression", "logic_expression");
			$$->children.push_back($1);
			logout<< "logic_expression: rel_expression"<<"\n";
			$$->startline = $$->children[0]->startline;
		    $$->endline = $$->children[0]->endline;
            $$->settypeSpec($1->gettypeSpec());
			$$->array = $1->array;
			


	}
		 | rel_expression LOGICOP rel_expression {
            $$ = new SymbolInfo("rel_expression LOGICOP rel_expression", "logic_expression");
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
            $$ = new SymbolInfo("simple_expression", "rel_expression");
			$$->children.push_back($1);
			logout<< "rel_expression: simple_expression"<<"\n";
            $$->startline = $$->children[0]->startline;
		    $$->endline = $$->children[0]->endline;
			$$->array = $1->array;
	
	}
		| simple_expression RELOP simple_expression	{
            $$ = new SymbolInfo("simple_expression RELOP simple_expression", "rel_expression");
			$$->children.push_back($1);
		    $$->children.push_back($2);
		    $$->children.push_back($3);
			logout<< "rel_expression: simple_expression RELOP simple_expression"<<"\n";
            $$->startline = $$->children[0]->startline;
		    $$->endline = $$->children[2]->endline;
            if($1->gettypeSpec() == "VOID" || $3->gettypeSpec() == "VOID")
			{
				errorout<<"Line# "<<line_count<<": "<<" Void cannot be used in expression"<<endl;

			}
			else 
			$$->settypeSpec("INT");
		}
		;
				
simple_expression: term {
            $$ = new SymbolInfo("term", "simple_expression");
			$$->children.push_back($1);
			logout<< "simple_expression: term"<<"\n";
			$$->startline = $$->children[0]->startline;
		    $$->endline = $$->children[0]->endline;
			$$->settypeSpec($1->gettypeSpec());
			$$->array = $1->array;
			


	}
		  | simple_expression ADDOP term {
            $$ = new SymbolInfo("simple_expression ADDOP term", "simple_expression");
			$$->children.push_back($1);
		    $$->children.push_back($2);
		    $$->children.push_back($3);
			logout<< "simple_expression: simple_expression ADDOP term"<<"\n";
			$$->startline = $$->children[0]->startline;
		    $$->endline = $$->children[2]->endline;
            if($1->gettypeSpec() =="VOID" ||$3->gettypeSpec() =="VOID")
			{
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
            $$ = new SymbolInfo("unary_expression", "term");
			$$->children.push_back($1);
			logout<< "term:	unary_expression "<<"\n";
			$$->startline = $$->children[0]->startline;
		    $$->endline = $$->children[0]->endline;
            $$->array = $1->array;
			$$->settypeSpec($1->gettypeSpec());
			
	}
     |  term MULOP unary_expression {
		    $$ = new SymbolInfo("term MULOP unary_expression", "term");
			$$->children.push_back($1);
		    $$->children.push_back($2);
		    $$->children.push_back($3);
			logout<< "term: term MULOP unary_expression"<<"\n";
			$$->startline = $$->children[0]->startline;
		    $$->endline = $$->children[2]->endline;
            if($1->gettypeSpec() =="VOID" || $3->gettypeSpec() =="VOID")
			{
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
				errorout<<"Line# "<<line_count<<": "<<"Warning: division by zero i=0f=1Const=0"<<endl;

			}
			else if($2->getName()=="%" && ($1->gettypeSpec() != "INT" || $3->gettypeSpec() != "INT" ))
			{
				errorout<<"Line# "<<line_count<<": "<<"Operands of modulus must be integers "<<endl;

			}

	 }
     ;

unary_expression: ADDOP unary_expression  {
		    $$ = new SymbolInfo("ADDOP unary_expression", "unary_expression");
			$$->children.push_back($1);
		    $$->children.push_back($2);	
			logout<< "unary_expression: ADDOP unary_expression"<<"\n";
			$$->startline = $$->children[0]->startline;
		    $$->endline = $$->children[1]->endline;
			if($2->gettypeSpec()=="VOID")
			{
				errorout<<"Line# "<<line_count<<": "<<" Void cannot be used in expression"<<endl;
				
			}
			else
			$$->settypeSpec($2->gettypeSpec());


	}
		 | NOT unary_expression {
		    $$ = new SymbolInfo("NOT unary_expression", "unary_expression");
			$$->children.push_back($1);
		    $$->children.push_back($2);
			logout<< "unary_expression: NOT unary_expression"<<"\n";
			$$->startline = $$->children[0]->startline;
		    $$->endline = $$->children[1]->endline;
			if($2->gettypeSpec()=="VOID")
			{
				errorout<<"Line# "<<line_count<<": "<<" Void cannot be used in expression"<<endl;
				
			}
			else
			$$->settypeSpec("INT");

		 }
		 | factor {
		    $$ = new SymbolInfo("factor", "unary_expression");
			$$->children.push_back($1);
			logout<< "unary_expression: factor"<<"\n";
			$$->startline = $$->children[0]->startline;
		    $$->endline = $$->children[0]->endline;
			$$->settypeSpec($1->gettypeSpec());
			$$->array =$1->array;


		 }
		 ;
	
factor: variable {
			$$ = new SymbolInfo("variable", "factor");
			$$->children.push_back($1);
			logout<< "factor: variable"<<"\n";
			$$->startline = $$->children[0]->startline;
			$$->endline = $$->children[0]->endline;
			$$->settypeSpec($1->gettypeSpec());
			$$->array =$1->array;

	}
	| ID LPAREN argument_list RPAREN {
			$$ = new SymbolInfo("ID LPAREN argument_list RPAREN", "factor");
			$$->children.push_back($1);
			$$->children.push_back($2);
			$$->children.push_back($3);
			$$->children.push_back($4);
			logout<< "factor: ID LPAREN argument_list RPAREN"<<"\n";
			$$->startline = $$->children[0]->startline;
			$$->endline = $$->children[3]->endline;


			SymbolInfo *ptr = table->LookUP($1->getName());
            if( ptr == nullptr ){
			errorout<<"Line# "<<line_count<<": "<<"Undeclared function "<<$1->getName()<<endl;
		    }
		    else{
			$$->settypeSpec(ptr->gettypeSpec());
			if( ptr->funcDec == false  && ptr->funcDef== false){
				errorout<<"Line# "<<line_count<<": "<<$1->getName()<<" is not a function"<<endl;
			}else if( $3->paramList.size() > ptr->paramList.size()){
				errorout<<"Too many arguments to function "<<$1->getName()<<endl;
			}
			else if( $3->paramList.size() < ptr->paramList.size()){
				errorout<<"Too few arguments to function "<<$1->getName()<<endl;
			}
			else{
	
				for(int i=0;i<$3->paramList.size();i++){

					if( ($3->paramList[i]->array ==true)  && (ptr->paramList[i]->array == false )){
						errorout<<"Type mismatch "<<$3->paramList[i]->getName()+" is an array"<<endl;
					}
					else if( ($3->paramList[i]->array ==false)  && (ptr->paramList[i]->array == true ))
					{
						errorout<<"Type mismatch "<<ptr->paramList[i]->getName()+" is an array"<<endl;

					}
					if( $3->paramList[i]->gettypeSpec()!= ptr->paramList[i]->gettypeSpec()){
						errorout<<"Type mismatch for argument "<<i+1<<" of"<<$1->getName()<<endl;

					}
					
				}
			}
		  }
	}

	
	| LPAREN expression RPAREN {
			$$ = new SymbolInfo("LPAREN expression RPAREN", "factor");
			$$->children.push_back($1);
			$$->children.push_back($2);
			$$->children.push_back($3);
			logout<< "factor: LPAREN expression RPAREN"<<"\n";
			$$->startline = $$->children[0]->startline;
			$$->endline = $$->children[2]->endline;
			$$->settypeSpec($1->gettypeSpec());

	}
	| CONST_INT {
			$$ = new SymbolInfo("CONST_INT", "factor");
			$$->children.push_back($1);
			logout<< "factor: CONST_INT"<<"\n";
			$$->startline = $$->children[0]->startline;
			$$->endline = $$->children[0]->endline;
			$$->settypeSpec("INT");
			
	}
	| CONST_FLOAT{
			$$ = new SymbolInfo("CONST_FLOAT", "factor");
			$$->children.push_back($1);
			logout<< "factor: CONST_FLOAT"<<"\n";
			$$->startline = $$->children[0]->startline;
			$$->endline = $$->children[0]->endline;
			$$->settypeSpec("FLOAT");

	}
	| variable INCOP{
			$$ = new SymbolInfo("variable INCOP", "factor");
			$$->children.push_back($1);
			$$->children.push_back($2);
			logout<< "factor: variable INCOP"<<"\n";
			$$->startline = $$->children[0]->startline;
			$$->endline = $$->children[1]->endline;

			if( $1->gettypeSpec() == "VOID" ){
			errorout<<"Void function used in expression"<<endl;
		    }
			else{
			$$->settypeSpec($1->gettypeSpec());
		}

	} 
	| variable DECOP{
			$$ = new SymbolInfo("variable DECOP", "factor");
			$$->children.push_back($1);
			$$->children.push_back($2);
			logout<< "factor: variable DECOP"<<"\n";
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
			$$ = new SymbolInfo("arguments", "argument_list");
			$$->children.push_back($1);
			logout<< "argument_list: arguments"<<"\n";
			$$->startline = $$->children[0]->startline;
			$$->endline = $$->children[0]->endline;
			$$->setParamList($1->getParamList());
	}
		
		;
	
arguments: arguments COMMA logic_expression{
			$$ = new SymbolInfo("arguments COMMA logic_expression", "arguments");
			$$->children.push_back($1);
			$$->children.push_back($2);
			$$->children.push_back($3);
			logout<<"arguments: arguments COMMA logic_expression"<<"\n";
			$$->startline = $$->children[0]->startline;
			$$->endline = $$->children[2]->endline;
			$$->setParamList($1->getParamList());
			$$->paramList.push_back($3);


	}

	    | logic_expression {
			$$ = new SymbolInfo("logic_expression", "arguments");
			$$->children.push_back($1);
			logout<<"arguments: logic_expression"<<"\n";
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
    test.open("test.txt");
	logout.open("log.txt");
	errorout.open("error.txt");
	parseTree.open("tree.txt");
	codeoutput.open("code.txt");
	optoutput.open("optcode.txt");
	yyin=fp;
	yyparse();
	
	logout.close();
	errorout.close();
	parseTree.close();
	codeoutput.close();
	optoutput.close();
    test.close();
	
	return 0;
}

