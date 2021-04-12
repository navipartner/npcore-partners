page 6151170 "NPR NpGp Det. POS S. Entries"
{
    Caption = 'Detailed Global POS Sales Entries';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR NpGp Det. POS Sales Entry";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry Time"; Rec."Entry Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry Time field';
                }
                field("Entry Type"; Rec."Entry Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry Type field';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Document No. field';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Quantity field';
                }
                field(Open; Rec.Open)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Open field';
                }
                field("Remaining Quantity"; Rec."Remaining Quantity")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Remaining Quantity field';
                }
                field(Positive; Rec.Positive)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Positive field';
                }
                field("Closed by Entry No."; Rec."Closed by Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Closed by Entry No. field';
                }
                field("Applies to Store Code"; Rec."Applies to Store Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Applies to Store Code field';
                }
                field("Cross Store Application"; Rec."Cross Store Application")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Cross Store Application field';
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry No. field';
                }
            }
        }
    }

    actions
    {
    }
}

