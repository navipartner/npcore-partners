page 6151170 "NPR NpGp Det. POS S. Entries"
{
    Extensible = False;
    Caption = 'Detailed Global POS Sales Entries';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR NpGp Det. POS Sales Entry";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry Time"; Rec."Entry Time")
                {

                    ToolTip = 'Specifies the value of the Entry Time field';
                    ApplicationArea = NPRRetail;
                }
                field("Entry Type"; Rec."Entry Type")
                {

                    ToolTip = 'Specifies the value of the Entry Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Document No."; Rec."Document No.")
                {

                    ToolTip = 'Specifies the value of the Document No. field';
                    ApplicationArea = NPRRetail;
                }
                field(Quantity; Rec.Quantity)
                {

                    ToolTip = 'Specifies the value of the Quantity field';
                    ApplicationArea = NPRRetail;
                }
                field(Open; Rec.Open)
                {

                    ToolTip = 'Specifies the value of the Open field';
                    ApplicationArea = NPRRetail;
                }
                field("Remaining Quantity"; Rec."Remaining Quantity")
                {

                    ToolTip = 'Specifies the value of the Remaining Quantity field';
                    ApplicationArea = NPRRetail;
                }
                field(Positive; Rec.Positive)
                {

                    ToolTip = 'Specifies the value of the Positive field';
                    ApplicationArea = NPRRetail;
                }
                field("Closed by Entry No."; Rec."Closed by Entry No.")
                {

                    ToolTip = 'Specifies the value of the Closed by Entry No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Applies to Store Code"; Rec."Applies to Store Code")
                {

                    ToolTip = 'Specifies the value of the Applies to Store Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Cross Store Application"; Rec."Cross Store Application")
                {

                    ToolTip = 'Specifies the value of the Cross Store Application field';
                    ApplicationArea = NPRRetail;
                }
                field("Entry No."; Rec."Entry No.")
                {

                    ToolTip = 'Specifies the value of the Entry No. field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }
}

