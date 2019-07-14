pageextension 50674 pageextension50674 extends Debugger 
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

