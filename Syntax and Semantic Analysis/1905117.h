#include <bits/stdc++.h>
using namespace std;

class SymbolInfo
{
    string name, type,typeSpec;
    SymbolInfo *next;
    int size;
    

public:
    bool funcDef=false;
    bool funcDec=false;
    bool array=false;
    int startline,endline;
    vector<SymbolInfo*> children;
    vector<SymbolInfo*> declarationList;
    vector<SymbolInfo*> paramList;
    bool isLeaf;
    SymbolInfo()
    {
        this->name = " ";
        this->type = " ";
        this->next = nullptr;
        this->array =false;
        this->funcDec=false;
        this->funcDef = false;
        this-> size =0;
        isLeaf=false;
    }
    SymbolInfo(string s, string t)
    {
        this->name = s;
        this->type = t;
        this->next = nullptr;
        this->isLeaf=false;
    }
    SymbolInfo(string s, string t,bool b)
    {
        this->name = s;
        this->type = t;
        this->next = nullptr;
        this->isLeaf=b;
    }
    SymbolInfo(const char* s, const char* t, const char* typeSpecifier)
    {
        this->name = s;
        this->type = t;
        this->typeSpec = typeSpecifier;
        this->isLeaf=true;
    }
    SymbolInfo(string s, string t, string typeSpecifier)
    {
        this->name = s;
        this->type = t;
        this->typeSpec = typeSpecifier;
        this->isLeaf=true;
    }
   
    void setStartline(int s)
    {
      this->startline = s;
    }
    int getStartline()
    {
        return startline;
    }
     void setEndline(int s)
    {
      this->endline = s;
    }
    int getEndline()
    {
        return endline;
    }
    string getName()
    {
        return name;
    }
    void setName(string &str)
    {
        this->name = str;
    }

    void setType(string &t)
    {
        this->type = t;
    }

    string getType()
    {
        return type;
    }

    void setNext(SymbolInfo *next)
    {
        this->next = next;
    }
    SymbolInfo *getNext()
    {
        return next;
    }
    int getSize()
    {
        return size;
    }
    void setSize(int s)
    {
        this->size =s;
    }
    void setParamList(vector<SymbolInfo*> p)
    {
        this->paramList = p;
    }
    vector<SymbolInfo*>getParamList()
    {
        return paramList;
    }
    void setDecList(vector<SymbolInfo*> p)
    {
        this->declarationList = p;
    }
    
    vector<SymbolInfo*>getDecList()
    {
        return declarationList;
    }
    
    bool isFunctionDef()
    {
        return funcDef;
    }
    void setFuncDec(bool f)
    {
        this->funcDec =f;
    }

    void setFuncDef(bool f)
    {
        this->funcDef = f;
    }

    bool isFunctionDec()
    {
        return funcDec;

    }
    
    bool isArray()
    {
        return array;
    }

    string gettypeSpec()
    {
        return typeSpec;
    }
     void settypeSpec(string s)
    {
        this->typeSpec = s;
    }
     SymbolInfo (SymbolInfo *symbolInfo)
    {
        name = symbolInfo->name;
        type = symbolInfo->type;
        array= symbolInfo->array;
        typeSpec = symbolInfo->typeSpec;
        size = symbolInfo->size;
        paramList = symbolInfo-> paramList;
        declarationList = symbolInfo->declarationList;
        funcDec = symbolInfo ->funcDec;
        funcDef = symbolInfo ->funcDef;   

    }
    

    ~SymbolInfo()
    {
    }
};

class ScopeTable
{
    int bucket_size;
    SymbolInfo **hashtable;
    ScopeTable *parentscope;
    int scope_id;

public:
    ScopeTable()
    {
        bucket_size = 10;
    }

    ScopeTable(int bSize)
    {
        this->parentscope = nullptr;
        // this->hashtable=nullptr;
        // this->scope_id=1;
        this->bucket_size = bSize;
        hashtable = new SymbolInfo *[bSize];
        for (int i = 0; i < bSize; i++)
        {
            hashtable[i] = nullptr;
        }
    }

    void setParentScope(ScopeTable *parentscope)
    {
        this->parentscope = parentscope;
    }

    ScopeTable *getParentScope()
    {
        return parentscope;
    }

    int getBucketSize()
    {
        return bucket_size;
    }

    void setBucketSize(int bSize)
    {
        this->bucket_size = bSize;
    }

    void setId(int id)
    {
        this->scope_id = id;
    }

    int getId()
    {
        return scope_id;
    }

    unsigned int SDBMHash(string str)
    {
        unsigned long long int hash = 0;
        unsigned int i = 0;
        unsigned int len = str.length();

        for (i = 0; i < len; i++)
        {
            hash = (str[i]) + (hash << 6) + (hash << 16) - hash;
        }

        return (hash % bucket_size);
    }

    ~ScopeTable()
    {

        for (int i = 0; i < bucket_size; i++)
        {

            if (hashtable[i] != nullptr)
            {
                // cout<<hashtable[i]<<endl;

                delete hashtable[i];

                // cout<<hashtable[i]<<endl;
            }
        }

        delete[] hashtable;
    }
    SymbolInfo *LookUp(string name)
    {
        int pos = SDBMHash(name);
        // cout<<"pos in lookup"<<pos<<endl;
        int i = 1;
        SymbolInfo *current = hashtable[pos];
        while (current != nullptr)
        {
            if (current->getName() == name)
            {
                // cout<<"\t"<<"'"<<name <<"' "<< "found in ScopeTable# "<< scope_id << " at position "<<pos+1<<", "<<i<<endl;
                return current;
            }
            i++;
            current = current->getNext();
        }
        return nullptr;
    }
    SymbolInfo *LookUpInsert(string name)
    {
        int pos = SDBMHash(name);
        // cout<<"pos in lookup"<<pos<<endl;
        int i = 1;
        SymbolInfo *current = hashtable[pos];
        while (current != nullptr)
        {
            if (current->getName() == name)
            {

                return current;
            }
            i++;
            current = current->getNext();
        }
        return nullptr;
    }
    

    bool Insert(string name, string type)
    {
        SymbolInfo *sym = LookUpInsert(name);
        if (sym != nullptr)
        {
           // fprintf(logout,"\t%s already exisits in the current ScopeTable\n",const_cast<char *>(name.c_str()));
            return false;
        }
        int pos = SDBMHash(name);
        // cout<<pos <<"is"<<endl;
        int i = 1;
        SymbolInfo *currSymbolInfo = new SymbolInfo(name, type);
        if (hashtable[pos] == nullptr)
        {
            hashtable[pos] = currSymbolInfo;
            // cout<<"i"<<i<<endl;
        }
        else
        {

            SymbolInfo *newSymbolInfo = hashtable[pos];
            while (newSymbolInfo->getNext() != nullptr)
            {
                newSymbolInfo = newSymbolInfo->getNext();
                i++;
            }
            newSymbolInfo->setNext(currSymbolInfo);
            i++;
        }
        // cout<< "\t"<<"Inserted in ScopeTable# " << scope_id << " at position " << pos+1 <<", "<<i<<endl;
        return true;
    }
bool Insertf(string name, string type,string typespec)
    {
        SymbolInfo *sym = LookUpInsert(name);
        if (sym != nullptr)
        {
           // fprintf(logout,"\t%s already exisits in the current ScopeTable\n",const_cast<char *>(name.c_str()));
            return false;
        }
        int pos = SDBMHash(name);
        // cout<<pos <<"is"<<endl;
        int i = 1;
        SymbolInfo *currSymbolInfo = new SymbolInfo(name,type,typespec);
        if (hashtable[pos] == nullptr)
        {
            hashtable[pos] = currSymbolInfo;
            // cout<<"i"<<i<<endl;
        }
        else
        {

            SymbolInfo *newSymbolInfo = hashtable[pos];
            while (newSymbolInfo->getNext() != nullptr)
            {
                newSymbolInfo = newSymbolInfo->getNext();
                i++;
            }
            newSymbolInfo->setNext(currSymbolInfo);
            i++;
        }
        // cout<< "\t"<<"Inserted in ScopeTable# " << scope_id << " at position " << pos+1 <<", "<<i<<endl;
        return true;
    }


    bool Delete(string name)
    {
        int pos = SDBMHash(name);
        int i = 1;
        SymbolInfo *currSymbolInfo = hashtable[pos];
        if (currSymbolInfo != nullptr)
        {
            if (currSymbolInfo->getName() == name)
            {
                // cout<< "\t"<< "Deleted"<<" '"<<name<<"' "<< "from ScopeTable# "<< scope_id<< " at position " <<pos+1<<", "<<i<<endl;
                hashtable[pos] = currSymbolInfo->getNext();
                return true;
            }
        }
        else if (currSymbolInfo == nullptr)
        {
            // cout<< "\t"<<"Not found in the current ScopeTable"<<endl;
            return false;
        }

        SymbolInfo *prevSymbolInfo = currSymbolInfo;
        while (currSymbolInfo->getNext() != nullptr)
        {
            if (currSymbolInfo->getName() == name)
            {
                prevSymbolInfo->setNext(currSymbolInfo->getNext());
                delete currSymbolInfo;
                // cout<< "\t"<<"Deleted "<<" '"<<name<<"' "<< "from ScopeTable# "<< scope_id<< " at position " <<pos+1<<", "<<i<<endl;
                return true;
            }
            prevSymbolInfo = currSymbolInfo;
            currSymbolInfo = currSymbolInfo->getNext();

            i++;
        }
        return false;
    }

    void printScopeTable(ofstream &logout)
    {
        logout<<"\tScopeTable# "<<scope_id<<endl;
        for (int i = 0; i < bucket_size; i++)
        {
            if (hashtable[i] != nullptr)
            {
                logout<<"\t"<< i + 1;
                SymbolInfo *currSymbolInfo = hashtable[i];
                while (currSymbolInfo != nullptr)
                {
                    logout<< "<"<<currSymbolInfo->getName()<<", "<<currSymbolInfo->getType()<<">";
                    currSymbolInfo = currSymbolInfo->getNext();
                }
                logout<<endl;
            }
        }
    }
};

class SymbolTable
{
    int bucket_size;
    ScopeTable *currScopeTable;
    int scope_count;

public:
    SymbolTable(int bSize)
    {
        this->bucket_size = bSize;
        // this->currScopeTable = new ScopeTable(bSize);
        currScopeTable = nullptr;
        this->scope_count = 0;
        ScopeTable *newScope = new ScopeTable(bucket_size);
        newScope->setParentScope(currScopeTable);
        currScopeTable = newScope;
        scope_count++;
        newScope->setId(scope_count);
    }
    int getScopeCount()
    {
        return scope_count;
    }
    void setScopeCount(int id)
    {
        this->scope_count = id;
    }
    ScopeTable *getCurrentScope()
    {
        return currScopeTable;
    }
    void setCurrentScopeTable(ScopeTable *curr)
    {
        currScopeTable = curr;
    }
    void EnterScope()
    {
        ScopeTable *newScope = new ScopeTable(bucket_size);
        newScope->setParentScope(currScopeTable);
        currScopeTable = newScope;
        scope_count++;
        newScope->setId(scope_count);
        // cout<< "\t"<<"ScopeTable# "<< newScope->getId() << " created"<<endl;
    }
    

    void QuitProgram()
    {

        while (currScopeTable != nullptr)
        {
            ScopeTable *removable = currScopeTable;
            currScopeTable = currScopeTable->getParentScope();

            // cout<< "\t"<<"ScopeTable# "<<removable->getId()<<" removed"<<endl;
        }
    }

    bool InsertSymbol(string name, string type)
    {
        if (currScopeTable == nullptr)
            return false;
        bool success = currScopeTable->Insert(name, type);
        return success;
    }
    bool InsertFunc(string name, string type,string typespec)
    {
         if (currScopeTable == nullptr)
            return false;
        bool success = currScopeTable->Insertf(name, type,typespec);
        return success;
    }
    bool deleteSymbol(string name)
    {
        if (currScopeTable == nullptr)
            return false;
        bool success = currScopeTable->Delete(name);
        return success;
    }
    SymbolInfo *LookUP(string name)
    {
        ScopeTable *presentScope = currScopeTable;
        while (presentScope != nullptr)
        {
            SymbolInfo *sym = presentScope->LookUp(name);
            if (sym != nullptr)
                return sym;
            presentScope = presentScope->getParentScope();
        }
        // cout<< "\t"<<"'"<<name <<"' "<<"not found in any of the ScopeTables"<<endl;
        return nullptr;
    }
    void printAllScopeTable(ofstream &logout)
    {
        ScopeTable *present = currScopeTable;
        while (present != nullptr)
        {
            present->printScopeTable(logout);
            present = present->getParentScope();
        }
    }
    void printCurrScopeTable(ofstream &logout)
    {
        currScopeTable->printScopeTable(logout);
    }
   
    void exitScope()
    {
        
        if (currScopeTable == nullptr)
        {
            return;
        }
     
            currScopeTable = currScopeTable->getParentScope();
            // cout<< "\t"<<"ScopeTable# "<<removable->getId()<<" removed"<<endl;
      

        //  else
        // cout<< "\t"<<"ScopeTable# "<<removable->getId()<<" cannot be removed"<<endl;
    }

    ~SymbolTable()
    {
        while (currScopeTable != nullptr)
        {
            ScopeTable *previous = currScopeTable->getParentScope();
            delete currScopeTable;
            currScopeTable = previous;
        }
    }
};
