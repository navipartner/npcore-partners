pageextension 6014484 pageextension6014484 extends Debugger 
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

