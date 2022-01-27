page 6150905 "NPR HC Paym.Types Post. Setup"
{
    Extensible = False;
    Caption = 'HC Payment Types Posting Setup';
    PageType = List;
    SourceTable = "NPR HC Paym.Type Post.Setup";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("BC Payment Type POS No."; Rec."BC Payment Type POS No.")
                {

                    ToolTip = 'Specifies the value of the BC Payment Type POS No. field';
                    ApplicationArea = NPRRetail;
                }
                field("BC Register No."; Rec."BC Register No.")
                {

                    ToolTip = 'Specifies the value of the BC Register No. field';
                    ApplicationArea = NPRRetail;
                }
                field("G/L Account No."; Rec."G/L Account No.")
                {

                    ToolTip = 'Specifies the value of the G/L Account No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Bank Account No."; Rec."Bank Account No.")
                {

                    ToolTip = 'Specifies the value of the Bank Account No. field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}

