page 6014593 "NPR Retail Doc. G/L Entries"
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
                field("G/L Account No."; "G/L Account No.")
                {
                    ApplicationArea = All;
                }
                field("glAcc.Name"; glAcc.Name)
                {
                    ApplicationArea = All;
                    Caption = 'Account';
                }
                field(Amount; Amount)
                {
                    ApplicationArea = All;
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

