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
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(Initial; Rec.Initial)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Initial field';
                }
                field(Blocked; Rec.Blocked)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Blocked field';
                }
                field("Delete Allowed"; Rec."Delete Allowed")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Delete Allowed field';
                }
                field("Rename Allowed"; Rec."Rename Allowed")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Rename Allowed field';
                }
                field("Purchase Insert"; Rec."Purchase Insert")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Purchase Insert field';
                }
                field("Purchase Release"; Rec."Purchase Release")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Purchase Release field';
                }
                field("Purchase Post"; Rec."Purchase Post")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Purchase Post field';
                }
                field("Sales Insert"; Rec."Sales Insert")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Insert field';
                }
                field("Sales Release"; Rec."Sales Release")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Release field';
                }
                field("Sales Post"; Rec."Sales Post")
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

