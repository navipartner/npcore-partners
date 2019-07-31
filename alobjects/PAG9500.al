pageextension 50081 pageextension50081 extends Debugger 
{
    layout
    {
        addafter(Callstack)
        {
            part("Variable List";"Debugger Variable List")
            {
                Caption = 'Debugger';
                Provider = Callstack;
                SubPageLink = "Call Stack ID"=FIELD(ID);
            }
        }
    }
}

