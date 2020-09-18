page 6060056 "NPR Item Status"
{
    // NPR5.25\BR  \20160720  CASE 246088 Object Created
    // NPR5.48/JDH /20181109 CASE 334163 Added Caption to Object

    Caption = 'Item Status';
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR Item Status";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field(Initial; Initial)
                {
                    ApplicationArea = All;
                }
                field(Blocked; Blocked)
                {
                    ApplicationArea = All;
                }
                field("Delete Allowed"; "Delete Allowed")
                {
                    ApplicationArea = All;
                }
                field("Rename Allowed"; "Rename Allowed")
                {
                    ApplicationArea = All;
                }
                field("Purchase Insert"; "Purchase Insert")
                {
                    ApplicationArea = All;
                }
                field("Purchase Release"; "Purchase Release")
                {
                    ApplicationArea = All;
                }
                field("Purchase Post"; "Purchase Post")
                {
                    ApplicationArea = All;
                }
                field("Sales Insert"; "Sales Insert")
                {
                    ApplicationArea = All;
                }
                field("Sales Release"; "Sales Release")
                {
                    ApplicationArea = All;
                }
                field("Sales Post"; "Sales Post")
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

