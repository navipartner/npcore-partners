pageextension 6014481 pageextension6014481 extends Debugger 
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

