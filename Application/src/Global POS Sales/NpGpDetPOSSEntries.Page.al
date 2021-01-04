page 6151170 "NPR NpGp Det. POS S. Entries"
{
    Caption = 'Detailed Global POS Sales Entries';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR NpGp Det. POS Sales Entry";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry Time"; "Entry Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry Time field';
                }
                field("Entry Type"; "Entry Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry Type field';
                }
                field("Document No."; "Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Document No. field';
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Quantity field';
                }
                field(Open; Open)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Open field';
                }
                field("Remaining Quantity"; "Remaining Quantity")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Remaining Quantity field';
                }
                field(Positive; Positive)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Positive field';
                }
                field("Closed by Entry No."; "Closed by Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Closed by Entry No. field';
                }
                field("Applies to Store Code"; "Applies to Store Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Applies to Store Code field';
                }
                field("Cross Store Application"; "Cross Store Application")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Cross Store Application field';
                }
                field("Entry No."; "Entry No.")
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

