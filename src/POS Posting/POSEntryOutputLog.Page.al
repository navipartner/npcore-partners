page 6150672 "NPR POS Entry Output Log"
{
    // NPR5.39/NPKNAV/20180223  CASE 304165 Transport NPR5.39 - 23 February 2018
    // NPR5.40/MMV /20180319 CASE 304639 Renamed to be print independent and added new field.
    // NPR5.48/MMV /20180619 CASE 318028 French certification

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
                }
                field("POS Entry No."; "POS Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Output Timestamp"; "Output Timestamp")
                {
                    ApplicationArea = All;
                }
                field("Output Type"; "Output Type")
                {
                    ApplicationArea = All;
                }
                field("User ID"; "User ID")
                {
                    ApplicationArea = All;
                }
                field("Salesperson Code"; "Salesperson Code")
                {
                    ApplicationArea = All;
                }
                field("Output Method"; "Output Method")
                {
                    ApplicationArea = All;
                }
                field("Output Method Code"; "Output Method Code")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }
}

