page 6150672 "NPR POS Entry Output Log"
{
    Caption = 'POS Entry Output Log';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR POS Entry Output Log";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry No. field';
                }
                field("POS Entry No."; Rec."POS Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Entry No. field';
                }
                field("Output Timestamp"; Rec."Output Timestamp")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Output Timestamp field';
                }
                field("Output Type"; Rec."Output Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Output Type field';
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the User ID field';
                }
                field("Salesperson Code"; Rec."Salesperson Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Salesperson Code field';
                }
                field("Output Method"; Rec."Output Method")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Output Method field';
                }
                field("Output Method Code"; Rec."Output Method Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Output Method Code field';
                }
            }
        }
    }

    actions
    {
    }
}

