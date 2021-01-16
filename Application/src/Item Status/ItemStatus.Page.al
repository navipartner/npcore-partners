page 6060056 "NPR Item Status"
{
    // NPR5.25\BR  \20160720  CASE 246088 Object Created
    // NPR5.48/JDH /20181109 CASE 334163 Added Caption to Object

    Caption = 'Item Status';
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
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
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(Initial; Initial)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Initial field';
                }
                field(Blocked; Blocked)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Blocked field';
                }
                field("Delete Allowed"; "Delete Allowed")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Delete Allowed field';
                }
                field("Rename Allowed"; "Rename Allowed")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Rename Allowed field';
                }
                field("Purchase Insert"; "Purchase Insert")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Purchase Insert field';
                }
                field("Purchase Release"; "Purchase Release")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Purchase Release field';
                }
                field("Purchase Post"; "Purchase Post")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Purchase Post field';
                }
                field("Sales Insert"; "Sales Insert")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Insert field';
                }
                field("Sales Release"; "Sales Release")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Release field';
                }
                field("Sales Post"; "Sales Post")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Post field';
                }
            }
        }
    }

    actions
    {
    }
}

