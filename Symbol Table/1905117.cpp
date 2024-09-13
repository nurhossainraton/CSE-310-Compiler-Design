#include <iostream>
using namespace std;

class SymbolInfo
{
    string name,type;
    SymbolInfo *next;
public:
    SymbolInfo()
    {
        this->name=" ";
        this->type=" ";
        this->next=nullptr;
    }
    SymbolInfo(const string &s,const string &t)
    {
        this->name=s;
        this->type=t;
        this->next=nullptr;
    }
    string getName()
    {
        return name;
    }
    void setName(string &str)
    {
        this->name=str;
    }

    void setType(string &t)
    {
        this->type=t;
    }

    string getType()
    {
        return type;
    }

    void setNext(SymbolInfo *next)
    {
        this->next=next;
    }
    SymbolInfo *getNext()
    {
        return next;
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
        bucket_size=7;

    }

    ScopeTable(int bSize)
    {
        this->parentscope=nullptr;
        //this->hashtable=nullptr;
        //this->scope_id=1;
        this->bucket_size=bSize;
        hashtable=new SymbolInfo*[bSize];
        for(int i=0; i<bSize; i++)
        {
            hashtable[i]= nullptr;
        }

    }

    void setParentScope(ScopeTable *parentscope)
    {
        this->parentscope=parentscope;
    }

    ScopeTable* getParentScope()
    {
        return parentscope;
    }

    int getBucketSize()
    {
        return bucket_size;
    }

    void setBucketSize(int bSize)
    {
        this->bucket_size=bSize;
    }

    void setId(int id)
    {
        this->scope_id=id;
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

        return (hash % bucket_size ) ;
    }

    ~ScopeTable()
    {

        for(int i=0; i<bucket_size; i++)
        {

            if(hashtable[i] !=nullptr)
            {
                //cout<<hashtable[i]<<endl;

                delete hashtable[i];

                //cout<<hashtable[i]<<endl;
            }
        }

        delete [] hashtable;
    }
    SymbolInfo* LookUp(string name)
    {
        int pos=SDBMHash(name);
        //cout<<"pos in lookup"<<pos<<endl;
        int i=1;
        SymbolInfo *current= hashtable[pos] ;
        while(current != nullptr)
        {
            if(current->getName()== name)
            {
                cout<<"\t"<<"'"<<name <<"' "<< "found in ScopeTable# "<< scope_id << " at position "<<pos+1<<", "<<i<<endl;
                return current;
            }
            i++;
            current=current->getNext();
        }
        return nullptr;
    }
    SymbolInfo* LookUpInsert(string name)
    {
        int pos=SDBMHash(name);
        //cout<<"pos in lookup"<<pos<<endl;
        int i=1;
        SymbolInfo *current= hashtable[pos] ;
        while(current != nullptr)
        {
            if(current->getName()== name)
            {

                return current;
            }
            i++;
            current=current->getNext();
        }
        return nullptr;
    }


    bool Insert(string name,string type)
    {
        SymbolInfo *sym = LookUpInsert(name);
        if(sym!= nullptr)
        {
            cout<<"\t"<<"'"<<name<<"' "<<"already exists in the current ScopeTable"<<endl;
            return false;
        }
        int pos=SDBMHash(name);
        //cout<<pos <<"is"<<endl;
        int i=1;
        SymbolInfo *currSymbolInfo = new SymbolInfo(name,type);
        if(hashtable[pos] == nullptr)
        {
            hashtable[pos]= currSymbolInfo;
            //cout<<"i"<<i<<endl;

        }
        else
        {

            SymbolInfo *newSymbolInfo = hashtable[pos];
            while(newSymbolInfo->getNext() != nullptr)
            {
                newSymbolInfo = newSymbolInfo->getNext();
                i++;
            }
            newSymbolInfo ->setNext(currSymbolInfo);
            i++;
        }
        cout<< "\t"<<"Inserted in ScopeTable# " << scope_id << " at position " << pos+1 <<", "<<i<<endl;
        return true;

    }


    bool Delete (string name)
    {
        int pos=SDBMHash(name);
        int i=1;
        SymbolInfo *currSymbolInfo = hashtable[pos];
        if(currSymbolInfo != nullptr)
        {
            if(currSymbolInfo->getName() == name)
            {
                cout<< "\t"<< "Deleted"<<" '"<<name<<"' "<< "from ScopeTable# "<< scope_id<< " at position " <<pos+1<<", "<<i<<endl;
                hashtable[pos]=currSymbolInfo->getNext();
                return true;

            }
        }
        else if(currSymbolInfo == nullptr)
        {
            cout<< "\t"<<"Not found in the current ScopeTable"<<endl;
            return false;
        }

        SymbolInfo *prevSymbolInfo= currSymbolInfo;
        while(currSymbolInfo->getNext() !=nullptr)
        {
            if(currSymbolInfo->getName() == name)
            {
                prevSymbolInfo->setNext(currSymbolInfo->getNext());
                delete currSymbolInfo;
                cout<< "\t"<<"Deleted "<<" '"<<name<<"' "<< "from ScopeTable# "<< scope_id<< " at position " <<pos+1<<", "<<i<<endl;
                return true;

            }
            prevSymbolInfo = currSymbolInfo;
            currSymbolInfo = currSymbolInfo->getNext();

            i++;

        }
        return false;

    }


    void printScopeTable()
    {
        cout<< "\t"<<"ScopeTable# "<< scope_id <<endl;
        for(int i=0; i<bucket_size; i++)
        {
            cout<<"\t"<<i+1<<"--> ";
            SymbolInfo *currSymbolInfo = hashtable[i];
            while(currSymbolInfo != nullptr)
            {
                cout<<"<"<<currSymbolInfo->getName()<<","<<currSymbolInfo->getType()<<"> ";
                currSymbolInfo = currSymbolInfo->getNext();
            }
            cout<<endl;
        }

    }
};

class SymbolTable
{
    int bucket_size;
    ScopeTable *currScopeTable ;
    int scope_count ;
public:
    SymbolTable(int bSize)
    {
        this->bucket_size = bSize;
        //this->currScopeTable = new ScopeTable(bSize);
        currScopeTable = nullptr;
        this->scope_count = 0;
    }
    int getScopeCount()
    {
        return scope_count;
    }
    void setScopeCount (int id)
    {
        this->scope_count =id;
    }
    ScopeTable* getCurrentScope()
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
        currScopeTable=newScope;
        scope_count++;
        newScope->setId(scope_count);
        cout<< "\t"<<"ScopeTable# "<< newScope->getId() << " created"<<endl;

    }
    void exitScope()
    {
        if(currScopeTable == nullptr)
        {
            return ;
        }
        ScopeTable *removable = currScopeTable;
        if(removable->getId() != 1)
        {
            currScopeTable =currScopeTable->getParentScope();

            cout<< "\t"<<"ScopeTable# "<<removable->getId()<<" removed"<<endl;
        }

        else
            cout<< "\t"<<"ScopeTable# "<<removable->getId()<<" cannot be removed"<<endl;
    }

    void QuitProgram()
    {


        while(currScopeTable!=nullptr)
        {
            ScopeTable *removable = currScopeTable;
            currScopeTable =currScopeTable->getParentScope();


            cout<< "\t"<<"ScopeTable# "<<removable->getId()<<" removed"<<endl;
        }
    }

    bool InsertSymbol(string name,string type)
    {
        if(currScopeTable == nullptr)
            return false ;
        bool success = currScopeTable ->Insert(name,type);
        return success;
    }
    bool deleteSymbol (string name)
    {
        if(currScopeTable == nullptr)
            return false;
        bool success = currScopeTable->Delete(name);
        return success;

    }
    SymbolInfo* LookUP(string name)
    {
        ScopeTable *presentScope = currScopeTable;
        while(presentScope != nullptr)
        {
            SymbolInfo *sym = presentScope ->LookUp(name);
            if(sym != nullptr) return sym;
            presentScope = presentScope->getParentScope();
        }
        cout<< "\t"<<"'"<<name <<"' "<<"not found in any of the ScopeTables"<<endl;
        return nullptr;
    }
    void printAllScopeTable()
    {
        ScopeTable *present = currScopeTable;
        while(present != nullptr)
        {
            present->printScopeTable();
            present = present->getParentScope();
        }
    }
    void printCurrScopeTable()
    {
        currScopeTable->printScopeTable();
    }

    ~SymbolTable()
    {
        while(currScopeTable != nullptr)
        {
            ScopeTable *previous = currScopeTable->getParentScope();
            delete currScopeTable;
            currScopeTable = previous;
        }
    }
};

void splitstr(string str, string deli,string ara[])
{
    int start = 0,i=0;
    int end = str.find(deli);
    while (end != -1)
    {
        ara[i++]= str.substr(start, end - start) ;
        start = end + deli.size();
        end = str.find(deli, start);
    }
    ara[i] = str.substr(start, end - start);
}

int length(string ara[])
{
    int len=0;
    for(int i=0; i<100; i++)
    {
        if(ara[i] != " ")
            len++;
        else
            return len;
    }
}


int main()
{
    /* SymbolInfo a,b("raton","int");
     cout<<a.getName()<<endl;
     cout<<a.getType()<<endl;
     cout<<b.getName()<<endl;
     cout<<b.getType()<<endl;
     ScopeTable c(7);
     cout<<"this is another"<<endl;
     cout <<c.getBucketSize() <<" "<<c.getId()<<endl;

     cout<<c.getParentScope()<<endl;
     string s= "foo",s1="FUNCTION";
     string s2="i",s3= "VAR";
     cout<<"hash is "<<c.SDBMHash(s)<<endl;
     c.Insert(s,s1);
     c.Insert(s2,s3);

     //c.Delete(s);
     c.printScopeTable();
      c.LookUp(s);*/



    string ara[100];
    for(int i=0; i<100; i++)
    {
        ara[i]=" ";
    }
    freopen("input.txt","r",stdin);
    freopen("output.txt","w",stdout);
    int bucket_size;
    cin>>bucket_size;
    SymbolTable symbolTable (bucket_size);
    symbolTable.EnterScope();

    string cmdline;
    int i=1;
    while(1)
    {
        //cin>>cmd;
        getline(cin,cmdline);
        splitstr(cmdline," ",ara);
        if( ara[0] == "I")
        {
            if(length(ara) == 3)
            {
                string name = ara[1],type= ara[2];
                int j=0;
                cout<<"Cmd "<<i<<": ";
                while(ara[j] != " ")
                {
                    if(ara[j+1] != " ")
                    {
                        cout<<ara[j]<<" ";
                        j++;
                    }
                    else
                    {
                         cout<<ara[j];
                         j++;
                    }

                }
                cout<<endl;
                symbolTable.InsertSymbol(name,type);
                i++;
            }
            else
            {
                //cout<<"Cmd "<< i << " :"<<ara[0] <<" " <<ara[1] <<endl;
                int j=0;
                cout<<"Cmd "<<i<<": ";
                while(ara[j] != " ")
                {
                   if(ara[j+1] != " ")
                    {
                        cout<<ara[j]<<" ";
                        j++;
                    }
                    else
                    {
                         cout<<ara[j];
                         j++;
                    }
                }
                cout<<endl;
                cout<<"\t"<<"Number of parameters mismatch for the command I"<<endl;
                i++;
            }
            //symbolTable.EnterScope();

        }

        else if(ara[0] == "L")
        {
            //cout<<length(ara)<<endl;
            if(length(ara) ==2)
            {
                string name = ara[1];
                int j=0;
                cout<<"Cmd "<<i<<": ";
                while(ara[j] != " ")
                {
                    if(ara[j+1] != " ")
                    {
                        cout<<ara[j]<<" ";
                        j++;
                    }
                    else
                    {
                         cout<<ara[j];
                         j++;
                    }
                }
                cout<<endl;
                symbolTable.LookUP(name);
                i++;
            }
            else
            {
                int j=0;
                cout<<"Cmd "<<i<<": ";
                while(ara[j] != " ")
                {
                    if(ara[j+1] != " ")
                    {
                        cout<<ara[j]<<" ";
                        j++;
                    }
                    else
                    {
                         cout<<ara[j];
                         j++;
                    }
                }
                cout<<endl;
                cout<<"\t"<<"Number of parameters mismatch for the command L"<<endl;
                i++;
            }

        }
        else if ( ara[0] == "D")
        {
            if(length(ara) == 2)
            {
                string name = ara[1];
                int j=0;
                cout<<"Cmd "<<i<<": ";
                while(ara[j] != " ")
                {
                    if(ara[j+1] != " ")
                    {
                        cout<<ara[j]<<" ";
                        j++;
                    }
                    else
                    {
                         cout<<ara[j];
                         j++;
                    }
                }
                cout<<endl;
                symbolTable.deleteSymbol(name);
                i++;
            }
            else
            {
                int j=0;
                cout<<"Cmd "<<i<<": ";
                while(ara[j] != " ")
                {
                    if(ara[j+1] != " ")
                    {
                        cout<<ara[j]<<" ";
                        j++;
                    }
                   else
                    {
                         cout<<ara[j];
                         j++;
                    }
                }
                cout<<endl;
                cout<<"\t"<<"Number of parameters mismatch for the command D"<<endl;
                i++;
            }
        }

        else if(ara[0] == "P")
        {
            if(length(ara) ==2)
            {
                string optn;
                optn = ara[1];
                int j=0;
                cout<<"Cmd "<<i<<": ";
                while(ara[j] != " ")
                {
                    if(ara[j+1] != " ")
                    {
                        cout<<ara[j]<<" ";
                        j++;
                    }
                    else
                    {
                         cout<<ara[j];
                         j++;
                    }
                }
                cout<<endl;

                if( optn == "C")
                {
                    symbolTable.printCurrScopeTable();
                }
                else
                    symbolTable.printAllScopeTable();
                i++;
            }
            else
            {
                int j=0;
                cout<<"Cmd "<<i<<": ";
                while(ara[j] != " ")
                {
                    if(ara[j+1] != " ")
                    {
                        cout<<ara[j]<<" ";
                        j++;
                    }
                    else
                    {
                         cout<<ara[j];
                         j++;
                    }
                }
                cout<<endl;
                cout<<"\t"<<"Number of parameters mismatch for the command P"<<endl;
                i++;
            }

        }
        else if(ara[0] == "S")
        {
            if(length(ara) ==1)
            {
                cout<<"Cmd "<< i << ": "<<ara[0] <<endl;
                symbolTable.EnterScope();
            }
            else
            {
                int j=0;
                cout<<"Cmd "<<i<<": ";
                while(ara[j] != " ")
                {
                    if(ara[j+1] != " ")
                    {
                        cout<<ara[j]<<" ";
                        j++;
                    }
                   else
                    {
                         cout<<ara[j];
                         j++;
                    }
                }
                cout<<endl;
                cout<<"\t"<<"Number of parameters mismatch for the command S"<<endl;
            }

            i++;


        }
        else if(ara[0] ==  "E")
        {
            if(length(ara) ==1)
            {
                cout<<"Cmd "<< i << ": "<<ara[0] <<endl;
                symbolTable.exitScope();
                i++;
            }
            else
            {
                int j=0;
                cout<<"Cmd "<<i<<": ";
                while(ara[j] != " ")
                {
                    if(ara[j+1] != " ")
                    {
                        cout<<ara[j]<<" ";
                        j++;
                    }
                    else
                    {
                         cout<<ara[j];
                         j++;
                    }
                }
                cout<<endl;
                cout<<"\t"<<"Number of parameters mismatch for the command E"<<endl;
                i++;
            }

        }
        else if( ara[0] == "Q")
        {
            if(length(ara) ==1)
            {
                cout<<"Cmd "<< i << ": "<<ara[0] <<endl;
                symbolTable.QuitProgram();
                break;
            }

            else
            {
                int j=0;
                cout<<"Cmd "<<i<<": ";
                while(ara[j] != " ")
                {
                    if(ara[j+1] != " ")
                    {
                        cout<<ara[j]<<" ";
                        j++;
                    }
                    else
                    {
                         cout<<ara[j];
                         j++;
                    }

                }
                cout<<endl;
                cout<<"\t"<<"Number of parameters mismatch for the command Q"<<endl;
                i++;
            }
        }
        for(int i =0; i<100; i++)
        {
            ara[i] = " ";
        }
    }



}
