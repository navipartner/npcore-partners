page 6014593 "NPR Retail Doc. G/L Entries"
{
    Caption = 'Detailed Cust. Ledg. Entries';
    Editable = false;
    PageType = ListPart;
    UsageCategory = Administration;
    ApplicationArea = All;
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
                    ToolTip = 'Specifies the value of the G/L Account No. field';
                }
                field("glAcc.Name"; glAcc.Name)
                {
                    ApplicationArea = All;
                    Caption = 'Account';
                    ToolTip = 'Specifies the value of the Account field';
                }
                field(Amount; Amount)
                {
                    ApplicationArea = All;
                    Caption = 'Amount';
                    ToolTip = 'Specifies the value of the Amount field';
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

