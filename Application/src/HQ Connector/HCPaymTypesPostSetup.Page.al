page 6150905 "NPR HC Paym.Types Post. Setup"
{
    Caption = 'HC Payment Types Posting Setup';
    PageType = List;
    SourceTable = "NPR HC Paym.Type Post.Setup";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("BC Payment Type POS No."; Rec."BC Payment Type POS No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the BC Payment Type POS No. field';
                }
                field("BC Register No."; Rec."BC Register No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the BC Register No. field';
                }
                field("G/L Account No."; Rec."G/L Account No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the G/L Account No. field';
                }
                field("Bank Account No."; Rec."Bank Account No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Bank Account No. field';
                }
            }
        }
    }
}

