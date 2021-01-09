page 6150672 "NPR POS Entry Output Log"
{
    Caption = 'POS Entry Output Log';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR POS Entry Output Log";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry No. field';
                }
                field("POS Entry No."; "POS Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Entry No. field';
                }
                field("Output Timestamp"; "Output Timestamp")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Output Timestamp field';
                }
                field("Output Type"; "Output Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Output Type field';
                }
                field("User ID"; "User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the User ID field';
                }
                field("Salesperson Code"; "Salesperson Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Salesperson Code field';
                }
                field("Output Method"; "Output Method")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Output Method field';
                }
                field("Output Method Code"; "Output Method Code")
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

