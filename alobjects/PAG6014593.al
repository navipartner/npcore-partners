page 6014593 "Retail Document G/L Entries"
{
    Caption = 'Detailed Cust. Ledg. Entries';
    Editable = false;
    PageType = ListPart;
    SourceTable = "G/L Entry";

    layout
    {
        area(content)
        {
            repeater(Control6150613)
            {
                ShowCaption = false;
                field("G/L Account No.";"G/L Account No.")
                {
                }
                field("glAcc.Name";glAcc.Name)
                {
                    Caption = 'Account';
                }
                field(Amount;Amount)
                {
                    Caption = 'Amount';
                }
            }
        }
    }

    actions
    {
    }

    var
        Navigate: Page Navigate;
        glAcc: Record "G/L Account";
}

